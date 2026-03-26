import { describe, it, expect, vi } from "vitest";
import {
  sanitizeErrorMessage,
  handleSecureError,
  SAFE_ERROR_MESSAGES,
} from "./error-handling";

describe("sanitizeErrorMessage", () => {
  it("returns generic error for null/undefined", () => {
    expect(sanitizeErrorMessage(null)).toBe(SAFE_ERROR_MESSAGES.GENERIC_ERROR);
    expect(sanitizeErrorMessage(undefined)).toBe(
      SAFE_ERROR_MESSAGES.GENERIC_ERROR
    );
  });

  it("handles string errors", () => {
    expect(sanitizeErrorMessage("too many requests")).toBe(
      SAFE_ERROR_MESSAGES.RATE_LIMIT_EXCEEDED
    );
  });

  it("handles Error instances", () => {
    expect(sanitizeErrorMessage(new Error("too many requests"))).toBe(
      SAFE_ERROR_MESSAGES.RATE_LIMIT_EXCEEDED
    );
  });

  it("handles objects with message property", () => {
    expect(sanitizeErrorMessage({ message: "too many requests" })).toBe(
      SAFE_ERROR_MESSAGES.RATE_LIMIT_EXCEEDED
    );
  });

  it("returns generic error for non-error objects", () => {
    expect(sanitizeErrorMessage(42)).toBe(SAFE_ERROR_MESSAGES.GENERIC_ERROR);
  });

  // Validation errors preserved
  it("preserves validation error messages", () => {
    expect(sanitizeErrorMessage("Name is required")).toBe("Name is required");
    expect(sanitizeErrorMessage("Must contain at least 8 characters")).toBe(
      "Must contain at least 8 characters"
    );
  });

  // Auth errors
  it("maps auth errors to safe messages", () => {
    expect(sanitizeErrorMessage("invalid credentials")).toBe(
      SAFE_ERROR_MESSAGES.INVALID_CREDENTIALS
    );
  });

  it("maps session errors", () => {
    expect(sanitizeErrorMessage("session expired")).toBe(
      SAFE_ERROR_MESSAGES.SESSION_EXPIRED
    );
  });

  it("maps authorization errors", () => {
    expect(sanitizeErrorMessage("access denied")).toBe(
      SAFE_ERROR_MESSAGES.UNAUTHORIZED
    );
    expect(sanitizeErrorMessage("403 Forbidden")).toBe(
      SAFE_ERROR_MESSAGES.UNAUTHORIZED
    );
  });

  // FastAPI-specific
  it("maps FastAPI validation errors", () => {
    expect(sanitizeErrorMessage("validation error for body")).toBe(
      SAFE_ERROR_MESSAGES.INVALID_INPUT
    );
    expect(sanitizeErrorMessage("value_error.missing")).toBe(
      SAFE_ERROR_MESSAGES.INVALID_INPUT
    );
  });

  it("maps connection refused to network error", () => {
    expect(sanitizeErrorMessage("connection refused")).toBe(
      SAFE_ERROR_MESSAGES.NETWORK_ERROR
    );
    expect(sanitizeErrorMessage("ECONNREFUSED")).toBe(
      SAFE_ERROR_MESSAGES.NETWORK_ERROR
    );
  });

  // Database errors
  it("maps database errors", () => {
    expect(sanitizeErrorMessage("database connection failed")).toBe(
      SAFE_ERROR_MESSAGES.DATABASE_ERROR
    );
  });

  // Sensitive pattern detection
  it("suppresses errors containing sensitive patterns", () => {
    expect(sanitizeErrorMessage("sqlalchemy.exc.OperationalError")).toBe(
      SAFE_ERROR_MESSAGES.SERVER_ERROR
    );
    expect(sanitizeErrorMessage("NEXT_PUBLIC_API_URL is undefined")).toBe(
      SAFE_ERROR_MESSAGES.SERVER_ERROR
    );
    expect(sanitizeErrorMessage("process.env.SECRET_KEY")).toBe(
      SAFE_ERROR_MESSAGES.SERVER_ERROR
    );
    expect(sanitizeErrorMessage("uvicorn error on startup")).toBe(
      SAFE_ERROR_MESSAGES.SERVER_ERROR
    );
  });

  // Safe passthrough
  it("passes through short safe messages", () => {
    expect(sanitizeErrorMessage("Item already exists")).toBe(
      "Item already exists"
    );
  });

  // Generic fallback
  it("falls back to generic for long technical messages", () => {
    const longError =
      "TypeError: Cannot read properties of undefined (reading 'map') at /app/src/components/List.tsx:42";
    expect(sanitizeErrorMessage(longError)).toBe(
      SAFE_ERROR_MESSAGES.GENERIC_ERROR
    );
  });
});

describe("handleSecureError", () => {
  it("returns success: false with sanitized error", () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    const result = handleSecureError(new Error("database connection failed"));
    expect(result).toEqual({
      success: false,
      error: SAFE_ERROR_MESSAGES.DATABASE_ERROR,
    });

    consoleSpy.mockRestore();
  });

  it("logs full error details to console", () => {
    const consoleSpy = vi.spyOn(console, "error").mockImplementation(() => {});

    handleSecureError(new Error("secret leak"), "test-context");

    expect(consoleSpy).toHaveBeenCalledWith(
      "Secure error handler:",
      expect.objectContaining({
        context: "test-context",
        error: expect.objectContaining({
          message: "secret leak",
        }),
      })
    );

    consoleSpy.mockRestore();
  });
});
