# ADR-0009: Caddy as Reverse Proxy

- **Status**: accepted
- **Updates**: Proxy choice in [ADR-0008](0008-ssh-deployment-strategy.md) (ADR-0008 remains authoritative for deployment strategy)
- **C4 Level**: L2-Container
- **Scope**: Reverse proxy selection for self-hosted Docker deployments
- **Date**: 2026-03-26

## Context

ADR-0008 assumes Traefik with a `traefik-public` external network (Coolify-managed). In practice, we deploy on bare VPS without Coolify — requiring manual Traefik setup (traefik.yml, dynamic config, Docker network creation). Caddy provides the same functionality with minimal config.

Production incident: blanket rate limiting at proxy level counted all requests (static assets included), blocking legitimate users after 2-3 page loads.

## Decision

Replace Traefik with Caddy as the default reverse proxy.

- Custom Caddy image (`Dockerfile.caddy`) built with `xcaddy` + `mholt/caddy-ratelimit` plugin
- Caddyfile with matcher-scoped rate limiting (static assets excluded, auth endpoints stricter)
- Caddy runs as a service inside the compose stack — no external network dependency

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

- **Easier:** No external network setup, no Traefik container to manage, simpler config, automatic HTTPS via ACME
- **Harder:** No Docker label-based service discovery (explicit Caddyfile entries needed). Custom Caddy image needed for rate-limit plugin.
- **Constraint:** Caddyfile changes require `docker compose restart caddy` (bind mount inode gotcha — see troubleshooting in cicd-setup.md)

## Migration from Traefik

For servers currently running with Traefik:

1. Stop all services: `docker compose -f docker-compose.prod.yml down`
2. Stop standalone Traefik if running: `docker stop traefik && docker rm traefik`
3. Free ports 80/443 (verify: `ss -tlnp | grep -E ':80|:443'`)
4. Remove old external network: `docker network rm traefik-public` (optional cleanup)
5. Pull updated compose + Caddyfile
6. Set `ACME_EMAIL` in `.env`
7. Build Caddy image: `docker compose -f docker-compose.prod.yml build caddy`
8. Start: `docker compose -f docker-compose.prod.yml up -d`
9. Caddy auto-provisions TLS certificates on first request

## Related ADRs

- [ADR-0008](0008-ssh-deployment-strategy.md): SSH Deployment Strategy (authoritative for deploy workflow)
- [ADR-0005](0005-cicd-pipeline-architecture.md): CI/CD Pipeline Architecture
