/**
 * Secure error handling utilities to prevent information disclosure.
 *
 * Sanitizes error messages before they reach the UI, mapping internal
 * details (stack traces, DB errors, framework internals) to safe,
 * user-friendly messages.
 */

// Safe error messages that don't expose system internals
export const SAFE_ERROR_MESSAGES = {
  INVALID_CREDENTIALS: "Invalid email or password",
  ACCOUNT_LOCKED: "Account temporarily locked. Please try again later",
  SESSION_EXPIRED: "Your session has expired. Please sign in again",
  UNAUTHORIZED: "You are not authorized to perform this action",

  INVALID_INPUT: "Please check your input and try again",
  REQUIRED_FIELD: "All required fields must be filled",

  OPERATION_FAILED:
    "The operation could not be completed. Please try again",
  USER_NOT_FOUND: "User not found",
  FILE_UPLOAD_FAILED:
    "File upload failed. Please check your file and try again",

  DATABASE_ERROR: "A database error occurred. Please try again later",
  NETWORK_ERROR:
    "Network error. Please check your connection and try again",
  SERVER_ERROR: "An internal server error occurred. Please try again later",
  SERVICE_UNAVAILABLE:
    "Service temporarily unavailable. Please try again later",

  RATE_LIMIT_EXCEEDED: "Too many requests. Please wait and try again",

  GENERIC_ERROR: "An unexpected error occurred. Please try again",
} as const;

// Patterns that indicate sensitive information in error messages
const SENSITIVE_PATTERNS = [
  /password/i,
  /token/i,
  /\bkey\b/i,
  /secret/i,
  /database/i,
  /\bsql\b/i,
  /connection/i,
  /\bport\b/i,
  /\bhost\b/i,
  /internal/i,
  /stack/i,
  /trace/i,
  /debug/i,
  /sqlalchemy/i,
  /uvicorn/i,
  /pydantic/i,
  /fastapi/i,
  /postgres/i,
  /\.env/i,
  /config/i,
  /NEXT_/i,
  /process\.env/i,
];

/**
 * Sanitize an error into a user-safe message.
 * Preserves validation errors (user-facing), maps known patterns to safe
 * messages, and falls back to a generic message for anything else.
 */
export function sanitizeErrorMessage(error: unknown): string {
  if (!error) {
    return SAFE_ERROR_MESSAGES.GENERIC_ERROR;
  }

  let errorMessage: string;

  if (typeof error === "string") {
    errorMessage = error;
  } else if (error instanceof Error) {
    errorMessage = error.message;
  } else if (
    typeof error === "object" &&
    error !== null &&
    "message" in error
  ) {
    errorMessage = String((error as Record<string, unknown>).message);
  } else {
    return SAFE_ERROR_MESSAGES.GENERIC_ERROR;
  }

  const lower = errorMessage.toLowerCase();

  // Validation errors — preserve as-is (user-facing and helpful)
  if (
    lower.includes("is required") ||
    lower.includes("must contain") ||
    lower.includes("must not exceed") ||
    lower.includes("at least") ||
    lower.includes("validation failed") ||
    lower.includes("please check your")
  ) {
    return errorMessage;
  }

  // Authentication
  if (
    lower.includes("invalid email or password") ||
    lower.includes("invalid credentials")
  ) {
    return SAFE_ERROR_MESSAGES.INVALID_CREDENTIALS;
  }

  // Rate limiting
  if (lower.includes("too many requests") || lower.includes("rate limit")) {
    return SAFE_ERROR_MESSAGES.RATE_LIMIT_EXCEEDED;
  }

  // User not found
  if (lower.includes("user not found") || lower.includes("no user found")) {
    return SAFE_ERROR_MESSAGES.USER_NOT_FOUND;
  }

  // Session
  if (
    lower.includes("session") &&
    (lower.includes("expired") || lower.includes("invalid"))
  ) {
    return SAFE_ERROR_MESSAGES.SESSION_EXPIRED;
  }

  // Authorization
  if (
    lower.includes("unauthorized") ||
    lower.includes("access denied") ||
    lower.includes("permission denied") ||
    lower.includes("403")
  ) {
    return SAFE_ERROR_MESSAGES.UNAUTHORIZED;
  }

  // FastAPI validation errors (422 Unprocessable Entity)
  if (lower.includes("validation error") || lower.includes("value_error")) {
    return SAFE_ERROR_MESSAGES.INVALID_INPUT;
  }

  // Network / connection errors (including backend down)
  if (
    lower.includes("network") ||
    lower.includes("fetch") ||
    lower.includes("connection refused") ||
    lower.includes("econnrefused")
  ) {
    return SAFE_ERROR_MESSAGES.NETWORK_ERROR;
  }

  // Database
  if (lower.includes("database") || lower.includes("timeout")) {
    return SAFE_ERROR_MESSAGES.DATABASE_ERROR;
  }

  // Service unavailable
  if (lower.includes("service unavailable") || lower.includes("503")) {
    return SAFE_ERROR_MESSAGES.SERVICE_UNAVAILABLE;
  }

  // Check for sensitive patterns
  if (SENSITIVE_PATTERNS.some((pattern) => pattern.test(errorMessage))) {
    console.error(
      "[error-handling] Sensitive information detected in error, suppressed:",
      errorMessage
    );
    return SAFE_ERROR_MESSAGES.SERVER_ERROR;
  }

  // Short, non-technical messages can pass through
  if (
    errorMessage.length < 100 &&
    !errorMessage.includes("/") &&
    !errorMessage.includes("\\") &&
    !errorMessage.includes("Error:") &&
    !/[A-Z]{3,}/.test(errorMessage)
  ) {
    return errorMessage;
  }

  return SAFE_ERROR_MESSAGES.GENERIC_ERROR;
}

/**
 * Log full error details for debugging, return sanitized message for the UI.
 */
export function handleSecureError(
  error: unknown,
  context?: string
): { success: false; error: string } {
  console.error("Secure error handler:", {
    context,
    error:
      error instanceof Error
        ? { name: error.name, message: error.message, stack: error.stack }
        : error,
    timestamp: new Date().toISOString(),
  });

  return {
    success: false,
    error: sanitizeErrorMessage(error),
  };
}
