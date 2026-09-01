import { recipeMethods } from "@/lib/solver";

/** Cooking steps, keyed by recipe. Fetched once and cached by the browser. */
export async function GET() {
  try {
    return Response.json(await recipeMethods());
  } catch {
    return Response.json(
      { status: "error", detail: "The solver service is not reachable." },
      { status: 502 },
    );
  }
}
