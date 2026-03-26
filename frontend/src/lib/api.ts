import { sanitizeErrorMessage } from "./error-handling";

const BASE_URL =
  process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

export async function apiFetch<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...init?.headers,
    },
    ...init,
  });

  if (!response.ok) {
    // Try to extract error detail from FastAPI JSON response
    let detail: string | undefined;
    try {
      const body: unknown = await response.json();
      if (
        typeof body === "object" &&
        body !== null &&
        "detail" in body
      ) {
        detail = String((body as Record<string, unknown>).detail);
      }
    } catch {
      // Response body not JSON — use status text
    }

    const rawMessage = detail ?? `${response.status} ${response.statusText}`;
    throw new Error(sanitizeErrorMessage(rawMessage));
  }

  return response.json() as Promise<T>;
}
