# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/verify-loop.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Full integration verification loop with browser testing, auto-planning, and staff engineer review
---

# Verify Loop Workflow

Volledige verificatie van frontend + backend met browser testing (agent-browser of Playwright) en automatische fix loop.

## Overview

```
SETUP & VERIFY → FAIL? → PLAN FIX → STAFF REVIEW → IMPLEMENT → LOOP
      ↑                                                          │
      └──────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
/verify-loop
## Acceptance Criteria

### Backend
- [ ] **API1**: GET /api/users returns 200

### Frontend
- [ ] **UI1**: [BROWSER] Login page has email and password inputs
- [ ] **UI2**: [BROWSER] Valid login redirects to /dashboard
```

## Phase 0: Browser Engine Selection

**Skip if** `.claude/verify-loop.yml` contains `browser-engine`.
**Skip if** no `[BROWSER]` criteria in the acceptance criteria.

Otherwise, ask:

```
AskUserQuestion:
  question: "Which browser engine for [BROWSER] verification?"
  options:
  - agent-browser (Recommended) — AI-optimized CLI with accessibility snapshots (Vercel Labs)
  - Playwright — Programmatic test framework with TypeScript test files
```

Store in `.claude/verify-loop.yml` under `browser-engine` (config, not cache).

**Non-interactive/CI default:** playwright (preserves current behavior).

---

## Criterion Types

| Prefix | Verification Method |
|--------|---------------------|
| `GET/POST/...` | HTTP request (curl) |
| `[BROWSER]` | Browser test (agent-browser or Playwright, per Phase 0 selection) |
| `[CLI]` | Command execution (30s timeout) |
| `[MANUAL]` | Skip, list in report |

---

## Phase 1: SETUP & VERIFY

### 1.1 Port Check

```
Check if ports in use (default: 3000, 8000)
If occupied:
  → Interactive: "Port 3000 in use by [process]. Kill? [y/n]"
  → Non-interactive: Fail with message
```

### 1.2 Browser Engine Check

**If playwright** (or no `[BROWSER]` criteria):

```
Run: npx playwright --version

If missing:
  → Interactive: "Playwright not installed. Install now? [y/n]"
    → If yes: npx playwright install
  → CI/Non-interactive: Fail with:
    "Playwright required. Run: npx playwright install"
```

**If agent-browser:**

```
Run: which agent-browser

If missing:
  → Interactive: "agent-browser not installed. Install now? [y/n]"
    → If yes: npm install -g agent-browser && agent-browser install
  → CI/Non-interactive: Fail with:
    "agent-browser required. Run: npm install -g agent-browser && agent-browser install"
```

### 1.3 Service Detection & Start

Auto-detect start commands by checking project files:

| Check | Detected Command |
|-------|------------------|
| `package.json` has `dev` script | `npm run dev` |
| `pyproject.toml` or `main.py` | `uvicorn main:app --reload` |
| `Cargo.toml` | `cargo run` |
| `docker-compose.yml` | `docker-compose up` |

**First run behavior:**
```
Detected:
  Backend: uvicorn main:app --port 8000
  Frontend: npm run dev

Proceed with these? [y/n/edit]
```

Cache detection in `.claude/verify-loop-cache.json` for subsequent runs.

**Timeouts:**
- Startup timeout: 60 seconds (process must start)
- Health timeout: 30 seconds (health endpoint must respond)
- Health poll interval: 2 seconds

### 1.4 Health Check

Poll health endpoints until responding:

```
Default endpoints tried in order:
  Backend: /health, /api/health, /healthz, /
  Frontend: /, /index.html

Success: HTTP 200 response
Failure after 30s: "Health check failed for backend at http://localhost:8000/health"
```

### 1.5 Run Verification Checks

**Check order:** HTTP → Browser → CLI (fast to slow)

HTTP and CLI criteria are always verified by the main verification agent.
`[BROWSER]` criteria are routed based on the browser engine selection from Phase 0.

#### [BROWSER] Criteria — agent-browser path (delegate to verify-acceptance)

**Only when `browser-engine: agent-browser`.**

verify-loop parses `[BROWSER]` criteria and converts them to structured format before passing to the subagent:

```
Input (verify-loop format):
  - [ ] **UI1**: [BROWSER] Login page has email and password inputs
  - [ ] **UI2**: [BROWSER] Valid login redirects to /dashboard

Converted to structured format for subagent:
  - id: UI1
    route: /login (inferred or ask)
    verify: "Login page has email and password inputs"
  - id: UI2
    route: /login
    verify: "Valid login redirects to /dashboard"
```

If a route cannot be inferred from the criterion, ask the user.

Spawn a subagent for browser verification:

```
Task tool parameters:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: |
    You are a browser verification agent using agent-browser.

    Read the agent-browser command reference at:
    ${PROJECT_ROOT}/setup/skills/skills-dev-workflows/verify-acceptance/references/agent-browser-ref.md

    The dev server is already running at http://localhost:${PORT}.

    ## Your job:
    1. For each criterion below, navigate to the route using agent-browser
    2. Take an accessibility snapshot and screenshot as evidence
    3. Evaluate whether the criterion passes or fails
    4. For interaction criteria: use element references (@eN) from snapshots
    5. If you hit a connection error, report it as a test failure (do NOT restart the server)

    ## Criteria to verify:
    ${STRUCTURED_BROWSER_CRITERIA}

    ## Return results in this exact format:

    ## Browser Verification Report

    ### Summary
    Total: X | Passed: X | Failed: X | Skipped: X

    ### Results

    #### PASSED
    - [x] **UI1**: Login page has email and password inputs ✓ (found email input @e3, password input @e5)

    #### FAILED
    - [ ] **UI2**: Valid login redirects to /dashboard ✗
      - Expected: Redirect to /dashboard after login
      - Actual: Stayed on /login
      - Screenshot: /tmp/agent-browser-verify/evidence-UI2.png
      - Snapshot: /tmp/agent-browser-verify/snapshot-UI2.txt
      - Root cause: [analysis]

    #### SKIPPED
    (any that could not be tested)

    ### Verdict: [PASSED / FAILED]
```

**Merge results:** Combine browser verification report with HTTP/CLI results into the unified report. Phase 2 works unchanged.

#### [BROWSER] Criteria — Playwright path

**When `browser-engine: playwright` (default) or no `[BROWSER]` criteria.**

Use Task tool to spawn verification agent:

```
Task tool parameters:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: [Verification Agent Prompt - see below]
```

#### Verification Agent Prompt (Playwright path)

```
You are an integration verification agent with browser testing capabilities.

## Acceptance Criteria:
[INSERT CRITERIA FROM USER INPUT]

## Previous Results (if iteration > 1):
[INSERT PREVIOUS RESULTS FOR REGRESSION DETECTION]

## Instructions:

### HTTP Criteria (GET/POST/etc.)
Use curl to test. Capture status, headers, body.

### [BROWSER] Criteria
For each browser criterion:

1. Create Playwright test in /tmp/playwright-verify/:

```typescript
import { test, expect } from '@playwright/test';

test('[criterion ID]: [description]', async ({ page }) => {
  await page.goto('http://localhost:3000/path');
  // Verify based on criterion
  await expect(page.locator('selector')).toBeVisible();
});
```

2. Run: npx playwright test /tmp/playwright-verify/ --reporter=json
3. Capture screenshots on failure

### [CLI] Criteria
Execute with 30s timeout. Capture stdout, stderr, exit code.

### [MANUAL] Criteria
Skip, but list in report.

## Output Format:

## Verification Report

### Summary
Total: X | Passed: X | Failed: X | Skipped: X

### Results

#### PASSED
- [x] **API1**: GET /api/users ✓ (200, 5 users returned)

#### FAILED
- [ ] **UI2**: [BROWSER] Login redirect ✗
  - Expected: Redirect to /dashboard
  - Actual: Stayed on /login
  - Screenshot: /tmp/playwright-verify/failure-UI2.png
  - Root cause: [analysis]
  - Suggested fix: [specific change]

#### REGRESSION (if any)
- [ ] **UI1**: Was PASS in iteration 1, now FAIL
  - This likely broke due to: [analysis]

#### SKIPPED (Manual)
- [ ] **MANUAL1**: Visual design check

### Verdict: [PASSED / FAILED]
```

---

## Phase 2: PLAN FIX (on failure)

**Only runs if Phase 1 verdict is FAILED.**

### 2.1 Stop Services

Stop backend and frontend to save resources during planning.

### 2.2 Log Evidence

Save to `.claude/verify-loop-logs/session-{timestamp}/iteration-{n}.md`:
- Full verification report
- All failure evidence
- Screenshots referenced

### 2.3 Create Fix Plan

Based on verification report, create fix plan:

```markdown
## Fix Plan - Iteration {n}

### Failed Criteria
[List with evidence]

### Regressions (if any)
[List with context: "This passed before, broke after fix X"]

### Root Cause Analysis
[From verification agent]

### Proposed Fixes

#### Fix 1: [File] - [Description]
```diff
- old code
+ new code
```

#### Fix 2: ...

### Files Affected
- src/components/Login.tsx
- src/api/auth.ts
```

---

## Phase 3: STAFF REVIEW

### 3.1 Submit for Review

Use Task tool:

```
Task tool parameters:
  subagent_type: "general-purpose"
  model: "opus"
  prompt: [Staff Engineer Review Prompt - see below]
```

#### Staff Engineer Review Prompt

```
You are a senior staff engineer reviewing a fix plan for failing integration tests.

## Context
- Iteration: {n} of max 3
- Previous fixes: [summary if any]

## Verification Report (what failed):
[INSERT REPORT]

## Proposed Fix Plan:
[INSERT PLAN]

## Review With Skepticism

1. Does the fix address ROOT CAUSE, not symptoms?
2. Could this fix break other tests? (check regressions)
3. Is the fix minimal and targeted?
4. Are there edge cases not considered?

## Output

### Summary
[One paragraph]

### Critical Issues (MUST FIX)
- [ ] Issue

### Concerns
- [ ] Concern

### Verdict
**[APPROVED / NEEDS REVISION]**

[Explanation]
```

### 3.2 Handle Verdict

**APPROVED:** Continue to Phase 4

**NEEDS REVISION:**
1. Main Claude revises fix plan based on feedback
2. Resubmit to staff engineer
3. Max 2 review iterations per fix cycle

**After 2 rejections:**
```
Staff engineer rejected fix plan twice.

Latest feedback:
[feedback]

Options:
1. Proceed anyway with current plan
2. Stop and investigate manually

Choice? [1/2]
```

### 3.3 Restart Services

After approval, restart backend and frontend for implementation.

---

## Phase 4: IMPLEMENT & LOOP

### 4.1 Apply Fixes

**Default (interactive):**
```
Fix 1: Update Login.tsx - Add redirect after auth

Apply this fix? [yes/skip/stop]
```

**With --auto-fix flag:**
Apply all fixes without prompts.

### 4.2 Check Iteration Count

```
If iteration >= 3:
  → Stop workflow
  → Report: "Max iterations (3) reached"
  → Show summary of all iterations
  → Suggest: "/debug [specific failing criterion]"
  → Do NOT auto-chain to /debug
```

### 4.3 Loop Back

Return to Phase 1 with same acceptance criteria.

### 4.4 Cleanup (on exit)

**Always runs on:**
- Success (all criteria pass)
- Max iterations reached
- User stops workflow
- Error/interrupt

**Cleanup actions:**
1. Kill backend process (and children)
2. Kill frontend process (and children)
3. If Playwright: Remove /tmp/playwright-verify/
4. If agent-browser: Run `agent-browser close`, remove /tmp/agent-browser-verify/
5. Keep .claude/verify-loop-logs/ for reference

---

## Configuration

### Zero Config (Default)

Works without configuration file:
- Auto-detects start commands
- Uses default ports (3000, 8000)
- Uses default timeouts (60s startup, 30s health)

### Optional: `.claude/verify-loop.yml`

Only create if defaults don't work:

```yaml
browser-engine: agent-browser  # or: playwright (default: playwright)
# Note: auth credentials for agent-browser testing live in .claude/verify.yml
# (see verify-acceptance skill docs)

backend:
  start: "custom start command"
  port: 8000
  health: "/custom/health"

frontend:
  start: "custom start command"
  port: 3000
  health: "/"

timeouts:
  startup: 60      # seconds
  health: 30       # seconds

max-iterations: 3
auto-fix: false
```

---

## Comparison with /verify-integration

| Aspect | /verify-integration | /verify-loop |
|--------|---------------------|--------------|
| Browser testing | No | Yes (agent-browser or Playwright) |
| Fix approach | User approves suggestions | Full fix plan + staff review |
| Iteration | Manual re-run | Automatic loop |
| Staff review | No | Yes |
| Use case | Quick API checks | Full frontend+backend validation |

---

## Rules

1. **Max 3 fix iterations** - After 3, stop and suggest /debug
2. **Max 2 review iterations per fix** - After 2 rejections, ask user
3. **Regressions are failures** - Include in next fix plan with context
4. **No auto-revert** - Regressions go through normal fix cycle
5. **Always cleanup** - Kill processes on any exit
6. **User approval default** - --auto-fix is opt-in
7. **Log everything** - Evidence saved to .claude/verify-loop-logs/
