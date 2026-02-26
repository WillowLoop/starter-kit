"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useCreateItem } from "../api";

const itemCreateSchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().optional(),
});

type ItemCreateFormValues = z.infer<typeof itemCreateSchema>;

export function ItemCreateForm() {
  const createItem = useCreateItem();
  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<ItemCreateFormValues>({
    resolver: zodResolver(itemCreateSchema),
    defaultValues: { name: "", description: "" },
  });

  const onSubmit = (data: ItemCreateFormValues) => {
    createItem.mutate(data, {
      onSuccess: () => reset(),
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="name">Name</Label>
        <Input
          id="name"
          placeholder="Item name"
          aria-invalid={!!errors.name}
          aria-describedby={errors.name ? "name-error" : undefined}
          {...register("name")}
        />
        {errors.name && (
          <p id="name-error" className="text-destructive text-sm">
            {errors.name.message}
          </p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="description">Description</Label>
        <Input
          id="description"
          placeholder="Optional description"
          aria-invalid={!!errors.description}
          aria-describedby={
            errors.description ? "description-error" : undefined
          }
          {...register("description")}
        />
        {errors.description && (
          <p id="description-error" className="text-destructive text-sm">
            {errors.description.message}
          </p>
        )}
      </div>

      <Button type="submit" disabled={createItem.isPending} className="w-full">
        {createItem.isPending ? "Creating..." : "Create item"}
      </Button>

      {createItem.isError && (
        <p className="text-destructive text-sm">
          {createItem.error instanceof Error
            ? createItem.error.message
            : "Failed to create item"}
        </p>
      )}
    </form>
  );
}
