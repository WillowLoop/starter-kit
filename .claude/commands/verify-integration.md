# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/verify-integration.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: Verify implementation against acceptance criteria with fix loop (supports HTTP and CLI)
---

# Integration Verification Workflow

## Input Handling

$ARGUMENTS can be:
- Path to a file containing the plan (if file exists)
- Inline text with acceptance criteria

Detection: Check if $ARGUMENTS is a valid file path that exists. If yes, read file. Otherwise, treat as inline text.

## Acceptance Criteria Format

Each criterion can specify its verification type:

```markdown
## Acceptance Criteria

# HTTP verification (default)
- [ ] **AC1**: GET /api/users returns 200
- [ ] **AC2**: POST /api/login returns {"token": ...}

# CLI verification (prefix with [CLI])
- [ ] **AC3**: [CLI] `mycli --version` outputs "1.0"
- [ ] **AC4**: [CLI] `mycli build` exits with code 0
- [ ] **AC5**: [CLI] `mycli invalid` exits with code 1

# Manual verification (prefix with [MANUAL])
- [ ] **AC6**: [MANUAL] UI renders correctly
```

### Type Detection Priority

1. `[CLI]` prefix → CLI verification
2. `[MANUAL]` prefix → Skip (requires manual check)
3. HTTP method (GET/POST/etc.) → HTTP verification
4. `verify.yml` default → Use project default
5. No match → HTTP verification

### CLI Syntax

```markdown
# Check command output contains string
- [ ] **AC1**: [CLI] `command args` outputs "expected string"

# Check command exit code
- [ ] **AC2**: [CLI] `command args` exits with code 0
```

## Project Configuration (Optional)

Create `.claude/verify.yml` for project-specific settings:

```yaml
# CLI-only project (no app to start)
type: cli

# Custom start command
start: docker-compose up -d && npm run dev
port: 3000

# Setup commands (run before starting app)
setup:
  - npm run db:migrate
  - npm run db:seed
```

## Phase 1: Verification

Use the Task tool with:
- subagent_type: "general-purpose"
- model: "opus"
- prompt: |
    You are an integration verification agent.

    ## Plan/Requirements:

    $ARGUMENTS

    ## Instructions:
    1. Check for .claude/verify.yml configuration
    2. Parse acceptance criteria (detect type per criterion)
    3. Run setup commands if configured
    4. Start app (unless type: cli)
    5. Execute checks:
       - HTTP: curl requests
       - CLI: command execution with 30s timeout
    6. Report PASS/FAIL with evidence
    7. Cleanup processes

    If no parseable criteria: Report "NO TESTABLE CRITERIA" and exit.
    If app won't start: Report "APP FAILED TO START" and exit.

    Output: Integration Verification Report with verdict.

## Phase 2: Handle Result

**On NO TESTABLE CRITERIA**:
- Report: "Could not find acceptance criteria in expected format"
- Show expected format with examples
- Stop workflow (terminal failure)

**On APP FAILED TO START**:
- Report the error message from verifier
- Stop workflow (terminal failure - do not retry)

**On NO AUTOMATED CHECKS**:
- Report: "All criteria require manual verification"
- List the manual checks user needs to perform
- Stop workflow (nothing to automate)

**On INTEGRATION PASSED**:
- Report success summary
- If has MANUAL items: "X manual checks still required: [list]"
- Workflow complete

**On INTEGRATION FAILED**:
- Continue to Phase 3

## Phase 3: Present Failures

Present to user:
1. Which criteria failed (with type: HTTP/CLI)
2. Evidence (actual vs expected)
3. Suggested fixes from verifier

Track internally: Which criteria passed (for regression detection)

For each failed criterion with a suggested fix:
- Show the suggested fix
- Ask: "Apply this fix? [yes / skip / stop]"

Handle response:
- **yes**: Queue fix for application
- **skip**: Mark criterion as SKIPPED, continue to next
- **stop**: Exit workflow immediately, report current state

After processing all failures: Continue to Phase 4

## Phase 4: Apply Fixes

Main Claude (not subagent) applies the queued fixes.
Follow each "Suggested Fix" from the verifier report.

After all fixes applied: Continue to Phase 5

## Phase 5: Re-verify

Check iteration count:
- If this would be iteration 4 (after 2 fix attempts):
  - Stop workflow
  - Report: "Max iterations reached (2 fix attempts)"
  - Show all evidence from all iterations
  - Suggest: "Run `/debug [specific failing criterion]` for deeper investigation"
  - Do NOT auto-chain to /debug

Return to Phase 1 with same plan.

Compare results to previous iteration:
- If a criterion that previously PASSED now FAILS:
  - Report prominently: "REGRESSION: AC1 previously passed, now fails"
  - Treat as a failure (user can fix or skip)

## Rules
- Max 2 fix-verify iterations (3 total verification runs)
- Terminal failures (no criteria, app won't start) NEVER retry
- Always show evidence (actual responses, exit codes, command output)
- Track state across retries to detect regressions
- [MANUAL] criteria are skipped but listed in final report
- CLI commands have 30s timeout, no shell expansion
- Never auto-chain to /debug - suggest only
- User must approve each fix individually
