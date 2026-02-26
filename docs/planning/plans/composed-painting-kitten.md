# Plan: Fix Starter-Kit Onboarding Gaps (v3 — Final)

*Staff engineer approved with changes (v2). This version addresses all remaining feedback.*

## Problem Statement

When a developer clones the starter-kit and runs `make init`, the **backend onboarding is excellent** (9/10) but the **frontend onboarding is broken** (2/10) and there's **no root-level entry point** (3/10):

1. **No root README.md** — GitHub/IDE shows nothing
2. **Frontend README.md is generic Next.js template** — says `npm` i.p.v. `pnpm`
3. **No working frontend example** — "Get Started" button does nothing, apiFetch unused
4. **No frontend tests** — Vitest configured but 0 test files
5. **Root Makefile has no `help` target**

## Proposed Solution

Bring frontend and root-level docs up to backend quality. Only documentation + minimal working examples. No new features, no architecture changes.

**Scope boundary:** Read-only Items list. No create form, no mutations. Match backend's Items feature as a working reference that survives `make init`.

---

## Implementation Steps

### Step 1: Root README.md

Create `README.md` at repo root.

Content structure:
- Project name (`AIpoweredMakers` — gets renamed by init script) + one-line description
- **Quick Start** (numbered): `make init` → `make setup` → backend start (4 commands) → frontend start (2 commands)
- **Tip** (blockquote): "You'll need 3 terminal sessions: database services, backend, frontend"
- **Repo Layout** table with links to sub-READMEs
- Links to: `docs/README.md` (Bootstrap Checklist), `backend/README.md`, `frontend/README.md`
- Frontend quick start: `pnpm install` → `pnpm dev` (2 commands, consistent with frontend README)

**Init script update:** Add `README.md` to the display-name replacement loop (line 106-120 in `scripts/init-project.sh`). Note: `frontend/.env.example` bevat geen "aipoweredmakers" — geen aanpassing nodig daar.

### Step 2: Frontend README.md

Rewrite `frontend/README.md` to mirror `backend/README.md` structure.

Sections:
- **Prerequisites:** Node.js 22+, pnpm
- **Quick Start:** `pnpm install` → `pnpm dev` → open localhost:3000 (API URL defaults to `http://localhost:8000` — `.env.example` copy only needed for non-default config)
- **Scripts:** table with dev, build, start, lint, test, test:watch, test:coverage
- **Environment Variables:** `NEXT_PUBLIC_API_URL` — Backend API URL, defaults to `http://localhost:8000`. Needed for Items example; frontend works without backend but shows connection message.
- **Project Structure:** src/app, src/components, src/features, src/hooks, src/lib, src/types
- **Conventions:** Link to `frontend/CLAUDE.md`

### Step 3: Working Frontend Example — Items List (read-only)

Demonstrates the full prescribed pattern: Server Component → Client Component → Hook → API layer.

**Design decision:** Frontend Items feature **survives `make init`**, matching backend Items feature (also kept as reference). No changes to init script cleanup section.

**Design decision:** When backend is unreachable, the component shows a helpful connection message — not a blank screen or unhandled error. `pnpm build` succeeds without a running backend (TanStack Query doesn't execute during SSR/build).

#### Files to create:

**a. `frontend/src/features/items/types.ts`** — TypeScript types matching `backend/features/items/schema.py`
```typescript
export interface Item {
  id: string;        // UUID as string
  name: string;
  description: string | null;
  created_at: string; // ISO datetime
  updated_at: string;
}

// Matches backend ItemListResponse
export interface ItemListResponse {
  items: Item[];
  total: number;
}
```

**b. `frontend/src/features/items/api.ts`** — TanStack Query hook (read-only, no mutations)
```typescript
import { useQuery } from "@tanstack/react-query";
import { apiFetch } from "@/lib/api";
import type { ItemListResponse } from "./types";

export function useItems() {
  return useQuery({
    queryKey: ["items"],
    queryFn: () => apiFetch<ItemListResponse>("/api/v1/items"),
    // Disable retry so connection failures show immediately instead of
    // silently retrying 3x (TanStack Query default). Intentional for
    // onboarding UX — don't remove without updating error state handling.
    retry: false,
  });
}
```

No `useCreateItem` — keep scope minimal. Mutations demonstrated when a form example is added later.

**c. `frontend/src/features/items/components/item-list.tsx`** — Client component with explicit error/empty states
```typescript
"use client";

import { useItems } from "../api";
// Uses Card from shadcn/ui

// Four render states:
// 1. Loading: skeleton/spinner
// 2. Error (backend unreachable): helpful message —
//    "Could not connect to API at localhost:8000. Is the backend running?"
//    "Start the backend: cd backend && make dev"
// 3. Success + empty: "No items yet. Create one via the API: POST /api/v1/items"
// 4. Success + items: list of items with name, description, created_at
```

**d. `frontend/src/features/items/index.ts`** — Barrel export
```typescript
export { ItemList } from "./components/item-list";
export type { Item, ItemListResponse } from "./types";
```

**e. Update `frontend/src/app/page.tsx`** — Replace static card with working example
```typescript
// Server Component (no "use client")
// Imports ItemList from features/items
// Shows project name + description + ItemList component
// Structure: centered layout with Card containing ItemList
//
// NOTE: Add comment explaining SSR/CSR boundary:
// ItemList is a Client Component — useQuery does NOT execute during SSR/build.
// The page renders a loading skeleton server-side, then hydrates and fetches
// client-side. No prefetchQuery/HydrationBoundary needed for this minimal example.
```

### Step 4: Frontend Test Example

Create `frontend/src/features/items/components/item-list.test.tsx`

**Correct testing pattern** (mock fetch globally, use real QueryClientProvider):
```typescript
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ItemList } from "./item-list";

// Mock fetch at global level — NOT the hooks
const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

afterEach(() => {
  mockFetch.mockReset(); // Prevent test ordering dependencies
});

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return ({ children }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}

// Mock return shapes (must match apiFetch expectations):
// Success: mockFetch.mockResolvedValue({ ok: true, json: () => Promise.resolve(data) })
// Empty:   mockFetch.mockResolvedValue({ ok: true, json: () => Promise.resolve({ items: [], total: 0 }) })
// Network: mockFetch.mockRejectedValue(new TypeError("Failed to fetch"))

// 4 test cases matching 4 render states:
// Test: shows loading state initially
// Test: shows items when API returns data
// Test: shows "no items" message when API returns empty list
// Test: shows connection error message when fetch fails (TypeError)
```

### Step 5: Root Makefile `help` Target

Use self-documenting pattern that parses existing `##` comments:
```makefile
.PHONY: help setup init
.DEFAULT_GOAL := help

help:  ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
```

Note: Use `.*##` (greedy) not `.*?##` — ERE does not support lazy quantifiers. Greedy is fine since `##` only appears once per line. Add `help` to `.PHONY` list.

Existing targets already have `##` comments: `init: ## Transform...`, `setup: ## First-time...`

### Step 6: Update init-project.sh

Only change: add `README.md` to the display-name replacement loop (line 106):

```bash
# Display name replacements: AIpoweredMakers → display name
for file in \
  CLAUDE.md \
  README.md \           # ← ADD THIS LINE
  frontend/src/app/page.tsx \
  ...
```

The frontend Items feature is **NOT** cleaned up during init (same as backend Items — kept as working reference).

---

## Files Affected

| File | Action | Description |
|---|---|---|
| `README.md` | **Create** | Root README with quick start |
| `frontend/README.md` | **Rewrite** | Project-specific setup, scripts, env vars |
| `frontend/src/features/items/types.ts` | **Create** | TypeScript types matching backend schemas |
| `frontend/src/features/items/api.ts` | **Create** | `useItems()` TanStack Query hook |
| `frontend/src/features/items/components/item-list.tsx` | **Create** | Items list with error/empty/loading states |
| `frontend/src/features/items/index.ts` | **Create** | Barrel export |
| `frontend/src/features/items/components/item-list.test.tsx` | **Create** | Test with global fetch mock |
| `frontend/src/app/page.tsx` | **Modify** | Replace static card with ItemList |
| `Makefile` | **Modify** | Add `help` target + `.DEFAULT_GOAL` |
| `scripts/init-project.sh` | **Modify** | Add `README.md` to rename loop |
| `frontend/CLAUDE.md` | **Modify** | Add one-liner: `features/items/` is a reference implementation that survives `make init` |

## Existing Code to Reuse

| File | What | Used in |
|---|---|---|
| `frontend/src/lib/api.ts` | `apiFetch<T>()` | `features/items/api.ts` |
| `frontend/src/components/providers/query-provider.tsx` | QueryProvider | Already in layout.tsx |
| `frontend/src/components/ui/card.tsx` | Card, CardHeader, etc. | `item-list.tsx`, `page.tsx` |
| `frontend/src/components/ui/button.tsx` | Button | `page.tsx` |
| `frontend/src/lib/utils.ts` | `cn()` | `item-list.tsx` |
| `backend/features/items/schema.py` | Pydantic schemas | Reference for `types.ts` |

## Pre-existing Conditions Verified

- **CORS:** `backend/.env.example` line 5: `CORS_ORIGINS=http://localhost:3000` — already configured
- **Vitest:** `passWithNoTests: true` in `vitest.config.mts` — current `pnpm test` passes with 0 tests
- **apiFetch:** Throws `Error` on non-2xx, doesn't handle network errors (TypeError) — component must catch both
- **QueryProvider:** Already wrapped in `layout.tsx` — no provider changes needed
- **Init script:** Uses `if [[ -f "$file" ]]` guards — adding README.md is safe even if file doesn't exist yet in some edge case

## Testing Strategy

**Automated:**
1. `cd frontend && pnpm test` → item-list.test.tsx passes (4 test cases)
2. `cd frontend && pnpm lint` → no ESLint errors
3. `cd frontend && pnpm build` → succeeds without running backend

**Manual full-stack:**
4. `cd frontend && pnpm dev` → page loads, shows "Could not connect" message (backend not running)
5. Start backend (`make dev`) → refresh frontend → shows "No items yet" with API hint
6. Create item via Swagger (`POST /api/v1/items {"name": "test"}`) → refresh → item appears
7. `make init` with test name → verify root README.md gets renamed, frontend Items feature preserved

## Rollback Plan

All changes are additive or documentation-only:
```bash
rm README.md
rm -rf frontend/src/features/items/
git checkout frontend/README.md frontend/src/app/page.tsx Makefile scripts/init-project.sh
```
No dependency changes, no database changes, no config changes.

---

## Staff Engineer Review History

**v1 → v2:** 3 critical issues (backend unreachable state, init script under-specified, pseudocode instead of API paths) + 5 concerns (test pattern, CORS, barrel export, make help, dead code). All addressed.

**v2 → v3 (final):** 2 critical issues (test mock specificity, README consistency) + 4 concerns (SSR comment, grep pattern, state count, retry comment). All addressed.
