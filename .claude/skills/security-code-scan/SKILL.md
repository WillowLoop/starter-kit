---
name: security-code-scan
description: >-
  Scan codebase for OWASP Top 10 vulnerabilities, AI/LLM security issues,
  and stack-specific risks in FastAPI + Next.js. Use when reviewing code
  for security issues, before deployment, or when security-audit dispatches
  a code scan. Covers SQL injection, XSS, SSRF, command injection, prompt
  injection, and framework-specific patterns.
---

# Security Code Scan

Scan the codebase for OWASP Top 10 vulnerabilities, AI/LLM security issues, and framework-specific risks.

## When to use

- Before deployment or release
- After major code changes
- When `security-audit` dispatches a code scan
- Standalone: `/security-code-scan`

## Grep patterns

Scan each vulnerability type using the patterns below. For each match: (1) Grep for the pattern, (2) Read 10 lines of context around each match, (3) Check against exclusion patterns, (4) Classify as PASS/FAIL/WARN.

| Vulnerability | Pattern | Scope | Exclude |
|---|---|---|---|
| SQL injection | `text(f"` / `text(f'` | `backend/**/*.py` | — |
| XSS | `dangerouslySetInnerHTML` | `frontend/src/**/*.tsx` | — |
| Command injection | `subprocess\|os\.system\|os\.popen` | `backend/**/*.py` | `session.execute`, `connection.execute` (SQLAlchemy) |
| Insecure eval | `eval\(\|exec\(` | `**/*.py` | `session.execute`, `connection.execute` |
| SSRF | `httpx\.\|requests\.\|urllib\.request` | `backend/**/*.py` | Constant URLs, health checks |
| Path traversal | `open\(.*\+\|Path\(.*\+` | `backend/**/*.py` | Hardcoded paths |
| Mass assignment | `class.*BaseModel` without `model_config` | `backend/**/*.py` | — |
| Error disclosure | `str\(exc\)\|str\(e\)\|traceback` in responses | `backend/**/*.py` | Logger calls |
| Prompt injection | `openai\|anthropic\|langchain\|llama` | `**/*.py`, `**/*.ts` | — |

## Known-good patterns (do NOT flag)

These patterns are safe and should be classified as PASS, not flagged:

- `session.execute(select(...))` — SQLAlchemy ORM query, parameterized by design
- `session.execute(text(...).bindparams(...))` — SQLAlchemy with bound parameters, safe
- `connection.execute(...)` — SQLAlchemy connection execute, parameterized
- `subprocess.run([...], check=True)` with hardcoded commands — safe when no user input
- `eval()` inside test files (`**/test_*.py`, `**/tests/**`) — acceptable in test context
- `httpx.AsyncClient` with constant base URLs in service clients — not SSRF
- Generic error handlers returning fixed messages (e.g., `"Internal server error"`) — safe

## Scan procedure

### Step 1: SQL Injection
```
Grep for: text(f" and text(f' in backend/**/*.py
```
- FAIL if f-string found inside `text()` — user input may be interpolated
- PASS if only `text(...).bindparams(...)` or ORM `select()` used

### Step 2: XSS
```
Grep for: dangerouslySetInnerHTML in frontend/src/**/*.tsx
```
- FAIL if content comes from user input or API without sanitization
- WARN if content is from a trusted CMS with HTML sanitizer
- PASS if not found

### Step 3: Command Injection
```
Grep for: subprocess|os.system|os.popen in backend/**/*.py
```
- FAIL if user input flows into command arguments
- WARN if commands use `shell=True`
- PASS if commands are hardcoded with no variable input
- EXCLUDE: `session.execute`, `connection.execute` — these are SQLAlchemy, not shell commands

### Step 4: Insecure Eval
```
Grep for: eval(|exec( in **/*.py
```
- FAIL if user-controlled input can reach eval/exec
- WARN if input source is ambiguous
- PASS if only in test files or with hardcoded strings
- EXCLUDE: `session.execute`, `connection.execute`

### Step 5: SSRF
```
Grep for: httpx.|requests.|urllib.request in backend/**/*.py
```
- FAIL if URL is constructed from user input without allowlist validation
- WARN if URL partially from user input
- PASS if URLs are constants or from validated config
- Read `references/owasp-fastapi.md` for FastAPI-specific SSRF patterns

### Step 6: Path Traversal
```
Grep for: open(.*+|Path(.*+ in backend/**/*.py
```
- FAIL if filename/path includes user input without sanitization
- WARN if path is constructed from config that could be influenced
- PASS if paths are hardcoded or use safe path joining with validation

### Step 7: Mass Assignment
```
Grep for Pydantic models in backend/**/*.py
Check: class.*BaseModel without model_config or explicit field definitions
```
- WARN if models accept `dict`/`Any` types without field restrictions
- PASS if models have explicit field definitions with types
- Read `references/owasp-fastapi.md` for Pydantic security patterns

### Step 8: Error Disclosure
```
Grep for: str(exc)|str(e)|traceback in backend/**/*.py
```
- FAIL if exception details are returned in HTTP responses
- PASS if exceptions are only logged (logger.error, structlog)
- PASS if generic messages returned to client (e.g., "Internal server error")

### Step 9: AI/LLM Security
```
Grep for: openai|anthropic|langchain|llama in **/*.py and **/*.ts
```
- If no matches: report as N/A with INFO note "No AI/LLM integrations detected"
- If matches found: read `references/prompt-injection.md` and check for:
  - User input concatenated directly into prompts (FAIL)
  - API keys in client-side code (FAIL)
  - System prompt exposed in error messages (WARN)

### Step 10: Framework-specific checks
- Read `references/owasp-fastapi.md` for FastAPI patterns
- Read `references/owasp-nextjs.md` for Next.js patterns
- Check auth dependency gaps, response_model usage, Server Action safety

## Severity classification

| Severity | Criteria |
|---|---|
| CRITICAL | Direct exploitation possible, no authentication required |
| HIGH | Exploitation possible with authentication or specific conditions |
| MEDIUM | Potential risk requiring specific circumstances to exploit |
| LOW | Best practice violation, minimal direct risk |
| INFO | Observation, no action required |

## Output format

```markdown
## Code Security Scan Results

### Summary
- Critical: N | High: N | Medium: N | Low: N | Info: N

### Findings

#### [SEVERITY] Finding title
- **Type**: OWASP category
- **Location**: `file:line`
- **Description**: What was found
- **Evidence**: Code snippet
- **Remediation**: How to fix
- **Reference**: Link to relevant reference doc

### Known-Good Patterns Verified
- [List of patterns checked and confirmed safe]

### Scan Coverage
- Files scanned: N
- Vulnerability types checked: 9
- AI/LLM integrations: detected/not detected
```

## References

For detailed stack-specific patterns, see:
- `references/owasp-fastapi.md` — FastAPI vulnerability patterns
- `references/owasp-nextjs.md` — Next.js vulnerability patterns
- `references/prompt-injection.md` — AI/LLM security patterns
