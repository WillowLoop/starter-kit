---
name: security-deps-scan
description: >-
  Audit dependency security and supply chain integrity: vulnerability scanning,
  license compatibility, lockfile integrity, and GitHub Actions version pinning.
  Use for dependency reviews, before releases, or when security-audit dispatches
  a deps scan. Covers frontend (pnpm), backend (uv/pip), and CI workflows.
---

# Security Dependencies Scan

Audit dependency security and supply chain integrity.

## When to use

- Before releases
- After adding new dependencies
- When `security-audit` dispatches a deps scan
- Standalone: `/security-deps-scan`

## Differentiation with CI

The `security.yml` CI workflow runs npm-audit, pip-audit, and Trivy automatically. This skill adds:

- **Interactive triage** — context and remediation guidance for each finding
- **License analysis** — not covered by CI
- **Supply chain review** — not covered by CI
- **GitHub Actions pinning audit** — not covered by CI

## Prerequisite check

Before running scans, verify tool availability:

### Step 0: Prerequisites

1. Check if `node_modules/` exists in `frontend/`
   - If not: advise running `pnpm install` first, or fall back to lockfile-only analysis
2. Check if `.venv/` exists in `backend/`
   - If not: advise running `make setup` first, or fall back to lockfile-only analysis
3. If tools are not available: **use fallback mode** (lockfile analysis + Grep-only)

### Fallback mode

When `pnpm` or `uv` are not available or `node_modules`/`.venv` don't exist:

- Parse `pnpm-lock.yaml` for frontend dependency versions
- Parse `uv.lock` for backend dependency versions
- Check GitHub Actions pinning via Grep (always works)
- Skip `pnpm audit`, `pip-audit`, `pnpm licenses`, `pnpm outdated`
- Note in report which checks were skipped and why

## Scan procedure

### Step 1: Frontend Vulnerability Audit

```bash
cd frontend && pnpm audit --audit-level=moderate
```

Parse output for:
- Total vulnerabilities by severity (critical, high, moderate, low)
- Affected packages and paths
- Available fixes (`pnpm audit --fix` applicability)

If pnpm audit fails or is unavailable, note as SKIPPED.

### Step 2: Backend Vulnerability Audit

```bash
cd backend && uv run pip-audit
```

Parse output for:
- Vulnerable packages with CVE IDs
- Severity ratings
- Fixed versions available

If pip-audit fails or is unavailable, note as SKIPPED.

### Step 3: Lockfile Integrity

Check that lockfiles exist and are committed:

```
Glob: frontend/pnpm-lock.yaml, backend/uv.lock
```

- FAIL if lockfile does not exist
- WARN if lockfile exists but is not committed (check git status)
- PASS if lockfile exists and is committed

### Step 4: GitHub Actions SHA Pinning

```
Grep for: uses: in .github/workflows/*.yml
```

For each `uses:` directive:
- FAIL if using mutable tag: `@v4`, `@main`, `@latest`, `@master`
- PASS if using SHA pin: `@abc123...` (40-char hex)
- List all unpinned actions with their current tags

**Why this matters**: Mutable tags can be moved to point to malicious code. SHA pinning ensures you run exactly the code you audited.

### Step 5: License Check

```bash
cd frontend && pnpm licenses list
```

Or manually check `package.json` dependencies.

Flag licenses:
- FAIL: AGPL — requires source disclosure for network use
- WARN: GPL — copyleft, may require source disclosure
- WARN: SSPL — restrictive for SaaS
- INFO: MIT, Apache-2.0, BSD, ISC — permissive, no concerns

### Step 6: Outdated Packages

```bash
cd frontend && pnpm outdated
cd backend && uv pip list --outdated
```

- WARN for packages more than 2 major versions behind
- INFO for packages with available minor/patch updates
- Focus on security-relevant packages (auth, crypto, http clients)

### Step 7: Supply Chain Advisory

Manual review guidance:
- Check for typosquatting: packages with names similar to popular packages
- Check for low-popularity packages in critical paths (auth, crypto)
- Verify package maintainers are reputable
- Check if any package was recently transferred to a new owner

This step is advisory — provide guidance for manual review rather than automated checks.

## Severity classification

| Severity | Criteria |
|---|---|
| CRITICAL | Known exploited vulnerability (KEV), no auth required |
| HIGH | High CVSS vulnerability with available exploit |
| MEDIUM | Moderate vulnerability or license concern |
| LOW | Low severity vulnerability or outdated package |
| INFO | Observation, supply chain advisory |

## Output format

```markdown
## Dependencies Security Scan Results

### Summary
- Critical: N | High: N | Medium: N | Low: N | Info: N

### Prerequisites
- Frontend (pnpm): available / fallback mode
- Backend (uv): available / fallback mode

### Findings

#### [SEVERITY] Finding title
- **Package**: name@version
- **Category**: Vulnerability / License / Lockfile / Actions Pinning / Supply Chain
- **CVE**: CVE-XXXX-XXXXX (if applicable)
- **Description**: What was found
- **Fix**: How to remediate

### GitHub Actions Pinning
| Action | Current | Status |
|---|---|---|
| actions/checkout | @v4 | FAIL — use SHA |
| ... | ... | ... |

### License Summary
| License | Count | Status |
|---|---|---|
| MIT | N | OK |
| Apache-2.0 | N | OK |
| ... | ... | ... |

### Scan Coverage
- Frontend packages: N
- Backend packages: N
- GitHub Actions: N
- Checks skipped: [list if any]
```
