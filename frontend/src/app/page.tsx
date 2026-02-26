import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ItemCreateForm, ItemList } from "@/features/items";

// ItemList is a Client Component — useQuery does NOT execute during SSR/build.
// The page renders a loading skeleton server-side, then hydrates and fetches
// client-side. No prefetchQuery/HydrationBoundary needed for this minimal example.

export default function Home() {
  return (
    <main className="flex min-h-screen items-center justify-center p-8">
      <Card className="w-full max-w-lg">
        <CardHeader>
          <CardTitle>AIpoweredMakers</CardTitle>
          <CardDescription>
            Full-stack starter kit: Next.js + FastAPI + PostgreSQL.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          <ItemCreateForm />
          <hr />
          <div>
            <h2 className="mb-3 text-sm font-medium">Items</h2>
            <ItemList />
          </div>
        </CardContent>
      </Card>
    </main>
  );
}
