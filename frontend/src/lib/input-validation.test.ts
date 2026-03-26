import { describe, it, expect } from "vitest";
import { z } from "zod";
import {
  sanitizeString,
  sanitizeFilename,
  sanitizeEmail,
  containsDangerousPatterns,
  validateInput,
} from "./input-validation";

describe("sanitizeString", () => {
  it("trims whitespace", () => {
    expect(sanitizeString("  hello  ")).toBe("hello");
  });

  it("removes null bytes", () => {
    expect(sanitizeString("hello\x00world")).toBe("helloworld");
  });

  it("removes script tags", () => {
    expect(sanitizeString('<script>alert("xss")</script>')).toBe("");
  });

  it("removes iframe tags", () => {
    expect(sanitizeString('<iframe src="evil.com"></iframe>')).toBe("");
  });

  it("removes javascript: protocol", () => {
    expect(sanitizeString("javascript:alert(1)")).toBe("alert(1)");
  });

  it("throws on non-string input", () => {
    expect(() => sanitizeString(123 as unknown as string)).toThrow(
      "Input must be a string"
    );
  });

  it("removes event handlers", () => {
    expect(sanitizeString('onerror="alert(1)"')).toBe('"alert(1)"');
  });
});

describe("sanitizeFilename", () => {
  it("removes path separators", () => {
    expect(sanitizeFilename("../../etc/passwd")).toBe("etcpasswd");
  });

  it("removes leading dots", () => {
    expect(sanitizeFilename("..hidden")).toBe("hidden");
  });

  it("truncates to 255 characters", () => {
    const long = "a".repeat(300);
    expect(sanitizeFilename(long).length).toBe(255);
  });

  it("keeps valid filenames unchanged", () => {
    expect(sanitizeFilename("report-2024.pdf")).toBe("report-2024.pdf");
  });
});

describe("sanitizeEmail", () => {
  it("lowercases and trims", () => {
    expect(sanitizeEmail("  User@Example.COM  ")).toBe("user@example.com");
  });

  it("removes invalid characters", () => {
    expect(sanitizeEmail("user+tag@example.com")).toBe("usertag@example.com");
  });
});

describe("containsDangerousPatterns", () => {
  it("detects SQL injection keywords", () => {
    expect(containsDangerousPatterns("1 UNION SELECT * FROM users")).toBe(true);
  });

  it("detects XSS script tags", () => {
    expect(containsDangerousPatterns("<script>alert(1)</script>")).toBe(true);
  });

  it("detects command injection", () => {
    expect(containsDangerousPatterns("test; rm -rf /")).toBe(true);
  });

  it("detects path traversal", () => {
    expect(containsDangerousPatterns("../../etc/passwd")).toBe(true);
  });

  it("returns false for safe input", () => {
    expect(containsDangerousPatterns("Hello, this is normal text")).toBe(false);
  });

  it("returns consistent results on repeated calls (no lastIndex bug)", () => {
    const input = "DROP TABLE users";
    expect(containsDangerousPatterns(input)).toBe(true);
    expect(containsDangerousPatterns(input)).toBe(true);
    expect(containsDangerousPatterns(input)).toBe(true);
  });
});

describe("validateInput", () => {
  const nameSchema = z.string().min(1, "Name is required").max(50);

  it("returns parsed value on success", () => {
    expect(validateInput(nameSchema, "Alice")).toBe("Alice");
  });

  it("throws with user-friendly message on failure", () => {
    expect(() => validateInput(nameSchema, "")).toThrow("Name is required");
  });

  it("throws generic message for non-Zod errors", () => {
    const failSchema = z.string().refine(() => {
      throw new TypeError("unexpected");
    });
    expect(() => validateInput(failSchema, "test")).toThrow(
      "Input validation failed"
    );
  });
});
