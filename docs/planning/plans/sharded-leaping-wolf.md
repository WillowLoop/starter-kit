# Plan: Node version check in setup + docs

## Context
ESLint crasht op Node 20 door een incompatibiliteit in `eslint-plugin-react` → `es-iterator-helpers` → `es-abstract` → `side-channel`. De starter-kit specificeert al Node 22 in `.node-version`, maar er is geen runtime check die ontwikkelaars waarschuwt als ze de verkeerde versie draaien. Dit leidt tot cryptische fouten.

## Wijzigingen

### 1. Makefile — Node version check in `setup` target
**File:** `Makefile` (regel 10-16)

Voeg een `node` existence check + version check toe als eerste stappen in de `setup` target, vóór de pnpm/uv checks:

```makefile
setup:  ## First-time project setup
	@command -v node > /dev/null 2>&1 || { echo "Error: Node is not installed. See https://nodejs.org/"; exit 1; }
	@required=$$(cat .node-version | sed 's/\..*//'); \
	 current=$$(node -v | sed 's/v//; s/\..*//'); \
	 if [ "$$current" -lt "$$required" ]; then \
	   echo "Error: Node $$required+ required (current: $$(node -v)). Run: nvm use (or see .node-version)"; \
	   exit 1; \
	 fi
	@command -v pnpm > /dev/null 2>&1 || { echo "Error: pnpm is not installed. See https://pnpm.io/installation"; exit 1; }
	@command -v uv > /dev/null 2>&1 || { echo "Error: uv is not installed. See https://docs.astral.sh/uv/"; exit 1; }
	cd backend && $(MAKE) setup
	cd frontend && pnpm install
	pre-commit install
	pre-commit install --hook-type commit-msg
```

Key fixes vs. v1:
- **`command -v node` check** vóór versie-vergelijking (voorkomt `integer expression expected` als node niet geïnstalleerd is)
- **`sed 's/\..*//'` op beide zijden** — als `.node-version` ooit `22.1.0` bevat, werkt de vergelijking nog steeds
- **Generieke foutmelding** — "nvm use (or see .node-version)" i.p.v. nvm-specifiek

### 2. Docs — Prerequisites in README.md
**File:** `README.md`

Voeg een `## Prerequisites` sectie toe vóór `## Quick Start` (regel 6):

```markdown
## Prerequisites

| Tool | Version | Notes |
|---|---|---|
| Node.js | 22+ (see `.node-version`) | ESLint crashes on Node 20. Use `nvm use` or `fnm use` |
| pnpm | latest | [pnpm.io/installation](https://pnpm.io/installation) |
| uv | latest | [docs.astral.sh/uv](https://docs.astral.sh/uv/) |
| Docker | latest | Required for PostgreSQL |
```

Dit staat in de README (waar developers het verwachten) i.p.v. in `environment-setup.md` (dat over env vars gaat).

## Bewust niet meegenomen
- **Check op andere targets** (`make dev`, `make lint`, `make test`): kan later, `setup` is de critical path
- **`engines` field in package.json**: pnpm respecteert dit, maar de Makefile check geeft een duidelijkere foutmelding en werkt ook voor het backend-gedeelte
- **Exact version pinning**: de check is bewust "minimum major version" (≥22), geen exact match

## Verificatie
1. `nvm use 20 && make setup` → moet falen met `Error: Node 22+ required (current: v20.x.x)`
2. Node niet geïnstalleerd → moet falen met `Error: Node is not installed`
3. `nvm use 22 && make setup` → moet normaal doorlopen
4. `README.md` — prerequisites tabel zichtbaar vóór Quick Start
