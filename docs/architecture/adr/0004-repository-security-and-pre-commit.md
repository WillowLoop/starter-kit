# ADR-0004: Repository Security and Pre-commit Hooks

- **Status**: accepted
- **C4 Level**: L2-Container
- **Scope**: monorepo (frontend + backend)
- **Date**: 2026-02-15

## Context

In a full-stack monorepo with pydantic-settings configuration, multiple risks for accidental data leakage exist:

1. **Credentials in code** — default values in `Settings` with real API keys, tokens or business data
2. **Sensitive files** — customer data, financial documents or exports accidentally committed
3. **Config drift** — new `Settings` fields without a corresponding `.env.example` entry, causing developers to miss that a new variable is needed after a pull
4. **Private keys** — SSH/TLS keys ending up in the repository

Manual reviews catch this inconsistently. An automated gate on every commit prevents these mistakes from reaching the repository.

## Decision

Pre-commit hooks as a mandatory gate on every commit, installed via `uv tool install pre-commit` + `make hooks`.

Hooks:

| Hook | Source | Purpose |
|------|--------|---------|
| `check-added-large-files` (max 500KB) | pre-commit-hooks | Block binaries and data dumps |
| `detect-private-key` | pre-commit-hooks | Block SSH/TLS private keys |
| `ruff` + `ruff-format` | ruff-pre-commit | Lint + format Python code |
| `env-example-sync` | local script | Verify that all `Settings` fields exist in `.env.example` |
| `no-sensitive-data` | `language: fail` | Block files in `backend/data/` |

Additional rules:
- `backend/data/` is in `.gitignore` for runtime data (uploads, exports)
- `Settings` fields without a default are required via `.env` — no real values as defaults
- `known-first-party` in ruff isort config so imports sort correctly from project root

## Reasoning Chain

- Credentials and data in git are hard to remove (git history) → prevention is better than detection
- Pre-commit runs locally and blocks before the commit → fastest feedback loop, no CI dependency
- `env-example-sync` as Python script instead of bash → more robust for edge cases (properties, `model_config`, computed fields)
- `language: fail` for data files → zero-config, no regex false positives, clear error message
- Ruff in pre-commit instead of only in Makefile → enforceable, not optional

## Alternatives Considered

| Alternative | Why rejected |
|---|---|
| `detect-secrets` (Yelp) | High false-positive rate on `.env.example` placeholders and test fixtures |
| CI-only checks (GitHub Actions) | Too late — credentials are already in git history by then |
| Husky (Node-based hooks) | Extra Node dependency for Python checks; pre-commit is language-agnostic |
| `pre-commit` as backend dependency | Repo-level tool, not backend-specific; `uv tool install` keeps it separate |

## Consequences

- Developers must run `make hooks` once after clone
- New `Settings` fields always require a `.env.example` update — commit fails otherwise
- Ruff errors in changed files must be resolved before commit
- Large files (>500KB) cannot be committed without bypassing the hook
- Pre-commit hooks are local and can be bypassed with `--no-verify` — this is acceptable for a solo/small-team setup where CI serves as a second layer
