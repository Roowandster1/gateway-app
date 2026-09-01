import { filtersOnly, type SolveRequest } from "@/lib/solver";

/**
 * How many recipes survive the dietary answers. No solve happens behind this,
 * so the onboarding's live counter costs nothing — asking /floor for the same
 * number meant a full set of CBC runs on every tap, which with 338 recipes was
 * 25 seconds to report a set intersection.
 */
export async function POST(request: Request) {
  const body = (await request.json()) as SolveRequest;
  try {
    return Response.json(await filtersOnly(body));
  } catch {
    return Response.json(
      { status: "error", detail: "The solver service is not reachable." },
      { status: 502 },
    );
  }
}
