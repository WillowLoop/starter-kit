/**
 * Input validation and sanitization utilities.
 *
 * IMPORTANT: This module is a UX defense-in-depth layer that shows user-friendly
 * error messages for suspicious input. It is NOT a security boundary — attackers
 * bypass the frontend entirely. The real protection lives in the backend:
 * Pydantic validation + SQLAlchemy parameterized queries.
 */

import { z } from "zod";

// ---------------------------------------------------------------------------
// Dangerous pattern detection (UX warnings, not security enforcement)
// ---------------------------------------------------------------------------

// Note: No /g flag on patterns — .test() only needs to find one match.
// Using /g with .test() causes lastIndex bugs on repeated calls.
const DANGEROUS_PATTERNS = {
  SQL_INJECTION: [
    /\b(union|select|insert|update|delete|drop|create|alter|exec|execute|sp_|xp_)\b/i,
    /(\s*(;|'|"|--|\*\/)\s*)/,
    /0x[0-9a-f]+/i,
    /char\s*\(\s*\d+\s*\)/i,
  ],
  XSS: [
    /<script[\s\S]*?>[\s\S]*?<\/script>/i,
    /<iframe[\s\S]*?>[\s\S]*?<\/iframe>/i,
    /<object[\s\S]*?>[\s\S]*?<\/object>/i,
    /<embed[\s\S]*?>[\s\S]*?<\/embed>/i,
    /<link[\s\S]*?>/i,
    /<style[\s\S]*?>[\s\S]*?<\/style>/i,
    /javascript:/i,
    /vbscript:/i,
    /on\w+\s*=/i,
  ],
  COMMAND_INJECTION: [
    /(\||&|;|`|\$\(|\${)/,
    /\b(nc|netcat|curl|wget|ping|nslookup|dig)\b/i,
    /\b(rm|cat|ls|ps|kill|chmod|chown|sudo)\b/i,
  ],
  PATH_TRAVERSAL: [/\.\.[/\\]/, /%2e%2e[/\\]/i, /\.\.[%2f%5c]/i],
  LDAP_INJECTION: [/[*()\\/]/],
} as const;

/**
 * Check if input contains patterns commonly associated with injection attacks.
 * Returns true if dangerous patterns are found.
 */
export function containsDangerousPatterns(input: string): boolean {
  const allPatterns = [
    ...DANGEROUS_PATTERNS.SQL_INJECTION,
    ...DANGEROUS_PATTERNS.XSS,
    ...DANGEROUS_PATTERNS.COMMAND_INJECTION,
    ...DANGEROUS_PATTERNS.PATH_TRAVERSAL,
    ...DANGEROUS_PATTERNS.LDAP_INJECTION,
  ];

  return allPatterns.some((pattern) => pattern.test(input));
}

// ---------------------------------------------------------------------------
// Sanitization functions
// ---------------------------------------------------------------------------

/** Remove null bytes, dangerous Unicode control characters, and XSS patterns. */
export function sanitizeString(input: string): string {
  if (typeof input !== "string") {
    throw new Error("Input must be a string");
  }

  let sanitized = input;

  // Remove null bytes
  sanitized = sanitized.replace(/\x00/g, "");

  // Remove dangerous Unicode control characters
  sanitized = sanitized.replace(/[\u0000-\u001f\u007f-\u009f]/g, "");

  // Remove XSS patterns
  sanitized = sanitized.replace(/<script[\s\S]*?>[\s\S]*?<\/script>/gi, "");
  sanitized = sanitized.replace(/<iframe[\s\S]*?>[\s\S]*?<\/iframe>/gi, "");
  sanitized = sanitized.replace(/<object[\s\S]*?>[\s\S]*?<\/object>/gi, "");
  sanitized = sanitized.replace(/<embed[\s\S]*?>[\s\S]*?<\/embed>/gi, "");
  sanitized = sanitized.replace(/javascript:/gi, "");
  sanitized = sanitized.replace(/vbscript:/gi, "");
  sanitized = sanitized.replace(/on\w+\s*=/gi, "");

  return sanitized.trim();
}

/** Remove path separators, leading dots, and dangerous characters from filenames. */
export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[<>:"/\\|?*\x00-\x1f]/g, "")
    .replace(/^\.+/, "")
    .replace(/\.+$/, "")
    .trim()
    .substring(0, 255);
}

/** Lowercase, trim, and remove non-email characters. */
export function sanitizeEmail(email: string): string {
  return email
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9@._-]/g, "");
}

// ---------------------------------------------------------------------------
// Validation wrapper
// ---------------------------------------------------------------------------

/**
 * Parse and validate input against a Zod schema.
 * Throws with grouped, user-friendly error messages on failure.
 */
export function validateInput<T>(schema: z.ZodType<T>, input: unknown): T {
  try {
    return schema.parse(input);
  } catch (error) {
    if (error instanceof z.ZodError) {
      if (error.issues.length > 0) {
        const errorsByField: Record<string, string[]> = {};

        error.issues.forEach((issue) => {
          const fieldName =
            issue.path.length > 0 ? String(issue.path[0]) : "general";
          const existing = errorsByField[fieldName];
          if (existing) {
            existing.push(issue.message);
          } else {
            errorsByField[fieldName] = [issue.message];
          }
        });

        const errorMessages: string[] = [];
        for (const [, messages] of Object.entries(errorsByField)) {
          errorMessages.push(...messages);
        }

        throw new Error(errorMessages.join("\n"));
      }

      throw new Error("Please check your input and try again");
    }

    throw new Error(
      "Input validation failed. Please check your input and try again."
    );
  }
}
