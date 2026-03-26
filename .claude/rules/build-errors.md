# Common Build Error Fixes

## ESLint/React
- Unescaped `'` in JSX: use `&apos;` or wrap in `{"`}
- Unescaped `"` in JSX: use `&quot;`

## Next.js 15+ Async Params
- `params` and `searchParams` are async — always `await` them
- Type as `Promise<{ id: string }>`, not `{ id: string }`

## TypeScript
- Always use `catch (error: unknown)` and narrow with `instanceof Error`
- Never use `as any` — use type guards or `satisfies`
- Prefer `null` over `undefined` for explicit absence; be consistent per module
- Third-party types: install `@types/pkg` or declare module in `types/`

## Forms and Input
- Controlled inputs: never pass `null` as value — use `""` for empty string
- Number inputs: parse with `Number()` or Zod, handle `NaN`

## Async/Promises
- `async` functions always return `Promise<T>` — callers must `await` or handle
- Never fire-and-forget: always handle rejections

## Arrays/Objects
- With `noUncheckedIndexedAccess`: use optional chaining (`arr[0]?.prop`) or length guards
- Never use non-null assertion (`!`) on indexed access

## Error Handling
- Generic error messages to clients; full details in server logs only
- Wrap external API calls in try/catch with typed error responses
