import { catalogueItems } from "@/lib/solver";

/** The priced catalogue, for the cupboard screen. */
export async function GET(request: Request) {
  const store = new URL(request.url).searchParams.get("store") ?? "aldi";
  try {
    return Response.json(await catalogueItems(store));
  } catch {
    return Response.json(
      { status: "error", detail: "The solver service is not reachable." },
      { status: 502 },
    );
  }
}
