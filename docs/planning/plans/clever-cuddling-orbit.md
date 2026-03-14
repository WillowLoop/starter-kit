# Plan: Bugfixes in Starter-Kit sync-upstream

## Context

Bij de audit van de administratie-app tegen de starter-kit zijn twee bugs en een manifest-probleem gevonden in het net gebouwde sync-upstream mechanisme. Deze moeten gefixt worden voordat sync naar downstream projecten (zoals administratie) betrouwbaar werkt.

---

## Bug 1: Bootstrap "already up to date" — `scripts/sync-upstream.sh:152-154`

**Probleem:** `do_init()` zet `last_synced_commit` op `HEAD` van de starter-kit remote. Als je daarna `sync` draait, vergelijkt het `last_synced..target` — die zijn identiek → "Already up to date" (regel 232). De eerste sync kan nooit wijzigingen tonen.

**Fix:** In `do_init()`, gebruik de **root commit** van de starter-kit i.p.v. HEAD:
```bash
# Regel 152-154 veranderen van:
head_sha=$(git rev-parse "${REMOTE_NAME}/${DEFAULT_BRANCH}")

# Naar:
# Root commit zodat eerste sync ALLE shared file wijzigingen toont
head_sha=$(git rev-list --max-parents=0 "${REMOTE_NAME}/${DEFAULT_BRANCH}" | head -1)
```

**Waarom `head -1`:** `git rev-list --max-parents=0` output root commits in reverse chronologische volgorde. `head -1` pakt de meest recente root (in een normale repo de enige). Veiliger dan `tail -1` bij multiple roots (bv. na `--allow-unrelated-histories` merge).

**Bestand:** `scripts/sync-upstream.sh` regels 152-154

---

## ~~Bug 2~~: init-project.sh SHA — GEEN BUG

Na staff review: `init-project.sh` gebruikt `git rev-parse HEAD` correct. De SHA wordt resolvable na `git fetch starter-kit` in het downstream project. Root-commit zou juist slechter zijn — het zou een diff tonen van ALLE wijzigingen sinds de eerste commit, inclusief wijzigingen die het project al heeft.

**Geen wijziging nodig.**

---

## Manifest fix: `.pre-commit-config.yaml` en `.gitignore` naar merge — `.starter-kit-files`

**Probleem:** Beide staan als `overwrite`. Bij sync naar een downstream project:
- `.pre-commit-config.yaml` overwrite verwijdert project-specifieke hooks (bv. financial doc blocking in administratie — ADR-0008 security)
- `.gitignore` overwrite verwijdert project-specifieke exclusions (bv. financial data dirs, API tokens, PII)

Dit is geen edge case — **elk** downstream project zal eigen entries in deze bestanden hebben.

**Fix:** Verander in `.starter-kit-files`:
```
# Van:
overwrite .pre-commit-config.yaml
overwrite .gitignore

# Naar:
merge .pre-commit-config.yaml
merge .gitignore
```

**Bestand:** `.starter-kit-files` regels 18 en 33

---

## Bug 3: `overwrite .claude/skills/` vernietigt project-specifieke skills — `.starter-kit-files`

**Probleem:** Het sync-script verwijdert lokale bestanden in overwrite-directories die niet in upstream bestaan (regels 382-395). De administratie-app heeft 35+ project-specifieke skills onder `.claude/skills/project-specific/administratie/`. Een sync zou die allemaal verwijderen. Maar ook individueel per directory opsplitsen is niet veilig — projecten kunnen generic skills customizen (bv. `design-system/` met eigen tokens).

**Fix:** Verander `overwrite .claude/skills/` naar `merge .claude/skills/`. Merge-logica:
- **Nieuwe** skill files van upstream worden toegevoegd
- **Gewijzigde** skills krijgen 3-way merge (project-aanpassingen behouden)
- **Project-specifieke** skills die niet in upstream bestaan worden **niet verwijderd** (merge delete nooit)
- **Hernoemde/verwijderde** skills in upstream worden niet opgeruimd (acceptabel tradeoff — zichtbaar in PR)

**Bestand:** `.starter-kit-files` — regel met `overwrite .claude/skills/`

---

## Bug 4: Shell injection in `validate_yaml` — `scripts/sync-upstream.sh:87`

**Probleem:** De YAML-validatie gebruikt onge-quote `$file` in een Python string:
```bash
python3 -c "import yaml; yaml.safe_load(open('$file'))"
```
Als een bestandsnaam een single quote bevat, breekt dit. Geen security-risico (paden komen uit git), maar wel een correctheid-bug.

**Fix:**
```bash
python3 -c "import yaml, sys; yaml.safe_load(open(sys.argv[1]))" "$file"
```

**Bestand:** `scripts/sync-upstream.sh` regel 87

---

## Bestanden overzicht

| Bestand | Wijziging |
|---------|-----------|
| `scripts/sync-upstream.sh` | `do_init()`: root commit i.p.v. HEAD; `validate_yaml`: fix shell injection |
| `.starter-kit-files` | `.pre-commit-config.yaml`, `.gitignore`, `.claude/skills/` → merge |

**2 bestanden, 4 wijzigingen.** (`init-project.sh` niet meer nodig na review.)

---

## Verificatie

```bash
# 1. Bootstrap-bug: init moet root commit gebruiken
cd /tmp && mkdir test-sync && cd test-sync && git init && git commit --allow-empty -m "init"
git remote add starter-kit /Users/cheersrijneau/Developer/dev_standards/starter-kit
git fetch starter-kit
cp /Users/cheersrijneau/Developer/dev_standards/starter-kit/scripts/sync-upstream.sh .
chmod +x sync-upstream.sh
./sync-upstream.sh --init
# Verifieer: last_synced_commit in .starter-kit.yml is root commit (niet HEAD)
grep last_synced_commit .starter-kit.yml
git rev-list --max-parents=0 starter-kit/main | head -1  # moet matchen

# 2. Sync na init: moet wijzigingen tonen
./sync-upstream.sh --dry-run
# Moet NIET "Already up to date" zeggen

# 3. Manifest: merge strategie
./sync-upstream.sh --dry-run 2>&1 | grep -E '\[(merge|overwrite)\]'
# .pre-commit-config.yaml → [merge]
# .gitignore → [merge]
# .claude/skills/ bestanden → [merge]

# 4. Cleanup
cd / && rm -rf /tmp/test-sync
```
