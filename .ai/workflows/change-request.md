# Change Request workflow

**Trigger:** a significant change to approved feature behavior, requirements, API/data contract, or cross-repository decision. **Inputs:** requested change, justification, approved spec, affected repositories, and acceptance criteria.

1. Inspect existing Change Requests to allocate an unused CR-YYYYMMDD-NNN ID. Inspect Git status and affected specs/code without editing approved requirements.
2. Fill .ai/templates/CHANGE_REQUEST.md with description, justification, affected specs, impacts/repositories, risks, acceptance criteria, approval status, implementation status, verification results, and changelog reference.
3. Record it under .ai/change-requests/. Keep status Proposed. Present the proposal and stop for requirements approval.
4. When requirements approval is recorded, update the living spec and its Change Request History on a reviewable branch/pull request. Update plan/tasks and clarify if needed. Do not edit main directly. This approval does not authorize code.
5. Stop for explicit implementation approval. After approval, implement only the named tasks and repositories; record exact verification evidence and implementation status.
6. On merge/release, add the appropriate user-facing changelog entry in the owning repository and link it. For docs-only changes, reference the merged documentation pull request or explain why a release entry is not applicable. Mark rejected/superseded requests without deleting history.

**Expected output:** a complete traceable CR record and either a decision request, approved spec update package, or verified implementation record. **Safety:** no silent spec changes, no code before its separate gate, and no release notes for proposed or unverified work.
