# Crawler Blocking Reference

Reference for `security-exposure-scan` Steps 1-2.

## robots.txt template

Complete template blocking known AI crawlers and protecting sensitive paths:

```
# Search engines — allow indexing of public pages
User-agent: Googlebot
Allow: /

User-agent: Bingbot
Allow: /

# Block all AI training crawlers
User-agent: GPTBot
Disallow: /

User-agent: ChatGPT-User
Disallow: /

User-agent: CCBot
Disallow: /

User-agent: anthropic-ai
Disallow: /

User-agent: ClaudeBot
Disallow: /

User-agent: Claude-Web
Disallow: /

User-agent: Google-Extended
Disallow: /

User-agent: Bytespider
Disallow: /

User-agent: Applebot-Extended
Disallow: /

User-agent: PerplexityBot
Disallow: /

User-agent: YouBot
Disallow: /

User-agent: Amazonbot
Disallow: /

User-agent: Diffbot
Disallow: /

User-agent: FacebookBot
Disallow: /

User-agent: Omgilibot
Disallow: /

User-agent: Timpibot
Disallow: /

# Block sensitive paths for all crawlers
User-agent: *
Disallow: /api/
Disallow: /admin/
Disallow: /_next/
Disallow: /auth/

# Sitemap
Sitemap: https://example.com/sitemap.xml
```

## Known AI crawlers

| User Agent | Operator | Purpose |
|---|---|---|
| GPTBot | OpenAI | Training data collection |
| ChatGPT-User | OpenAI | ChatGPT browsing feature |
| CCBot | Common Crawl | Open dataset (used by many AI models) |
| anthropic-ai | Anthropic | Training data collection |
| ClaudeBot | Anthropic | Claude browsing feature |
| Claude-Web | Anthropic | Claude web access |
| Google-Extended | Google | Gemini/Bard training |
| Bytespider | ByteDance | TikTok/AI training |
| Applebot-Extended | Apple | Apple Intelligence training |
| PerplexityBot | Perplexity AI | AI search engine |
| YouBot | You.com | AI search engine |
| Amazonbot | Amazon | Alexa/AI training |
| Diffbot | Diffbot | Web data extraction |
| FacebookBot | Meta | AI training |
| Omgilibot | Omgili | Blog/forum scraping |
| Timpibot | Timpi | Decentralized search |

## Meta robots tags

For pages that need more granular control:

```html
<!-- Block all indexing -->
<meta name="robots" content="noindex, nofollow">

<!-- Allow indexing but block AI training -->
<meta name="robots" content="noai, noimageai">
```

## X-Robots-Tag header

For API routes and non-HTML responses:

```
X-Robots-Tag: noindex, nofollow
```

In Next.js, add to API route headers or middleware.

## Important notes

- `robots.txt` is **advisory** — it is NOT a security boundary
- Malicious crawlers will ignore robots.txt
- For true access control, use authentication and rate limiting
- robots.txt itself should not contain sensitive path information that reveals internal structure
- Monitor access logs for crawlers ignoring robots.txt rules
