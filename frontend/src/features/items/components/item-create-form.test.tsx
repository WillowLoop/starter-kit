import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { ItemCreateForm } from "./item-create-form";

const mockFetch = vi.fn();
vi.stubGlobal("fetch", mockFetch);

afterEach(() => {
  mockFetch.mockReset();
});

function createWrapper() {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
    );
  };
}

describe("ItemCreateForm", () => {
  it("renders form fields and submit button", () => {
    render(<ItemCreateForm />, { wrapper: createWrapper() });

    expect(screen.getByLabelText("Name")).toBeInTheDocument();
    expect(screen.getByLabelText("Description")).toBeInTheDocument();
    expect(
      screen.getByRole("button", { name: "Create item" }),
    ).toBeInTheDocument();
  });

  it("shows validation error when submitting empty name", async () => {
    const user = userEvent.setup();
    render(<ItemCreateForm />, { wrapper: createWrapper() });

    await user.click(screen.getByRole("button", { name: "Create item" }));

    await waitFor(() => {
      expect(screen.getByText("Name is required")).toBeInTheDocument();
    });
    expect(mockFetch).not.toHaveBeenCalled();
  });

  it("submits successfully and clears form", async () => {
    const user = userEvent.setup();
    mockFetch.mockResolvedValue({
      ok: true,
      json: () =>
        Promise.resolve({
          id: "123",
          name: "New Item",
          description: null,
          created_at: "2024-01-01T00:00:00Z",
          updated_at: "2024-01-01T00:00:00Z",
        }),
    });

    render(<ItemCreateForm />, { wrapper: createWrapper() });

    const nameInput = screen.getByLabelText("Name");
    await user.type(nameInput, "New Item");
    await user.click(screen.getByRole("button", { name: "Create item" }));

    await waitFor(() => {
      expect(nameInput).toHaveValue("");
    });
  });

  it("shows API error on failure", async () => {
    const user = userEvent.setup();
    mockFetch.mockResolvedValue({
      ok: false,
      status: 500,
      statusText: "Internal Server Error",
    });

    render(<ItemCreateForm />, { wrapper: createWrapper() });

    await user.type(screen.getByLabelText("Name"), "Fail Item");
    await user.click(screen.getByRole("button", { name: "Create item" }));

    await waitFor(() => {
      expect(
        screen.getByText("API error: 500 Internal Server Error"),
      ).toBeInTheDocument();
    });
  });
});
