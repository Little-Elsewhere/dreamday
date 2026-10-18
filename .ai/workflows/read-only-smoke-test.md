# Read-only architecture smoke scenario

This reusable scenario validates role discovery and orchestration behavior. It is read-only and does not approve a feature or authorize implementation.

## Prompt

    From the DreamDay workspace root, perform a read-only architecture inventory for a possible collaborative trip itinerary with scheduled activities. This is discovery only: do not edit code, specs, handoffs, or configuration; do not run tests, start services, switch branches, or change Git state. First inspect root and submodule status and read applicable instructions. Treat existing product context as unverified.

    Delegate independent read-only analysis and wait for all results:
    - Architect: inspect workspace boundaries and approved specs; report architecture/API/data/infrastructure seams, uncertainty, and decisions requiring a human.
    - Frontend: inspect apps/frontend/ trip-related code and local instructions; report observed UI/data flow, paths/symbols, and gaps relative to the proposed capability. Do not edit.
    - Backend: inspect apps/backend/ trip-related models, routes, services, and local instructions; report observed persistence/API behavior and gaps. Do not edit.
    - Reviewer: independently cross-check reports against code and approved specs; flag unsupported claims, contradictions, and security or scope risks. Do not edit.

    The orchestrator must state which findings are observed, inferred, or unknown; cite paths and symbols; identify affected repositories; and recommend the next documentation-first step. Do not create or update a Spec Kit feature unless separately requested.

## Assignment and expected output

The four tasks are independent reads with separate repository/file ownership; Reviewer cross-checks after the other reports return. The final report includes repository state, evidence, feature status (implemented, partial, planned, unknown), interface/data dependencies, risks, open product questions, and a recommended Spec Kit action.

## Validation boundary

A written prompt is a prepared scenario, not runtime proof. If a tool run is authorized and inexpensive, record the tool/version, agents actually spawned, actual outputs, and any unavailable adapter. Never claim this scenario ran without runtime evidence.
