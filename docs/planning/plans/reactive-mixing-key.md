# Security Audit Skills — Implementation Plan

## Context

Dit project (Next.js 16 + FastAPI + PostgreSQL) heeft al een sterke security-basis (pre-commit hooks, CI security workflows, headers, Docker hardening). Wat ontbreekt is een **on-demand, interactieve security audit** die dieper gaat dan geautomatiseerde CI-checks en rekening houdt met app-context.

We bouwen 5 skills: 1 orchestrator + 4 scanners. Elk los aanroepbaar of als geheel via de orchestrator.

Alle SKILL.md bestanden en rapporten in het **Engels** (consistent met de rest van de codebase).

## Bestandsoverzicht (11 bestanden)

```
.claude/skills/
├── security-audit/
│   └── SKILL.md                          # Orchestrator + auto-detect + intake
├── security-code-scan/
│   ├── SKILL.md                          # OWASP + AI security scanner
│   └── references/
│       ├── owasp-fastapi.md              # FastAPI vulnerability patterns
│       ├── owasp-nextjs.md               # Next.js vulnerability patterns
│       └── prompt-injection.md           # AI/LLM security patterns
├── security-config-scan/
│   ├── SKILL.md                          # Infra & config scanner
│   └── references/
│       ├── headers-checklist.md          # HTTP security headers reference
│       └── docker-checklist.md           # Docker hardening reference
├── security-exposure-scan/
│   ├── SKILL.md                          # Exposure & privacy scanner
│   └── references/
│       └── crawler-blocking.md           # robots.txt + AI crawlers reference
└── security-deps-scan/
    └── SKILL.md                          # Dependencies & supply chain scanner
```

## Bouwvolgorde

Scanners eerst (geen dependencies), orchestrator laatst.

---

### Stap 1: `security-code-scan` (~300 regels SKILL.md + 3 references)

**SKILL.md** frontmatter:
```yaml
---
name: security-code-scan
description: >-
  Scan codebase for OWASP Top 10 vulnerabilities, AI/LLM security issues,
  and stack-specific risks in FastAPI + Next.js. Use when reviewing code
  for security issues, before deployment, or when security-audit dispatches
  a code scan. Covers SQL injection, XSS, SSRF, command injection, prompt
  injection, and framework-specific patterns.
---
```

**SKILL.md body** bevat:
- Grep-patronen tabel per vulnerability type met **expliciete exclusion patterns**:

  | Vulnerability | Pattern | Scope | Exclude |
  |---|---|---|---|
  | SQL injection | `text(f"` / `text(f'` | `backend/**/*.py` | — |
  | XSS | `dangerouslySetInnerHTML` | `frontend/src/**/*.tsx` | — |
  | Command injection | `subprocess\|os\.system\|os\.popen` | `backend/**/*.py` | `session.execute`, `connection.execute` (SQLAlchemy) |
  | Insecure eval | `eval\(\|exec\(` | `**/*.py` | `session.execute`, `connection.execute` |
  | SSRF | `httpx\.\|requests\.\|urllib\.request` | `backend/**/*.py` | Constante URLs, health checks |
  | Path traversal | `open\(.*\+\|Path\(.*\+` | `backend/**/*.py` | Hardcoded paden |
  | Mass assignment | `class.*BaseModel` zonder `model_config` | `backend/**/*.py` | — |
  | Error disclosure | `str\(exc\)\|str\(e\)\|traceback` in responses | `backend/**/*.py` | Logger calls |
  | Prompt injection | `openai\|anthropic\|langchain\|llama` | `**/*.py`, `**/*.ts` | — |

- Scan procedure: per vulnerability type: (1) Grep voor patroon, (2) Read context rondom match, (3) Check exclusion, (4) Classificeer als PASS/FAIL/WARN
- Known-good patronen sectie (net als config-scan)
- Severity classificatie tabel
- Output format template (consistent met alle scans)
- Verwijzingen naar references voor stack-specifieke details

**references/owasp-fastapi.md** (~200 regels):
- `Depends()` auth gaps: endpoints zonder auth dependency, met whitelist voor health/public endpoints
- `response_model` ontbreekt: data leakage risico
- `text()` met f-strings vs veilig `bindparams()` — met code voorbeelden van SAFE vs UNSAFE
- Background tasks met sensitive data
- `pickle.loads`, `yaml.load` zonder SafeLoader
- Input validatie: `dict`/`Any` vs typed Pydantic models
- **Expliciete SQLAlchemy safe patterns**: `session.execute(select(...))`, `session.execute(text(...).bindparams(...))` zijn VEILIG

**references/owasp-nextjs.md** (~150 regels):
- Server Actions: **note dat Next.js 16 ingebouwde CSRF-bescherming heeft** — alleen flaggen als bescherming expliciet omzeild wordt
- Server vs Client component data leakage via props
- `eval()`, `Function()` in client code
- Source maps (`productionBrowserSourceMaps`)
- `next/image` remotePatterns audit
- `NEXT_PUBLIC_` prefix: geen secrets
- Middleware bypass checks

**references/prompt-injection.md** (~100 regels):
- Directe prompt injection: user input geconcateneerd in prompts
- Indirecte prompt injection: RAG documenten met instructies
- System prompt leakage via errors/API
- Output validatie: LLM output in SQL/HTML/commands
- API key exposure in client-side code
- Detectie-patronen voor LLM libraries
- **Als geen AI integraties gevonden: rapporteer N/A met INFO-note**

---

### Stap 2: `security-config-scan` (~250 regels SKILL.md + 2 references)

**SKILL.md** frontmatter:
```yaml
---
name: security-config-scan
description: >-
  Audit infrastructure and configuration security: HTTP headers, CORS,
  Docker hardening, rate limiting, auth status, cookie security, env var
  hygiene, and SSL/TLS. Use for deployment readiness checks, configuration
  reviews, or when security-audit dispatches a config scan. Covers
  next.config.ts, FastAPI middleware, Docker compose, and PostgreSQL.
---
```

**SKILL.md body** bevat:
- Geordende scan procedure (10 stappen):
  1. Read `frontend/next.config.ts` → cross-ref met `references/headers-checklist.md`
  2. Read `backend/shared/middleware/cors.py` + `backend/shared/config.py` → CORS validatie (wildcard check, productie vs dev)
  3. Read `backend/app/main.py` → OpenAPI/Swagger productie check (`openapi_url=None`)
  4. Read `backend/Dockerfile` + `frontend/Dockerfile` → cross-ref met `references/docker-checklist.md`
  5. Read `backend/docker-compose.prod.yml` → compose security
  6. Read `backend/shared/auth/dependencies.py` → auth implementatie status (stub vs real)
  7. Read `backend/shared/middleware/rate_limit.py` + check `rate_limit_default` in `config.py` → config validatie
  8. Read `backend/.env.example` → secret placeholder patronen, `SECRET_KEY` min_length=32
  9. Grep `set_cookie|response\.cookies` → cookie security flags (Secure, HttpOnly, SameSite)
  10. Grep `DATABASE_URL|postgresql` → SSL mode check (`sslmode=require`)
- Known-good patronen (specifiek voor dit project):
  - OpenAPI disabled in prod (`openapi_url=None if not is_development`) ✓
  - Docker non-root (UID 1001) ✓, read_only ✓, no-new-privileges ✓
  - Sentry `send_default_pii=False` ✓
  - Generic error messages in `unhandled_exception_handler` ✓
  - `SECRET_KEY` min_length=32 ✓
  - Rate limit default `100/minute` ✓

**references/headers-checklist.md** (~150 regels):
- Tabel: Header | Verwachte waarde | Severity als ontbreekt | Huidige status
- CSP directive-analyse (`unsafe-inline`/`unsafe-eval` = MEDIUM warning)
- Ontbrekende headers flaggen: `Permissions-Policy`, `Cross-Origin-Opener-Policy`, `Cross-Origin-Resource-Policy`

**references/docker-checklist.md** (~120 regels):
- Dockerfile checks: multi-stage, non-root USER, geen secrets in build args, `.dockerignore` bestaat, specifieke base image tags, HEALTHCHECK
- Compose checks: `read_only`, `no-new-privileges`, `tmpfs`, internal networks, geen exposed ports voor DB/Redis, resource limits
- Per check: current status in dit project

---

### Stap 3: `security-exposure-scan` (~250 regels SKILL.md + 1 reference)

**SKILL.md** frontmatter:
```yaml
---
name: security-exposure-scan
description: >-
  Scan for external exposure and privacy risks: search engine and AI crawler
  indexation control (robots.txt, meta robots), PII in logs, API endpoint
  inventory, source maps, error leakage, open redirects, and license
  compliance. Use before production launch, for privacy audits, or when
  security-audit dispatches an exposure scan.
---
```

**SKILL.md body** bevat:
- Known-good patronen sectie (consistent met andere scans)
- Scan procedure (10 stappen):
  1. Check `frontend/public/robots.txt` bestaat
  2. Als robots.txt bestaat: check AI crawler blocking via `references/crawler-blocking.md`
  3. Check `public/sitemap.xml` — geen admin/internal routes exposed
  4. PII in logs: grep op **specifieke patronen** in structlog calls: `password=|secret=|credit_card=|ssn=` (niet losse woorden als `token` die false positives geven)
  5. API endpoint inventarisatie: read alle router files, list endpoints + auth status
  6. Source maps: check `productionBrowserSourceMaps` in next.config.ts
  7. Error message leakage: check exception handlers
  8. Open redirect: grep `redirect(|RedirectResponse(` met variabele URLs
  9. Licentie compliance: cross-ref met deps-scan output
  10. `next/image` remote patterns check

**references/crawler-blocking.md** (~100 regels):
- Complete `robots.txt` template met bekende AI crawlers
- User agent lijst met beschrijving: GPTBot (OpenAI), ChatGPT-User, CCBot (Common Crawl), anthropic-ai, ClaudeBot, Google-Extended, Bytespider (ByteDance), Applebot-Extended, PerplexityBot, YouBot, Amazonbot
- Meta robots tag opties en wanneer te gebruiken
- `X-Robots-Tag` header voor API routes
- Note: robots.txt is advisory — geen security boundary

---

### Stap 4: `security-deps-scan` (~200 regels SKILL.md, geen references)

**SKILL.md** frontmatter:
```yaml
---
name: security-deps-scan
description: >-
  Audit dependency security and supply chain integrity: vulnerability scanning,
  license compatibility, lockfile integrity, and GitHub Actions version pinning.
  Use for dependency reviews, before releases, or when security-audit dispatches
  a deps scan. Covers frontend (pnpm), backend (uv/pip), and CI workflows.
---
```

**SKILL.md body** bevat:
- **Prerequisite check** (voorkomt verwarring bij fresh clone):
  1. Check `node_modules/` bestaat → zo niet: adviseer `pnpm install` eerst, of gebruik alleen lockfile-gebaseerde checks
  2. Check `.venv/` bestaat → zo niet: adviseer `make setup` eerst
  3. Als tools niet beschikbaar: **fallback naar lockfile-analyse + Grep-only mode** (parse `pnpm-lock.yaml` en `uv.lock` voor bekende CVEs, check GitHub Actions pinning)
- Scan procedure (7 stappen):
  1. `pnpm audit --audit-level=moderate` (frontend) — parse severity counts
  2. `uv run pip-audit` (backend) — parse findings
  3. Lockfile integriteit: verify `pnpm-lock.yaml` en `uv.lock` bestaan en committed zijn
  4. GitHub Actions SHA-pinning: grep `uses:` in `.github/workflows/*.yml`, flag mutable tags (`@v4`, `@main`)
  5. Licentie check: `pnpm licenses list` of handmatige check
  6. Outdated packages: `pnpm outdated`, `uv pip list --outdated`
  7. Supply chain advisory: typosquatting, low-popularity flags (handmatig advies)
- Severity classificatie
- **Differentiatie met CI**: `security.yml` draait npm-audit/pip-audit/Trivy automatisch. Deze skill biedt:
  - Interactieve triage (context bij elke finding)
  - Licentie-analyse (niet in CI)
  - Supply chain review (niet in CI)
  - GitHub Actions pinning audit (niet in CI)

---

### Stap 5: `security-audit` orchestrator (~300 regels SKILL.md, geen references)

**SKILL.md** frontmatter:
```yaml
---
name: security-audit
description: >-
  Complete security audit orchestrator with auto-detection and targeted intake.
  Auto-detects app context from codebase (auth method, deploy target, AI usage),
  asks only for ambiguous items (data sensitivity, public/internal), then
  dispatches targeted scans. Use for full security reviews, production readiness,
  or after major changes. Invoke with /security-audit. Supports --quick mode
  to skip intake and run all scans with defaults.
---
```

**SKILL.md body** bevat:

**Phase 1 — Auto-Detect + Intake** (deploy-setup patroon):

Auto-detect uit codebase:
1. Auth methode: read `backend/shared/auth/dependencies.py` → stub/JWT/OAuth
2. Deploy target: read ADRs + docker-compose files → self-hosted/Vercel/cloud
3. AI/LLM gebruik: grep `openai|anthropic|langchain` → ja/nee
4. Framework versies: read `package.json` + `pyproject.toml`

Presenteer gedetecteerde context, dan vraag alleen wat niet af te leiden is:
1. Data sensitivity? (PII, financieel, medisch, publiek)
2. Publiek of intern? (kan soms uit CORS/headers maar niet altijd)

**--quick mode**: skip intake, gebruik defaults (publiek + PII aanname = meest strikte scan)

**Phase 2 — Prioritering**:
- Matrix: context → scan prioriteit + focus areas
- Publiek + PII = CRITICAL prioriteit code-scan + exposure-scan
- Self-hosted = HIGH prioriteit config-scan
- AI integratie = HIGH prioriteit prompt-injection checks
- Presenteer aanbevolen scans, user kiest (of --quick = alles)

**Phase 3 — Dispatch**:
- Voer geselecteerde scans **sequentieel** uit (één scan per keer, voorkomt context overload)
- Volgorde: code → config → exposure → deps
- Per scan: read die scan's SKILL.md en volg de procedure

**Phase 4 — Rapport**:
```
# Security Audit Report
Date: [date]
App Context: [auto-detected + intake answers]

## Executive Summary
- Critical: N | High: N | Medium: N | Low: N | Info: N
- Overall risk: [LOW/MEDIUM/HIGH/CRITICAL]

## Critical & High Findings
[Findings met remediation]

## Medium & Low Findings
[Findings]

## What's Already Good
[PASS items worth noting]

## Recommended Next Steps
[Geprioriteerde acties]
```
- Optie om rapport op te slaan in `docs/security/` (maak directory aan als die niet bestaat)

---

## Verificatie

Na het bouwen van alle skills:
1. Draai `/security-audit` en doorloop volledige auto-detect + intake + alle 4 scans
2. Draai `/security-audit --quick` om quick mode te testen
3. Draai elke scan los: `/security-code-scan`, `/security-config-scan`, `/security-exposure-scan`, `/security-deps-scan`
4. Controleer dat output format consistent is tussen alle scans
5. Controleer dat known-good patronen als PASS worden gerapporteerd (geen false positives op `session.execute`, `connection.execute`, etc.)
6. Controleer dat ontbrekende items (robots.txt, Permissions-Policy header) correct als FAIL worden gevonden
7. Test deps-scan fallback: verwijder `node_modules` tijdelijk, verify graceful fallback naar lockfile-analyse

## Staff Engineer Review — Verwerkte Feedback

| Issue | Status | Oplossing |
|---|---|---|
| Missing YAML frontmatter | ✅ Fixed | Alle 5 SKILL.md files hebben frontmatter met name + description |
| Grep false positives (session.execute) | ✅ Fixed | Exclusion patterns per vulnerability type + known-good sectie in code-scan |
| deps-scan assumes tools installed | ✅ Fixed | Prerequisite check + fallback naar lockfile/grep-only mode |
| Orchestrator over-engineered intake | ✅ Fixed | Auto-detect uit codebase (deploy-setup patroon), slechts 2 vragen |
| Context window budget | ✅ Fixed | Dispatch sequentieel, één scan per keer |
| Next.js Server Actions CSRF | ✅ Fixed | Note dat Next.js 16 ingebouwde CSRF heeft, alleen flag bij bypass |
| PII grep false positives (token) | ✅ Fixed | Specifiekere patronen: `password=` ipv `password` |
| Bestandstelling (16 vs 11) | ✅ Fixed | Gecorrigeerd naar 11 bestanden |
| Taal inconsistentie | ✅ Fixed | Skills en rapporten in Engels |
| --quick mode | ✅ Added | Skip intake, run alle scans met stricte defaults |
| Known-good in alle scans | ✅ Added | Consistent in code-scan, config-scan, en exposure-scan |
