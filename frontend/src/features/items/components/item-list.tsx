"use client";

import { useItems } from "../api";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

export function ItemList() {
  const { data, error, isLoading } = useItems();

  if (isLoading) {
    return (
      <div className="space-y-3">
        {[1, 2, 3].map((i) => (
          <div
            key={i}
            className="bg-muted h-16 animate-pulse rounded-lg"
          />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Could not connect to API</CardTitle>
          <CardDescription>
            Could not reach the backend at{" "}
            <code className="bg-muted rounded px-1 py-0.5 text-xs">
              {process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000"}
            </code>
            . Is the backend running?
          </CardDescription>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground text-sm">
            Start the backend:
          </p>
          <pre className="bg-muted mt-2 rounded-lg p-3 text-sm">
            <code>cd backend && make dev</code>
          </pre>
        </CardContent>
      </Card>
    );
  }

  if (!data?.items.length) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="text-base">No items yet</CardTitle>
          <CardDescription>
            Use the form above to create your first item.
          </CardDescription>
        </CardHeader>
      </Card>
    );
  }

  return (
    <div className="space-y-3">
      {data.items.map((item) => (
        <Card key={item.id}>
          <CardHeader>
            <CardTitle className="text-base">{item.name}</CardTitle>
            {item.description && (
              <CardDescription>{item.description}</CardDescription>
            )}
          </CardHeader>
          <CardContent>
            <p className="text-muted-foreground text-xs">
              Created{" "}
              {new Date(item.created_at).toLocaleDateString()}
            </p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
