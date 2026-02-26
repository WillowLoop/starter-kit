import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { ItemList } from "./item-list";

const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

afterEach(() => {
  mockFetch.mockReset();
});

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

describe("ItemList", () => {
  it("shows loading state initially", () => {
    mockFetch.mockReturnValue(new Promise(() => {}));

    render(<ItemList />, { wrapper: createWrapper() });

    const skeletons = document.querySelectorAll(".animate-pulse");
    expect(skeletons.length).toBeGreaterThan(0);
  });

  it("shows items when API returns data", async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: () =>
        Promise.resolve({
          items: [
            {
              id: "123",
              name: "Test Item",
              description: "A test item",
              created_at: "2024-01-01T00:00:00Z",
              updated_at: "2024-01-01T00:00:00Z",
            },
          ],
          total: 1,
        }),
    });

    render(<ItemList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("Test Item")).toBeInTheDocument();
    });
    expect(screen.getByText("A test item")).toBeInTheDocument();
  });

  it("shows empty message when API returns no items", async () => {
    mockFetch.mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ items: [], total: 0 }),
    });

    render(<ItemList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(screen.getByText("No items yet")).toBeInTheDocument();
    });
  });

  it("shows connection error when fetch fails", async () => {
    mockFetch.mockRejectedValue(new TypeError("Failed to fetch"));

    render(<ItemList />, { wrapper: createWrapper() });

    await waitFor(() => {
      expect(
        screen.getByText("Could not connect to API"),
      ).toBeInTheDocument();
    });
  });
});
