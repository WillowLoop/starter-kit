# Staff Engineer Review: Fix Starter-Kit Onboarding Gaps

## Summary

The problem diagnosis is correct and the plan addresses real pain points. The frontend is genuinely incomplete compared to the backend, and a developer cloning this repo would immediately hit friction. The plan's scope is appropriately constrained: documentation plus one working example. However, there are several issues ranging from a fundamental architectural mistake in the frontend example to missing details in the init script update that need to be addressed before implementation.

## Critical Issues (MUST FIX)

- [ ] **Issue: `apiFetch` is a server-incompatible function being called from a client component, but page.tsx is a Server Component that renders it -- the plan skips the hydration/SSR problem entirely.** The plan says page.tsx is a Server Component that "renders ItemList." ItemList is a `"use client"` component that uses TanStack Query's `useQuery` to call `apiFetch`. On the server-side render, `apiFetch` calls `fetch()` with `localhost:8000` as the base URL. This will fail during `next build` (SSR at build time) and will fail at SSR in production unless the backend is reachable from the Next.js server at that exact URL. The plan does not mention `NEXT_PUBLIC_API_URL` configuration requirements, does not address what happens during `pnpm build` when no backend is running, and does not discuss SSR vs client-only rendering for this component. **Fix:** Either (a) explicitly make the ItemList component render only on the client (Suspense boundary with a loading state, where TanStack Query only fires on mount), which is what `useQuery` does by default -- but this needs to be explicitly stated and tested during build, or (b) document clearly that `pnpm build` requires the backend to be reachable, or that the component gracefully handles fetch failures at build time. The plan should include `pnpm build` as a verification step (it does, item 4 in testing) but should anticipate and specify what happens when the backend is not running.

- [ ] **Issue: The init script update (Step 6) is under-specified and likely incomplete.** The plan says to "add root README.md to the list" in init-project.sh. But examining the actual script at `/Users/cheersrijneau/Developer/dev_standards/starter-kit/scripts/init-project.sh`, lines 94-119, there are two separate replacement loops: one for lowercase `aipoweredmakers` (package names) and one for display-name `AIpoweredMakers`. The root README.md would need to be added to the `AIpoweredMakers` display-name loop (lines 106-119). But more importantly: the plan creates frontend feature files under `frontend/src/features/items/` -- the init script's cleanup section (lines 133-155) deletes example files from `docs/planning/` but does NOT delete the backend Items example. Looking at the init script, the backend Items feature is kept as a reference. The plan should explicitly state whether the frontend Items feature should also survive `make init`, or should be deleted like the doc examples. If it should be deleted, the init script needs a `rm -rf frontend/src/features/items/` line added. If it should survive, that needs to be a conscious decision.

- [ ] **Issue: The plan creates a frontend Items feature but the backend Items feature uses the API path `/api/v1/items` -- the plan's `api.ts` pseudocode does not specify the actual endpoint path.** This seems minor but is exactly the kind of gap that causes a "it doesn't work" experience. The `apiFetch` call in the hooks must use `/api/v1/items` as the path. The plan should specify this explicitly rather than leaving it as pseudocode (`// useItems() hook using apiFetch + useQuery`). A starter-kit example that has the wrong API path on first try is worse than no example at all.

## Concerns (SHOULD ADDRESS)

- [ ] **Concern: No `frontend/src/features/items/index.ts` barrel export.** The frontend CLAUDE.md convention (`src/features/{name}/`) and the fact that this is a starter-kit example means it should demonstrate the full pattern including clean imports. Other features will follow this example. Add a barrel file.

- [ ] **Concern: The test in Step 4 mocks TanStack Query, which means it tests almost nothing.** "Basic render test with mocked TanStack Query" -- if you mock the data-fetching layer, you are testing that React can render a list of items, which is trivial. A more useful test for a starter-kit would be one that wraps the component in a real `QueryClientProvider` with a mocked `fetch` (using `vi.fn()` or `msw`), showing how to actually test components that use TanStack Query. This is the pattern developers will copy. A test that mocks at the wrong layer teaches the wrong lesson. At minimum, specify which layer is mocked: mock `fetch` globally via `vi.fn()`, not the hooks themselves.

- [ ] **Concern: The plan does not address CORS.** The backend has CORS middleware (`shared/middleware/cors.py`). For the frontend running on `localhost:3000` to call the backend on `localhost:8000`, CORS must allow origin `http://localhost:3000`. This may already be configured, but the plan does not verify it. If CORS is not configured for development, the working example will fail with an opaque browser error -- terrible for onboarding. The plan should include checking CORS config as part of the manual verification.

- [ ] **Concern: The `make help` implementation (Step 5) has no detail.** The plan says "Add `make help` that prints available targets with descriptions." There are multiple well-known patterns for this (self-documenting with `##` comments, manual `@echo` list, `awk` on Makefile). The existing Makefile already uses `##` comments on targets (`init:  ## Transform starter-kit...`). The implementation should use the standard `grep '##'` awk pattern that parses these existing comments, making it self-documenting. Specify this to avoid someone implementing it as a manual echo list that will drift.

- [ ] **Concern: The plan adds `frontend/README.md` to the init script rename loop, but the content of that README will contain "AIpoweredMakers" (as per Step 2). However, it also likely contains references to `pnpm`, `localhost:3000`, etc. that should NOT be renamed. The plan should clarify exactly which strings in the frontend README are placeholder vs fixed content.** Examining the backend README, it uses "AIpoweredMakers" in the title (`# Backend -- AIpoweredMakers API`). The frontend README should follow the same pattern -- only the title contains the project name. This should be made explicit.

## Suggestions (NICE TO HAVE)

- The frontend example should include a simple error boundary or at least a clear empty state when the backend is not running. A message like "Could not connect to API -- is the backend running? See backend/README.md" would be vastly more helpful than a generic error or loading spinner that never resolves. This is a starter-kit -- the most common state is "frontend running, backend not started yet."

- Consider adding a `.env.local.example` or at minimum documenting `NEXT_PUBLIC_API_URL` in the frontend README's environment variables section. The `apiFetch` function defaults to `http://localhost:8000`, which is fine for development, but new developers should know this is configurable.

- The root README's Quick Start says `make init -> make setup -> backend start -> frontend start`. Consider whether the root Makefile should also have `make dev` that starts both backend and frontend concurrently (e.g., using `concurrently` or separate terminals instruction). This is out of scope for this plan, but worth noting for the README: don't promise a smooth workflow that requires the developer to open three terminals without telling them.

- The `types.ts` file should include a note or comment showing the correspondence with `backend/features/items/schema.py`. This is a starter-kit -- making the relationship between Pydantic schemas and TypeScript types explicit is more valuable than saving two lines.

## Questions

- Is the backend Items feature intended to be deleted by the init script, or kept as a reference implementation? The init script currently keeps it. If the frontend Items feature is added but the backend one is deleted during init, the frontend example breaks immediately. If both survive, are they meant to be the "starter example" that developers build on? This needs an explicit decision.

- The `item-list.tsx` component: should it also demonstrate the `useCreateItem` mutation hook (e.g., a simple form), or just the read-only list? The plan's pseudocode mentions `useCreateItem()` in `api.ts` but the component only shows a list. If the hook is created but never used in any component, it is dead code in the example -- which is a bad signal in a starter-kit.

- Does `pnpm build` currently pass? With the existing static page.tsx it should, but the plan should verify this is the case before modifying page.tsx, so there is a known-good baseline.

## What's Good

- The problem statement is accurate and well-diagnosed. The asymmetry between backend and frontend quality is real and measurable.
- The scope boundary is clearly drawn: "Only fix onboarding documentation and add minimal working examples. No new features, no architectural changes." This discipline is good.
- The plan correctly identifies all existing infrastructure to reuse (`apiFetch`, `QueryProvider`, shadcn components) rather than creating new infrastructure.
- The file table is clear and the rollback plan is realistic. These are additive changes that are genuinely easy to revert.
- Following the backend's pattern (colocated feature with types, API layer, components) creates consistency that will scale.
- The testing strategy includes both manual full-stack verification and automated checks.

## Verdict

**APPROVED WITH CHANGES**

The plan's direction is correct and the scope is well-defined. The three critical issues must be addressed before implementation: (1) specify how the frontend example behaves when the backend is not running, particularly during `pnpm build` and SSR; (2) make an explicit decision about whether `frontend/src/features/items/` survives `make init` and update the init script accordingly; (3) replace the pseudocode in Step 3 with actual API paths and enough implementation detail to avoid "it doesn't work" on first try. The concerns about test strategy and CORS verification are important but can be addressed during implementation with good judgment.
