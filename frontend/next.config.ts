import type { NextConfig } from "next";
import { withSentryConfig } from "@sentry/nextjs";

const nextConfig: NextConfig = {
  /* config options here */
};

export default withSentryConfig(nextConfig, {
  // Source map upload disabled by default — requires SENTRY_AUTH_TOKEN in CI
  sourcemaps: {
    disable: true,
  },
  // Automatically tree-shake Sentry debug logging to reduce bundle size
  bundleSizeOptimizations: {
    excludeDebugStatements: true,
  },
  // Suppress Sentry CLI warnings when no auth token is set
  silent: true,
});
