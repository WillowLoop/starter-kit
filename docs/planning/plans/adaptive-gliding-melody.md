# Plan: Standaarden overnemen uit productivity-tools-template

## Context

De `productivity-tools-template` (Next.js + Supabase) bevat mature standaarden voor security, input validatie, error handling en AI-assisted development rules die ontbreken in de starter-kit (Next.js 16 + FastAPI + PostgreSQL). Dit plan adopteert de meest waardevolle onderdelen, aangepast voor de starter-kit stack.

## Scope: 9 nieuwe bestanden, 1 wijziging

> **Fase 4 (security-headers extractie) geschrapt** op advies staff engineer review — de huidige `next.config.ts` is 59 regels, clean en leesbaar. De extractie voegt indirectie toe zonder evenredige waarde.

### Fase 1: `.claude/rules/` — AI development guidance

Bron: template `.claude/rules/` (7 bestanden) → 6 bestanden (aangepast)

| Bestand | Inhoud | Aanpassingen |
|---|---|---|
| `.claude/rules/naming.md` | kebab-case routes, snake_case DB, camelCase code, `_at`/`_id` suffixes | + Python snake_case functies, + `UPPER_SNAKE_CASE` env vars |
| `.claude/rules/security.md` | Input validatie regels, security headers checklist, file upload regels, error handling | Supabase auth sectie verwijderd, FastAPI/Pydantic patronen toegevoegd, rate limiting verwijst naar slowapi+Caddy |
| `.claude/rules/build-errors.md` | 25+ concrete foutpatronen (ESLint, TypeScript, Next.js async params, forms) | `catch (error: any)` → `catch (error: unknown)`, Supabase Server Component code verwijderd |
| `.claude/rules/ui.md` | Mobile responsiveness, keyboard accessibility, 3-state components, semantic HTML | Component limiet 300→200 (conform frontend CLAUDE.md) |
| `.claude/rules/api.md` | Response shapes, HTTP status codes, validatie | + FastAPI REST conventions, + verwijzing naar `lib/api.ts` |
| `.claude/rules/workflow.md` | Minimal changes, lees voor je wijzigt, check bestaande patterns, vraag voor destructieve acties | Git commit/push regels verwijderd (starter-kit gebruikt conventional commits met AI), docs/scripts folder verwijzingen aangepast |

**Niet dupliceren** wat al in CLAUDE.md bestanden staat: conventional commits, repo layout, CORS config, file limits, component patterns.

**Na schrijven:** diff elke rule file tegen root CLAUDE.md en frontend CLAUDE.md — verwijder overlap. **CLAUDE.md is autoritatief** — bij conflict wordt overlap verwijderd uit de rules file, niet uit CLAUDE.md. Rules files max ~200 tokens (zelfde discipline als CLAUDE.md).

**Toevoegen aan root CLAUDE.md:** één regel in de Docs tabel: `| .claude/rules/ | Domain-specifieke development rules (naming, security, UI, etc.) |`

### Fase 2: `lib/input-validation.ts` — defense-in-depth (UX, niet security boundary)

Bron: template `lib/input-validation.ts` (367 regels) → ~200 regels

> **Belangrijk:** Deze module is een UX-laag die gebruikers vriendelijke foutmeldingen toont bij verdachte input. Het is GEEN security boundary — aanvallers omzeilen de frontend. De echte bescherming zit in de backend (Pydantic validatie + SQLAlchemy parameterized queries). Dit moet expliciet gedocumenteerd worden in de module header.

**Nieuw bestand:** `frontend/src/lib/input-validation.ts`
- Sanitization functies: `sanitizeString`, `sanitizeFilename`, `sanitizeEmail`
- ~~`sanitizeHTML`~~ **geschrapt** — React escapet HTML standaard in JSX. Zonder `dangerouslySetInnerHTML` gebruik is dit dead code. Mocht HTML sanitization nodig zijn, gebruik DOMPurify.
- Attack pattern detection: SQLi, XSS, command injection, path traversal, LDAP (als UX warnings)
- Zod `ValidationSchemas`: alleen de sanitize-functies en `validateInput<T>()` wrapper
- ~~`ValidationSchemas` object met email/password/userId/etc.~~ **geschrapt** — features definiëren hun eigen Zod schemas (React Hook Form + Zod pattern). Premature generieke schemas zonder consumers.
- `validateInput<T>()` wrapper
- ~~`safeJsonParse<T>()`~~ **uitgesteld** — geen consumers vandaag. Shallow `__proto__` stripping is onvolledig (mist `constructor`, nested keys). Toevoegen wanneer er een concrete use case is, met recursive key filtering of `JSON.parse` reviver.
- **Verwijderd:** `withValidation`, `validateFormData`, `validateCSPReport`
- **Zod 4:** Code wordt **from scratch geschreven** voor Zod 4 API (niet geport van Zod 3). Gebruikt `z.ZodType<T>` voor generics.
- **Fix:** `/g` flag verwijderd van regex patterns (lastIndex bug)

**Nieuw bestand:** `frontend/src/lib/input-validation.test.ts`
- Tests voor sanitize-functies (string, filename, email)
- Tests voor `validateInput` success/failure
- Tests voor dangerous pattern detection
- Tests voor `safeJsonParse` (valid JSON, invalid JSON, prototype pollution)

### Fase 3: `lib/error-handling.ts` — frontend error sanitization

Bron: template `lib/error-handling.ts` (237 regels) → ~150 regels

**Nieuw bestand:** `frontend/src/lib/error-handling.ts`
- `SAFE_ERROR_MESSAGES` constanten (14 voorgedefinieerde veilige foutmeldingen)
- `sanitizeErrorMessage(error: unknown)` — detecteert sensitive patterns, mapt naar veilige berichten
- `handleSecureError(error, context?)` — logt server-side, retourneert sanitized response
- **Verwijderd:** `withSecureErrorHandling` (Server Actions wrapper)
- **Aangepast patterns:** Supabase → FastAPI/SQLAlchemy (`/sqlalchemy/i`, `/uvicorn/i`, `/pydantic/i`)
- **Toegevoegd:** "connection refused" → `NETWORK_ERROR`, "validation error" → `INVALID_INPUT`

**Wijziging:** `frontend/src/lib/api.ts`
- Integreer `sanitizeErrorMessage` in `apiFetch` error handling (regel 17 lekt nu raw status codes)
- Huidige: `throw new Error(\`API error: ${response.status} ${response.statusText}\`)`
- Nieuw: gebruik `sanitizeErrorMessage` voor de throw, of gooi een typed `ApiError` met sanitized message

**Nieuw bestand:** `frontend/src/lib/error-handling.test.ts`
- Tests per categorie: auth errors, rate limiting, network, database, sensitive patterns, generic fallback
- FastAPI-specifieke tests: connection refused, validation error mapping

## Implementatievolgorde

```
Fase 1: .claude/rules/ (6 bestanden, onafhankelijk)
   ↓
Fase 2: input-validation.ts + tests → pnpm test
   ↓  (parallel mogelijk)
Fase 3: error-handling.ts + tests + api.ts update → pnpm test
   ↓
Eindverificatie: pnpm typecheck && pnpm lint && pnpm test && pnpm build
```

Fase 2 en 3 zijn onafhankelijk en kunnen parallel (behalve dat api.ts in fase 3 van error-handling.ts afhangt).

## Verificatie

```bash
# Per fase
cd frontend && pnpm typecheck          # geen any types gelekt
cd frontend && pnpm test               # alle tests groen
cd frontend && pnpm lint               # ESLint clean

# Eindcheck (CI-equivalent)
cd frontend && pnpm typecheck && pnpm lint && pnpm test && pnpm build
```

## Bestanden overzicht

| # | Bestand | Actie |
|---|---------|-------|
| 1 | `.claude/rules/naming.md` | Nieuw |
| 2 | `.claude/rules/security.md` | Nieuw |
| 3 | `.claude/rules/build-errors.md` | Nieuw |
| 4 | `.claude/rules/ui.md` | Nieuw |
| 5 | `.claude/rules/api.md` | Nieuw |
| 6 | `.claude/rules/workflow.md` | Nieuw |
| 7 | `frontend/src/lib/input-validation.ts` | Nieuw |
| 8 | `frontend/src/lib/input-validation.test.ts` | Nieuw |
| 9 | `frontend/src/lib/error-handling.ts` | Nieuw |
| 10 | `frontend/src/lib/error-handling.test.ts` | Nieuw |
| 11 | `frontend/src/lib/api.ts` | Wijziging (sanitized errors) |

## Bekende risico's

| Risico | Mitigatie |
|---|---|
| Zod 4 API verschillen | Code from scratch voor Zod 4, niet geport van Zod 3. Gebruikt `z.ZodType<T>` |
| `noUncheckedIndexedAccess` in validatie code | Template patronen (`forEach`, `.length > 0`) al compatible |
| Regex `/g` flag + `.test()` lastIndex bug | `/g` flag verwijderen — niet nodig voor existence check |
| `sanitizeErrorMessage` in `apiFetch` kan stack traces verbergen tijdens development | `console.error` behouden voor development logging, alleen sanitized message in throw |

## Staff engineer review feedback verwerkt

| Feedback | Actie |
|---|---|
| Input validation is UX, niet security boundary | Expliciet gedocumenteerd in module header |
| Zod 4 compatibility concreet adresseren | Code from scratch voor Zod 4, niet "fallback" |
| `apiFetch` lekt raw status codes | api.ts update toegevoegd aan scope |
| `sanitizeHTML` zonder consumers is dead code | Geschrapt (React escapet al) |
| Security-headers extractie is over-engineering | Fase 4 geschrapt |
| `.claude/rules/` kan conflicteren met CLAUDE.md | Expliciete deduplicatie-stap na schrijven |
| `ValidationSchemas` premature zonder consumers | Geschrapt — features definiëren eigen schemas |
| `safeJsonParse` prototype pollution | Utility uitgesteld — geen consumers, shallow stripping onvolledig |
| `.claude/rules/` kan CLAUDE.md tegenspreken | CLAUDE.md is autoritatief, rules files max ~200 tokens |
| `safeJsonParse` re-review: shallow stripping onvolledig | Uitgesteld tot concrete consumer, dan recursive filtering |
