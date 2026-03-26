# HTTP Security Headers Checklist

Reference for `security-config-scan` Step 1. Cross-reference with `frontend/next.config.ts`.

## Required headers

| Header | Expected Value | Severity if Missing | Notes |
|---|---|---|---|
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains; preload` | HIGH | HSTS — forces HTTPS. `max-age` should be ≥ 1 year (31536000) |
| `X-Content-Type-Options` | `nosniff` | MEDIUM | Prevents MIME type sniffing |
| `X-Frame-Options` | `DENY` or `SAMEORIGIN` | MEDIUM | Clickjacking protection |
| `Referrer-Policy` | `strict-origin-when-cross-origin` or stricter | LOW | Controls referer header leakage |
| `X-DNS-Prefetch-Control` | `off` | LOW | Prevents DNS prefetch privacy leaks |

## Content Security Policy

CSP is the most complex header. Analyze each directive:

| Directive | Ideal | Flag if |
|---|---|---|
| `default-src` | `'self'` | `*` or missing |
| `script-src` | `'self'` | `'unsafe-inline'` (MEDIUM), `'unsafe-eval'` (HIGH) |
| `style-src` | `'self' 'unsafe-inline'` | `'unsafe-inline'` is common but note it |
| `img-src` | `'self' data:` + CDN domains | `*` |
| `connect-src` | `'self'` + API domains | `*` |
| `font-src` | `'self'` + font CDNs | `*` |
| `frame-ancestors` | `'none'` or `'self'` | `*` or missing |
| `base-uri` | `'self'` | missing |
| `form-action` | `'self'` | missing or `*` |
| `upgrade-insecure-requests` | present | missing |

**Notes on CSP**:
- `'unsafe-inline'` in `script-src` = MEDIUM — required by some frameworks but weakens XSS protection
- `'unsafe-eval'` in `script-src` = HIGH — allows `eval()`, significant XSS risk
- Nonce-based CSP (`'nonce-xxx'`) is preferred over `'unsafe-inline'`
- `report-uri` or `report-to` is recommended for monitoring violations

## Recommended additional headers

| Header | Expected Value | Severity if Missing | Notes |
|---|---|---|---|
| `Permissions-Policy` | Restrict camera, microphone, geolocation, etc. | MEDIUM | Controls browser feature access |
| `Cross-Origin-Opener-Policy` | `same-origin` | LOW | Isolates browsing context |
| `Cross-Origin-Resource-Policy` | `same-origin` or `same-site` | LOW | Controls resource sharing |
| `Cross-Origin-Embedder-Policy` | `require-corp` | LOW | Required for SharedArrayBuffer |

### Permissions-Policy example

```
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
```

Disables access to sensitive browser APIs unless explicitly needed.

## Next.js specific

In Next.js, headers are configured in `next.config.ts`:

```typescript
async headers() {
  return [
    {
      source: "/(.*)",
      headers: [
        { key: "X-Content-Type-Options", value: "nosniff" },
        { key: "X-Frame-Options", value: "DENY" },
        // ...
      ],
    },
  ]
}
```

Check that headers apply to all routes (`/(.*)`), not just specific paths.
