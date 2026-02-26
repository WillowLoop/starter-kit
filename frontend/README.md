# Frontend — AIpoweredMakers

Next.js 16 web app with TypeScript, Tailwind CSS and shadcn/ui.

## Prerequisites

- Node.js 22+
- [pnpm](https://pnpm.io/)

## Quick Start

```bash
# Install dependencies
pnpm install

# Start development server (hot reload)
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

The Items page fetches data from the backend API (`http://localhost:8000` by default). The frontend works without the backend, but will show a connection message.

## Scripts

| Command | Description |
|---|---|
| `pnpm dev` | Development server with hot reload |
| `pnpm build` | Production build |
| `pnpm start` | Production server |
| `pnpm lint` | Linting with ESLint |
| `pnpm test` | Run tests (Vitest) |
| `pnpm test:watch` | Tests in watch mode |
| `pnpm test:coverage` | Tests with coverage report |

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `NEXT_PUBLIC_API_URL` | Backend API URL | `http://localhost:8000` |

Copy `.env.example` only if you need a non-default URL:

```bash
cp .env.example .env.local
```

## Project Structure

```
frontend/
├── src/
│   ├── app/                → Routes, layouts, error boundaries
│   ├── components/
│   │   ├── ui/             → shadcn/ui components
│   │   └── providers/      → Context providers (QueryProvider)
│   ├── features/
│   │   └── items/          → Items example (components, api, types)
│   ├── hooks/              → Shared hooks
│   ├── lib/                → Utilities (cn, api client)
│   └── types/              → Cross-feature types
├── vitest.config.mts       → Test configuration
├── package.json            → Dependencies + scripts
└── tsconfig.json           → TypeScript configuration
```

## Conventions

See [frontend/CLAUDE.md](CLAUDE.md) for all rules and patterns.
