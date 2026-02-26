# DO NOT EDIT - Auto-generated from setup/commands/
# Source: setup/commands/verify-acceptance.md
# To modify, edit the source and run: ./setup/scripts/sync-agents.sh

---
description: AI-driven browser testing with agent-browser to verify acceptance criteria. Auto-spawns fix agents on failure using /plan-and-review.
---

# Verify Acceptance Criteria

AI-driven browser testing using agent-browser with automatic fix loop.

## What This Does

```
Parse Plan → Discover Config → Browser Test → Pass? → Done
                                    ↓ Fail
                              Spawn Fix Agent (/plan-and-review)
                                    ↓
                              Re-verify (max 3 loops)
```

## Quick Start

```bash
# Verify criteria from a plan file
/verify-acceptance

# Or with explicit plan path
/verify-acceptance plans/my-feature.md

# Or paste criteria inline
/verify-acceptance
## Acceptance Criteria
### AC-001: Login page works
- **route**: /login
- **verify**: Email and password inputs visible
```

## Invoke the Skill

Use the `verify-acceptance` skill from `skills/skills-dev-workflows/verify-acceptance/SKILL.md`.

Follow all phases in order:
1. **Phase 0: Discovery** - Find or ask for config (NEVER fail, always ask)
2. **Phase 1: Parse** - Extract testable criteria from plan
3. **Phase 2: Setup** - Start dev server if needed
4. **Phase 3: Verify** - Run browser tests with agent-browser
5. **Phase 4: Results** - Report pass/fail
6. **Phase 5: Fix** - On failure, spawn fix agent with /plan-and-review
7. **Phase 6: Loop** - Re-verify after fix (max 3 iterations)

## Acceptance Criteria Format

See `skills/skills-dev-workflows/verify-acceptance/references/ac-format.md` for full format.

### Quick Example

```markdown
### AC-001: Role dropdown shows correct label
- **route**: /settings
- **auth**: VESTIGING_ADMIN
- **verify**: Text "Hoofdvestiging Admin" visible in dropdown
- **not**: Should NOT show "Kantoor Admin"

### AC-002: Logout button works
- **route**: /dashboard
- **auth**: any
- **verify**: Button with text "Logout" exists in header
```

## Discovery (Auto-Config)

The skill automatically discovers project configuration:

1. **Check .claude/verify.yml** - Explicit config
2. **Auto-detect** - package.json, pyproject.toml, docker-compose
3. **Search** - README, .env.example, CI configs
4. **Ask user** - If nothing found, ask with smart defaults
5. **Save** - Offer to save config for future runs

**The skill will NEVER fail** because config is missing - it will always ask.

## Fix Loop

When tests fail:

1. Failures collected with screenshots + accessibility snapshots
2. Fix agent spawned with full context
3. Fix agent uses `/plan-and-review` workflow:
   - Creates fix plan
   - Staff engineer reviews
   - Iterates until approved
   - Implements fix
4. Re-verification runs automatically
5. Loop continues until all pass (max 3 iterations)

## Comparison with /verify-loop

| Aspect | /verify-loop | /verify-acceptance |
|--------|--------------|-------------------|
| Browser engine | Playwright | agent-browser |
| Test style | Code-based tests | AI-interpreted criteria |
| Flexibility | Rigid selectors | Semantic locators |
| Setup | Needs Playwright install | npm i -g agent-browser |
| AI-native | No | Yes |

Use `/verify-acceptance` when:
- Criteria are in natural language
- UI may change but meaning stays same
- You want AI to interpret pass/fail

Use `/verify-loop` when:
- You need exact selector matching
- Running in CI/CD pipeline
- Playwright already in project

## Output

### Success
```
✅ VERIFICATION PASSED

All 5 acceptance criteria verified:
- AC-001: ✅ Login page renders correctly
- AC-002: ✅ Valid credentials redirect to dashboard
- AC-003: ✅ Role label shows "Hoofdvestiging Admin"
- AC-004: ✅ Logout button visible
- AC-005: ✅ Settings page loads

📸 Evidence: evidence/

🔍 1 criterion requires manual verification:
- AC-006: [MANUAL] Email notification received
```

### Failure with Fix Loop
```
❌ VERIFICATION FAILED → STARTING FIX LOOP

## Iteration 1/3

### Failures
- AC-003: Expected "Hoofdvestiging Admin", found "Kantoor Admin"

### Spawning fix agent with /plan-and-review...
[Fix agent creates plan, gets staff review, implements]

### Re-verifying...
✅ AC-003 now passes

## Final Result
✅ All criteria pass after 1 fix iteration
```

## Prerequisites

```bash
# Install agent-browser globally
npm install -g agent-browser
agent-browser install
```

## Rules

1. **Never fail on missing config** - Discovery asks user
2. **Max 3 fix iterations** - Then stop and suggest /debug
3. **Screenshots as evidence** - Saved to evidence/ folder
4. **Staff engineer review** - Fix plans are reviewed before implementation
5. **Cleanup on exit** - Stop dev server if we started it
