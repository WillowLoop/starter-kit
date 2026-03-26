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

# Security Audit

Complete security audit orchestrator. Auto-detects app context, runs targeted scans, produces a consolidated report.

## When to use

- Full security review before production launch
- After major changes to auth, infrastructure, or dependencies
- Periodic security check
- Invoke with `/security-audit` or `/security-audit --quick`

## Modes

- **Standard mode** (`/security-audit`): Auto-detect + 2 intake questions + prioritized scans
- **Quick mode** (`/security-audit --quick`): Skip intake, run all scans with strictest defaults (assumes public app + PII)

---

## Phase 1 — Auto-Detect + Intake

### Auto-detect from codebase

Detect these automatically — do NOT ask the user:

1. **Auth method**: Read `backend/shared/auth/dependencies.py`
   - Look for: JWT tokens, OAuth flows, session-based auth, or stub/placeholder
   - Classify as: `stub` | `JWT` | `OAuth` | `session` | `none`

2. **Deploy target**: Read ADRs in `docs/architecture/adr/` + `docker-compose*.yml`
   - Look for: SSH deploy, Vercel, AWS, GCP, self-hosted indicators
   - Classify as: `self-hosted` | `vercel` | `cloud-managed` | `unknown`

3. **AI/LLM usage**: Grep for `openai|anthropic|langchain|llama` in `**/*.py` and `**/*.ts`
   - Classify as: `yes` (list libraries found) | `no`

4. **Framework versions**: Read `frontend/package.json` (Next.js version) + `backend/pyproject.toml` (FastAPI version)

### Present auto-detected context

```
## Detected App Context
- Auth: [method] (source: backend/shared/auth/dependencies.py)
- Deploy: [target] (source: ADR/compose files)
- AI/LLM: [yes/no] [libraries if yes]
- Next.js: [version] | FastAPI: [version]
```

### Intake questions (standard mode only)

Ask only these 2 questions — everything else was auto-detected:

1. **Data sensitivity?** What type of data does this app handle?
   - Options: PII (names, emails), Financial, Medical/Health, Public only
   - Default (quick mode): PII (most restrictive)

2. **Public or internal?** Is this app public-facing or internal only?
   - Options: Public, Internal
   - Default (quick mode): Public (most restrictive)

### Quick mode

If `--quick` flag is provided:
- Skip intake questions
- Use defaults: Public + PII (strictest scan profile)
- Run all 4 scans
- Proceed directly to Phase 2

---

## Phase 2 — Prioritization

Based on detected context + intake answers, determine scan priorities:

| Context | Impact |
|---|---|
| Public + PII/Financial/Medical | CRITICAL priority: code-scan + exposure-scan |
| Self-hosted deploy | HIGH priority: config-scan (Docker, headers, SSL) |
| AI/LLM integrations detected | HIGH priority: prompt injection in code-scan |
| Auth = stub/none | HIGH priority: auth review in config-scan |
| Internal + Public data only | MEDIUM priority: standard scan all areas |

### Present recommended scans

```
## Recommended Scans
Based on your app context, I recommend running these scans:

1. [CRITICAL] Code Scan — OWASP + AI security
2. [HIGH] Config Scan — Docker, headers, CORS
3. [HIGH] Exposure Scan — crawlers, PII in logs, endpoints
4. [MEDIUM] Deps Scan — vulnerabilities, licenses, Actions pinning

Run all? Or select specific scans (1-4):
```

In quick mode: skip this prompt, run all 4 scans.

---

## Phase 3 — Dispatch

Run selected scans **sequentially** (one at a time to manage context):

**Order**: code → config → exposure → deps

For each scan:
1. Read that scan's SKILL.md file
2. Follow the scan procedure defined in the SKILL.md
3. Collect findings with severity classifications
4. Present intermediate results before moving to next scan

### Scan dispatch

| Scan | Skill file |
|---|---|
| Code | `.claude/skills/security-code-scan/SKILL.md` |
| Config | `.claude/skills/security-config-scan/SKILL.md` |
| Exposure | `.claude/skills/security-exposure-scan/SKILL.md` |
| Deps | `.claude/skills/security-deps-scan/SKILL.md` |

---

## Phase 4 — Consolidated Report

After all scans complete, produce this report:

```markdown
# Security Audit Report

**Date**: [YYYY-MM-DD]
**Mode**: Standard / Quick
**App Context**:
- Auth: [method]
- Deploy: [target]
- AI/LLM: [yes/no]
- Data sensitivity: [level]
- Exposure: [public/internal]
- Next.js: [version] | FastAPI: [version]

## Executive Summary

| Severity | Count |
|---|---|
| Critical | N |
| High | N |
| Medium | N |
| Low | N |
| Info | N |

**Overall risk**: [LOW / MEDIUM / HIGH / CRITICAL]

## Critical & High Findings

[Each finding with full details and remediation steps]

### [CRITICAL] Finding title
- **Scan**: code / config / exposure / deps
- **Category**: specific category
- **Location**: `file:line`
- **Description**: what was found
- **Remediation**: how to fix, with code examples where applicable

## Medium & Low Findings

[Each finding with details]

## What's Already Good

[PASS items worth noting — highlights of existing security measures]

Examples from this project:
- OpenAPI disabled in production ✓
- Docker non-root user ✓
- Generic error messages ✓
- Rate limiting configured ✓
- Security headers present ✓

## Recommended Next Steps

[Prioritized action items, ordered by severity and effort]

1. **[CRITICAL]** Fix X — estimated effort: small/medium/large
2. **[HIGH]** Address Y — estimated effort: small/medium/large
3. ...
```

### Save report

After presenting the report, offer to save it:

```
Save this report to docs/security/audit-YYYY-MM-DD.md? (y/n)
```

If yes:
- Create `docs/security/` directory if it doesn't exist
- Save the full report as markdown
