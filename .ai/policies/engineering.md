# Engineering policy

## Evidence and scope

- Inspect current source, local instructions, and approved specifications before deciding how a feature works. Product context is not proof of implementation.
- Make the smallest coherent change within the authorized scope. Preserve unrelated user work and avoid unnecessary dependencies, frameworks, or runtime services.
- Root owns workspace infrastructure; apps/frontend/ and apps/backend/ are independent application repositories. Follow each repository's conventions instead of imposing one language or tool rule across all three.
- Keep product-wide documentation distinct from feature-specific Spec Kit artifacts. Maintain traceability from requirement to plan, task, code, and verification.

## Implementation and quality

- Prefer clear contracts, small modules, explicit failure behavior, and accessible user-facing interfaces.
- Protect user, trip, and financial data with server-side authorization and least privilege; validate untrusted inputs at trust boundaries.
- Select checks relevant to the authorized change and repository instructions. Do not claim tests or builds ran unless they did; explain skipped and inconclusive checks.
- Do not run destructive, expensive, or externally consequential checks without authorization.

## Approval and delivery

- New or materially changed behavior follows the documentation-first workflow and its approval gates.
- Use a Change Request for significant changes to approved feature behavior. Do not silently retrofit a spec to match implementation.
- Do not commit, push, merge, rebase, reset, clean, deploy, or alter remote infrastructure without explicit authorization.
- Report files/repositories changed, why, verification evidence, risks, and remaining work.
