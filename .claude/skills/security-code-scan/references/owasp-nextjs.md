# Next.js OWASP Vulnerability Patterns

Reference for Next.js-specific security patterns used by `security-code-scan`.

## Server Actions and CSRF

**Important**: Next.js 16 has built-in CSRF protection for Server Actions. Only flag as a vulnerability if:
- CSRF protection is explicitly disabled or bypassed
- Server Actions accept and process raw request objects without the framework's validation
- Custom API routes bypass Next.js middleware

```typescript
// SAFE — Next.js 16 handles CSRF automatically
"use server"
export async function updateProfile(formData: FormData) {
  // Built-in CSRF token validation
}

// WARN — only if CSRF protection is explicitly bypassed
```

## Server vs Client component data leakage

Data passed from Server Components to Client Components is serialized and visible in the HTML source:

```typescript
// UNSAFE — sensitive data passed to client component via props
// ServerComponent.tsx
export default async function Page() {
  const user = await getUser() // includes password_hash, internal_id
  return <ClientProfile user={user} /> // full object serialized to client
}

// SAFE — only pass needed fields
export default async function Page() {
  const user = await getUser()
  return <ClientProfile name={user.name} avatar={user.avatar} />
}
```

## eval() and Function() in client code

```typescript
// UNSAFE — arbitrary code execution
const result = eval(userInput)
const fn = new Function(userInput)

// WARN — template literals in eval
eval(`console.log("${userInput}")`)
```

Check both `.ts` and `.tsx` files in `frontend/src/`.

## Source maps in production

```typescript
// next.config.ts
// UNSAFE — exposes source code in production
productionBrowserSourceMaps: true

// SAFE — source maps disabled (default)
// productionBrowserSourceMaps is not set or false
```

## next/image remotePatterns

Overly permissive remote patterns allow loading images from any domain:

```typescript
// UNSAFE — wildcard allows any hostname
images: {
  remotePatterns: [{ protocol: 'https', hostname: '**' }]
}

// SAFE — specific domains
images: {
  remotePatterns: [
    { protocol: 'https', hostname: 'cdn.example.com' }
  ]
}
```

## NEXT_PUBLIC_ environment variables

Any variable prefixed with `NEXT_PUBLIC_` is exposed to the browser:

```
# UNSAFE — secret exposed to client
NEXT_PUBLIC_API_SECRET=sk-xxxxx
NEXT_PUBLIC_DATABASE_URL=postgresql://...

# SAFE — only public config
NEXT_PUBLIC_API_URL=https://api.example.com
NEXT_PUBLIC_APP_NAME=MyApp
```

Grep for `NEXT_PUBLIC_` in `.env*` files and verify no secrets are prefixed.

## Middleware bypass

Check that Next.js middleware (`middleware.ts`) cannot be bypassed:

```typescript
// WARN — middleware only matches specific paths, other paths unprotected
export const config = {
  matcher: ['/dashboard/:path*']
  // /api/admin/* is not covered
}
```

Verify middleware covers all protected routes.

## Open redirect via redirect()

```typescript
// UNSAFE — user-controlled redirect target
import { redirect } from 'next/navigation'

export async function action(formData: FormData) {
  const url = formData.get('returnUrl')
  redirect(url as string) // can redirect to malicious site
}

// SAFE — validate against allowlist
const ALLOWED_REDIRECTS = ['/dashboard', '/profile', '/settings']
if (ALLOWED_REDIRECTS.includes(url)) {
  redirect(url)
}
```

## Script injection via searchParams

```typescript
// UNSAFE — rendering search params without sanitization
export default function Page({ searchParams }: { searchParams: { q: string } }) {
  return <div dangerouslySetInnerHTML={{ __html: searchParams.q }} />
}
```

## Headers and security config

Check `next.config.ts` for security headers. See `security-config-scan` for detailed header analysis.
