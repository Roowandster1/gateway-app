import { floor, type SolveRequest } from "@/lib/solver";

export async function POST(request: Request) {
  const body = (await request.json()) as SolveRequest;
  try {
    return Response.json(await floor(body));
  } catch {
    return Response.json(
      { status: "error", detail: "The solver service is not reachable." },
      { status: 502 },
    );
  }
}
