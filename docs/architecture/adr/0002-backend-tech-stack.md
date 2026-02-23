# ADR-0002: Backend Tech Stack

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: Backend API container
- **Date**: 2026-02-14

## Context

Het AIpoweredMakers project heeft een backend API nodig die async-first is, sterke type-safety biedt, en goed aansluit bij het Python-ecosysteem. De keuze voor framework, ORM, database, package manager, linter en test runner moet nu gemaakt worden omdat het de basis legt voor alle toekomstige backend ontwikkeling.

## Decision

- **Framework:** FastAPI (Python 3.12+)
- **ORM:** SQLAlchemy 2.0 (async)
- **Database:** PostgreSQL via asyncpg
- **Cache:** Redis
- **Package manager:** uv
- **Linter/Formatter:** Ruff
- **Test runner:** pytest + pytest-asyncio

## Reasoning Chain

1. We bouwen een async API met sterke request/response validatie → framework met native async + Pydantic integratie nodig → FastAPI
2. FastAPI vereist Python, Python ecosystem biedt mature async ORM opties → SQLAlchemy 2.0 met native async support (geen legacy patterns) → SQLAlchemy 2.0 + asyncpg
3. Database moet ACID-compliant zijn met goede async driver support → PostgreSQL (mature, asyncpg is snelste Python async PG driver)
4. Cache/sessie-opslag nodig voor toekomstige features → Redis (de facto standaard, minimale operationele overhead)
5. Package manager moet snel zijn en lockfile ondersteunen → uv (10-100x sneller dan pip/Poetry, native lockfile, editable installs)
6. Linter + formatter moeten snel zijn en één tool → Ruff (vervangt flake8 + black + isort in één binary, 10-100x sneller)
7. Test runner moet native async ondersteunen → pytest + pytest-asyncio (de facto standaard, uitgebreid plugin ecosysteem)

### uv vs Poetry

uv is gekozen boven Poetry omdat:
- uv is significant sneller (Rust-gebaseerd, 10-100x sneller dan Poetry)
- uv gebruikt standaard `pyproject.toml` (geen `poetry.toml`)
- uv genereert een `uv.lock` die gecommit wordt (reproducible builds)
- uv heeft native support voor editable installs en dependency groups

### Ruff vs Black + Flake8

Ruff vervangt meerdere tools (flake8, black, isort, pyupgrade) in één binary:
- Eén configuratie in `pyproject.toml` in plaats van meerdere config files
- 10-100x sneller dan de combinatie van individuele tools
- Actief onderhouden door Astral (zelfde team als uv)

## Alternatives Considered

| Alternatief | Waarom afgewezen |
|---|---|
| Django REST Framework | Heavyweight, synchrone achtergrond, eigen ORM verplicht, overkill voor API-only |
| Express/NestJS (Node.js) | Team expertise is Python, geen voordeel boven FastAPI voor dit project |
| Tortoise ORM | Kleiner ecosysteem dan SQLAlchemy, minder mature async support |
| MongoDB | Geen ACID compliance nodig? Toch wel — SQLAlchemy + PostgreSQL biedt meer flexibiliteit |
| Poetry | Langzamer dan uv, complexere dependency resolution, eigen config formaat |
| pip + venv | Geen lockfile, geen dependency groups, langzaam |
| Black + Flake8 + isort | Drie tools in plaats van één, significant langzamer dan Ruff |

## Consequences

- **Makkelijker:** Snelle iteratie met FastAPI + auto-docs, sterke type-safety met Pydantic + mypy, snelle tooling met uv + Ruff
- **Moeilijker:** SQLAlchemy 2.0 async heeft een leercurve, uv is relatief nieuw (maar snel mature)
- **Constraints:** Alle backend code moet Python 3.12+ zijn, async-first, type-checked met mypy --strict, geformat met Ruff
