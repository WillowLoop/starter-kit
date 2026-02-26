# Plan: Rebase en merge docs/translate-to-english naar main

## Context

Branch `docs/translate-to-english` bevat 1 commit (`7ff3abf`) die 30 bestanden raakt — vertalingen naar Engels, nieuwe ADRs, templates en READMEs. De branch mist 8 commits die op `main` staan. Er zijn ~9 merge conflicts verwacht bij rebase.

## Steps

### 1. Voorbereiding

```bash
git stash --include-untracked -m "WIP: plan files"    # dirty working tree opruimen
git branch translate-backup docs/translate-to-english  # backup voor rollback
```

### 2. Rebase op main

```bash
git checkout docs/translate-to-english
git rebase main
```

### 3. Conflict resolution (per bestand)

| # | Bestand | Strategie |
|---|---------|-----------|
| 1 | `CLAUDE.md` | Engelse vertaling van translate, maar **behoud `make setup`** (niet `make hooks`) en **behoud `release-please-config.json`** referentie uit main. Neem CI/CD sectie mee als die op main staat. |
| 2 | `.pre-commit-config.yaml` | **Gebruik main's versie** (51 regels, superset met `frontend-lint` + `conventional-pre-commit` hooks). Translate's versie is incompleet. |
| 3 | `scripts/init-project.sh` | **Gebruik translate's versie** (216 regels, robuuster: prerequisite checks, confirmation, self-deletion). Main's 54-regels versie is een simplificatie. |
| 4 | `backend/CLAUDE.md` | **Merge beide**: Engelse tekst van translate + structurele info van main (httpx testing, directory layout). |
| 5 | `README.md` | **Gebruik translate's versie** (Engels, uitgebreider). |
| 6 | `docs/README.md` | **Merge**: Engelse structuur van translate + nieuwe secties van main (PRD, Design Docs, bootstrap checklist). |
| 7 | `docs/architecture/c4/containers.md` | **Merge**: Engelse tekst van translate + deployment details van main (Vercel, Coolify). Next.js 16. |
| 8 | `docs/architecture/adr/0001-frontend-tech-stack.md` | **Merge**: Engelse vertaling + Next.js 16 versie-update uit main. |
| 9 | `.github/workflows/security.yml` | **Gebruik main's versie** (functioneel, geen vertaalbare content). |

Na elk bestand: `git add <file>`, daarna `git rebase --continue`.

### 4. Merge in main (fast-forward)

```bash
git checkout main
git merge docs/translate-to-english
```

### 5. Push en opruimen

```bash
git push origin main
git branch -d docs/translate-to-english
git branch -d translate-backup
git stash pop  # WIP plan files terugzetten
```

## Verification

```bash
git log --oneline -5                    # vertaalcommit bovenop main
git diff main~1..main --stat            # alleen vertaal-wijzigingen
grep "make setup" CLAUDE.md             # functionele fix behouden
grep "frontend-lint" .pre-commit-config.yaml  # hook behouden
git status                              # clean tree (behalve unstashed plan files)
```
