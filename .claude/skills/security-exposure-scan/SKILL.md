---
name: security-exposure-scan
description: >-
  Scan for external exposure and privacy risks: search engine and AI crawler
  indexation control (robots.txt, meta robots), PII in logs, API endpoint
  inventory, source maps, error leakage, open redirects, and license
  compliance. Use before production launch, for privacy audits, or when
  security-audit dispatches an exposure scan.
---

# Security Exposure Scan

Scan for external exposure and privacy risks.

## When to use

- Before production launch
- Privacy compliance audits
- When `security-audit` dispatches an exposure scan
- Standalone: `/security-exposure-scan`

## Known-good patterns (do NOT flag)

These patterns are already implemented correctly in this project:

- Source maps disabled in production (`productionBrowserSourceMaps` not enabled) ✓
- Generic error messages in exception handlers ✓
- Sentry `send_default_pii=False` ✓

When scanning, verify these are still in place and report as PASS.

## Scan procedure

### Step 1: robots.txt

Check if `frontend/public/robots.txt` exists.

- FAIL if file does not exist — search engines will index everything by default
- If exists: read contents and proceed to Step 2

### Step 2: AI Crawler Blocking

If robots.txt exists, check against `references/crawler-blocking.md`.

- WARN if known AI crawlers are not blocked (GPTBot, CCBot, etc.)
- INFO if robots.txt exists but only has basic rules
- PASS if comprehensive AI crawler blocking is configured

### Step 3: Sitemap Audit

Check if `frontend/public/sitemap.xml` exists.

- WARN if sitemap includes admin, internal, or authenticated routes
- PASS if sitemap only includes public pages
- INFO if no sitemap exists

### Step 4: PII in Logs

```
Grep for: password=|secret=|credit_card=|ssn=|social_security in backend/**/*.py
```

Specifically check inside logging/structlog calls:
- FAIL if PII fields are logged with their values
- PASS if sensitive fields are masked or excluded from logs
- Note: Do not flag generic words like `token` or `key` in log context — only flag explicit PII patterns

### Step 5: API Endpoint Inventory

Read all router files in `backend/app/` to build an endpoint inventory:

```
Glob: backend/app/**/router*.py, backend/app/**/routes*.py
```

For each endpoint, document:
- HTTP method and path
- Auth requirement (has `Depends(get_current_user)` or similar)
- WARN for any endpoint without auth that isn't in the public whitelist

### Step 6: Source Maps

Read `frontend/next.config.ts`.

- FAIL if `productionBrowserSourceMaps: true` — exposes source code
- PASS if not set or set to false

### Step 7: Error Message Leakage

Check exception handlers in:
- `backend/app/main.py` — global exception handlers
- `backend/shared/middleware/` — middleware error handling

- FAIL if stack traces or internal details returned in HTTP responses
- PASS if generic error messages returned

### Step 8: Open Redirects

```
Grep for: redirect(|RedirectResponse( in backend/**/*.py and frontend/src/**/*.ts
```

- FAIL if redirect target comes from user input without validation
- PASS if redirects use hardcoded paths or validated allowlists

### Step 9: License Compliance

Cross-reference with `security-deps-scan` output if available.

- WARN if any dependency uses AGPL, GPL, or other copyleft license in a proprietary project
- INFO listing all unique licenses found

### Step 10: next/image Remote Patterns

Read `frontend/next.config.ts` image configuration.

- FAIL if `hostname: '**'` or wildcard patterns allow arbitrary image sources
- PASS if only specific, trusted domains are listed

## Severity classification

| Severity | Criteria |
|---|---|
| CRITICAL | Sensitive data actively exposed to public |
| HIGH | Significant exposure risk requiring immediate action |
| MEDIUM | Exposure risk that should be addressed |
| LOW | Best practice for reducing exposure surface |
| INFO | Observation, documented for awareness |

## Output format

```markdown
## Exposure Security Scan Results

### Summary
- Critical: N | High: N | Medium: N | Low: N | Info: N

### Findings

#### [SEVERITY] Finding title
- **Category**: Crawlers / PII / Endpoints / Source Maps / Errors / Redirects / Licenses / Images
- **Location**: `file:line` or system-level
- **Description**: What was found
- **Remediation**: How to fix

### API Endpoint Inventory
| Method | Path | Auth | Notes |
|---|---|---|---|
| GET | /health | No | Expected public |
| ... | ... | ... | ... |

### Known-Good Patterns Verified
- [List of patterns checked and confirmed in place]

### Scan Coverage
- Files scanned: N
- Categories audited: 10
```

## References

- `references/crawler-blocking.md` — robots.txt + AI crawlers reference
