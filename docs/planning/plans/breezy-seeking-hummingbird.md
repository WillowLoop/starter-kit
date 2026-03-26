# Plan: Productie-lessen + Caddy als standaard reverse proxy

## Context

Twee triggers voor dit plan:

1. **Operationele lessen** uit productie:
   - Rate limiting op proxy-niveau telt alle requests (inclusief static assets) → legitieme gebruikers geblokkeerd
   - Docker bind mounts volgen inodes, niet paden → config-reload leest stale data na file-overwrite

2. **Proxy-keuze**: De starter-kit gebruikt Traefik met Coolify-labels, maar we deployen feitelijk op bare VPS met Docker (geen Coolify). Caddy is simpeler voor dit scenario: automatische HTTPS, minimal config, matcher-scoped rate limiting.

## Wijzigingen (10 bestanden, ~180 regels)

### 1. `backend/Dockerfile.caddy` (NIEUW) — Custom Caddy build met rate-limit plugin

`rate_limit` is GEEN ingebouwde Caddy directive — het is de `mholt/caddy-ratelimit` module. Vereist een custom build via `xcaddy`.

```dockerfile
FROM caddy:2-builder AS builder
RUN xcaddy build --with github.com/mholt/caddy-ratelimit

FROM caddy:2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

### 2. `backend/Caddyfile` (NIEUW) — Productie Caddy config

Caddy config met matcher-scoped rate limiting (les 1) en inode-waarschuwing (les 2). Gebruikt `BACKEND_DOMAIN` (niet `API_DOMAIN`) om consistent te blijven met bestaande `.env.example`.

```caddyfile
{
	email {$ACME_EMAIL:admin@example.com}
}

# Frontend
{$FRONTEND_DOMAIN:localhost} {
	# Static assets — no rate limit
	@static path /_next/static/* /favicon.ico /robots.txt /sitemap*.xml *.svg *.png *.jpg *.webp *.woff2
	handle @static {
		reverse_proxy frontend:3000
	}

	# Auth endpoints — strict rate limit
	@auth path /api/auth/* /auth/*
	rate_limit @auth {
		zone auth_zone {
			key    {remote_host}
			events 10
			window 60s
		}
	}
	handle @auth {
		reverse_proxy frontend:3000
	}

	# Dynamic requests — moderate rate limit
	handle {
		rate_limit {
			zone dynamic_zone {
				key    {remote_host}
				events 200
				window 10s
			}
		}
		reverse_proxy frontend:3000
	}
}

# Backend API
{$BACKEND_DOMAIN:api.localhost} {
	# API rate limiting handled by FastAPI slowapi — no proxy-level limit
	reverse_proxy app:8000
}

# NOTE: After editing this file, run `docker compose restart caddy`
# (not `caddy reload`). Docker bind mounts reference inodes — file
# overwrites (write temp → rename) create a new inode, so reload
# reads stale config.
```

### 3. `backend/docker-compose.prod.yml` — Traefik → Caddy

**Wijzigingen:**

a) **Networks**: Vervang `traefik-public` (extern) door `proxy-network` (niet-extern):
```yaml
networks:
  proxy-network:
    name: proxy-network   # Caddy + frontend + backend
  backend-network:
    internal: true
```

b) **Caddy service** toevoegen (met `read_only: true` + tmpfs, consistent met andere services):
```yaml
  caddy:
    build:
      context: .
      dockerfile: Dockerfile.caddy
    restart: unless-stopped
    read_only: true
    tmpfs:
      - /tmp:size=50m
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"   # HTTP/3
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data       # TLS certificates
      - caddy_config:/config   # Caddy runtime config
    networks:
      - proxy-network
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:80"]
      interval: 30s
      timeout: 5s
      retries: 3
    security_opt:
      - no-new-privileges:true
```

> **Noot healthcheck:** Gebruikt port 80 (→ Caddy redirect naar 443) i.p.v. admin API port 2019. Zo werkt de healthcheck ook als de admin API later uitgeschakeld wordt.

c) **Volumes** toevoegen:
```yaml
volumes:
  postgres_data:
  redis_data:
  caddy_data:
  caddy_config:
```

d) **App service**: Verwijder alle Traefik labels, verander `public-network` → `proxy-network`, voeg localhost port binding toe voor deploy health checks:
```yaml
  app:
    # ... (ongewijzigd)
    networks:
      - proxy-network
      - backend-network
    ports:
      - "127.0.0.1:8000:8000"   # Health check only — not externally exposed
    # Verwijder labels blok volledig
```

e) **Frontend service**: Verwijder alle Traefik labels, verander `public-network` → `proxy-network`, voeg localhost port binding toe:
```yaml
  frontend:
    # ... (ongewijzigd)
    networks:
      - proxy-network
    ports:
      - "127.0.0.1:3000:3000"   # Health check only — not externally exposed
    # Verwijder labels blok volledig
```

> **Noot port bindings:** De deploy workflow (deploy.yml) runt health checks via SSH op `localhost:3000` en `localhost:8000`. Zonder port bindings zijn deze containers niet bereikbaar vanaf de host. `127.0.0.1` binding zorgt dat ze niet extern toegankelijk zijn (Caddy routeert extern verkeer).

### 4. `backend/docker-compose.local.yml` — Network naam update

Verander `public-network` / `traefik-public` referenties naar `proxy-network`:

```yaml
networks:
  public-network:
    name: proxy-network
    external: false
```

Verwijder `traefik.enable: "false"` labels (niet meer relevant zonder Traefik).

### 5. `backend/.env.example` — `ACME_EMAIL` toevoegen

Toevoegen na `FRONTEND_DOMAIN` (regel 27):

```env
ACME_EMAIL=admin@your-domain.com  # Let's Encrypt certificate notifications
```

### 6. `docs/architecture/adr/0009-caddy-reverse-proxy.md` (NIEUW) — ADR voor proxy-switch

```markdown
# ADR-0009: Caddy as Reverse Proxy

- **Status**: accepted
- **Updates**: Proxy choice in [ADR-0008](0008-ssh-deployment-strategy.md) (ADR-0008 remains authoritative for deployment strategy)
- **C4 Level**: L2-Container
- **Date**: 2026-03-26

## Context

ADR-0008 assumes Traefik with a `traefik-public` external network (Coolify-managed). In practice, we deploy on bare VPS without Coolify — requiring manual Traefik setup (traefik.yml, dynamic config, Docker network creation). Caddy provides the same functionality with minimal config.

Production incident: blanket rate limiting at proxy level counted all requests (static assets included), blocking legitimate users after 2-3 page loads.

## Decision

Replace Traefik with Caddy as the default reverse proxy.

## Reasoning

1. No Coolify → Traefik labels have no orchestrator to configure them
2. Caddy: automatic HTTPS (ACME), zero TLS config needed
3. Caddy matchers allow scoped rate limiting (static vs dynamic vs auth)
4. Single Caddyfile vs 15+ Docker labels per service
5. Caddy is part of the compose stack — no external network dependency

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| Keep Traefik with manual setup | Requires separate traefik.yml, dynamic config, external network — too much overhead without Coolify |
| Nginx | No automatic HTTPS, more config complexity than Caddy |
| Drop proxy entirely (direct port exposure) | No TLS termination, no rate limiting, no single entry point |

## Consequences

- **Easier:** No external network setup, no Traefik container to manage, simpler config
- **Harder:** No Docker label-based service discovery (explicit Caddyfile entries needed). Custom Caddy image needed for rate-limit plugin.
- **Constraint:** Caddyfile changes require `docker compose restart caddy` (bind mount inode gotcha)

## Migration from Traefik

For servers currently running with Traefik:
1. Stop all services: `docker compose -f docker-compose.prod.yml down`
2. Remove old external network: `docker network rm traefik-public` (optional cleanup)
3. Pull updated compose + Caddyfile
4. Set `ACME_EMAIL` in `.env`
5. Start: `docker compose -f docker-compose.prod.yml up -d`
6. Caddy auto-provisions TLS certificates on first request
```

### 7. `docs/architecture/adr/0008-ssh-deployment-strategy.md` — Traefik → Caddy referenties

4 wijzigingen:

a) Regel 50: `Traefik handles TLS termination and routing` → `Caddy handles TLS termination and routing (see [ADR-0009](0009-caddy-reverse-proxy.md))`

b) Regel 67: `Traefik running with traefik-public external network` → `Caddy runs as part of the compose stack (no external setup needed). See [ADR-0009](0009-caddy-reverse-proxy.md)`

c) Regel 103: `Server needs Traefik configured for TLS` → `Custom Caddy image must be built for rate-limit plugin (Dockerfile.caddy)`

d) Regel 107: `Server must have Docker, Compose, Traefik, and SSH access` → `Server must have Docker, Compose, and SSH access`

### 8. `docs/workflows/cicd-setup.md` — Traefik referenties + troubleshooting

**Traefik referenties updaten:**

a) Regel 59: `Traefik running with traefik-public external network` → `Caddy is included in the compose stack (no external setup needed)`

b) Regel 96-97: Verwijder `docker network create traefik-public || true` blok, vervang door:
```
# No external network needed — Caddy runs inside the compose stack
```

c) Regel 115-116: Wijzig Traefik routing beschrijving:
```
| `BACKEND_DOMAIN` | `api.your-domain.com` | Caddy HTTPS routing |
| `FRONTEND_DOMAIN` | `your-domain.com` | Caddy HTTPS routing |
| `ACME_EMAIL` | `admin@your-domain.com` | Let's Encrypt certificate notifications |
```

d) Regel 143: `Traefik: Ensure Let's Encrypt certresolver is configured` → `Caddy handles TLS automatically — ensure `ACME_EMAIL` is set in `.env``

e) Regel 218: `Check Traefik logs if external routing fails` → `Check Caddy logs: docker compose -f docker-compose.prod.yml logs caddy`

**Troubleshooting entries toevoegen** (na "Health check fails after deploy"):

Entry A: Rate limiting blokkeert normale gebruikers
```markdown
### "Rate limiting blocks normal users (429 errors)"

**Cause:** A blanket rate limit counts ALL requests — JS chunks, CSS, images, API calls. A single Next.js page load generates 40-60 requests.

**Solution:**
1. Use matcher-scoped rate limiting in Caddyfile (static assets excluded, auth endpoints stricter)
2. Keep API rate limiting in the backend via slowapi (separate layer)
3. See `backend/Caddyfile` for the production-ready config
```

Entry B: Config changes niet zichtbaar na reload
```markdown
### "Config file changes not visible inside container after reload"

**Cause:** Tools that overwrite files (write to temp → rename) create a new inode. Docker bind mounts reference the old inode → reload reads stale config.

**Diagnosis:**
```bash
diff <(cat Caddyfile) <(docker compose -f docker-compose.prod.yml exec caddy cat /etc/caddy/Caddyfile)
```

**Solution:** Restart the container, not just reload:
```bash
docker compose -f docker-compose.prod.yml restart caddy
```
```

### 9. `docs/workflows/disaster-recovery.md` — Traefik network referentie

Regel 181: `docker network create traefik-public || true` → verwijderen. Geen externe network nodig met Caddy in de compose stack.

### 10. `.claude/skills/deploy-setup/SKILL.md` — Caddy ipv Traefik

a) Phase 1 scan (regel 14): Verwijder "traefik" uit infra filter, voeg "caddy" toe
b) Server Preparation checklist (regel 75): Vervang Traefik bullet:

**Was:**
```markdown
- [ ] Ensure Traefik is running with `traefik-public` external network
```

**Wordt:**
```markdown
- [ ] Caddy is included in the compose stack — no external setup needed
- [ ] Set `ACME_EMAIL`, `FRONTEND_DOMAIN`, `BACKEND_DOMAIN` in `.env`
- [ ] Note: Caddyfile changes require `docker compose restart caddy` (bind mount inode gotcha)
```

## Wat we NIET doen

| Overweging | Waarom niet |
|---|---|
| Traefik config als alternatief behouden | Eén duidelijke default, geen keuzestress |
| Caddy als aparte compose stack | Moet deel zijn van dezelfde stack voor network access |
| Stock `caddy:2-alpine` gebruiken | `rate_limit` is een plugin (mholt/caddy-ratelimit), vereist custom build |
| `API_DOMAIN` als nieuwe env var | Bestaande codebase gebruikt `BACKEND_DOMAIN` — consistent blijven |
| Path-based routing split voor alle endpoints | Over-engineering; static/auth/dynamic is voldoende |
| Wijzigen slowapi config | Backend rate limiting is correct. Probleem zat op proxy-niveau |
| `docs/workflows/environment-setup.md` updaten | Verwijst alleen naar slowapi proxy-vertrouwen, niet naar Traefik specifiek — tekst is proxy-agnostisch |

## Verificatie

1. `docker compose -f backend/docker-compose.prod.yml config` — valideert compose syntax
2. `docker build -f backend/Dockerfile.caddy backend/` — verifieert custom Caddy build
3. Caddy config check: `docker run --rm -v ./backend/Caddyfile:/etc/caddy/Caddyfile <custom-image> caddy validate --config /etc/caddy/Caddyfile`
4. Grep voor resterende `traefik` referenties buiten ADR-0006 en planningsdocs (die historisch zijn)
5. ADR-0009 consistent met ADR-0008 updates
6. `.env.example` bevat alle env vars uit Caddyfile (`ACME_EMAIL`, `BACKEND_DOMAIN`, `FRONTEND_DOMAIN`)
7. Deploy workflow health checks werken met `127.0.0.1` port bindings
