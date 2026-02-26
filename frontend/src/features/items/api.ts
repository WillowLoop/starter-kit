import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "@/lib/api";
import type { Item, ItemCreate, ItemListResponse } from "./types";

export function useItems() {
  return useQuery({
    queryKey: ["items"],
    queryFn: () => apiFetch<ItemListResponse>("/api/v1/items"),
    // Disable retry so connection failures show immediately instead of
    // silently retrying 3x (TanStack Query default). Intentional for
    // onboarding UX — don't remove without updating error state handling.
    retry: false,
  });
}

export function useCreateItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: ItemCreate) =>
      apiFetch<Item>("/api/v1/items", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["items"] });
    },
  });
}
