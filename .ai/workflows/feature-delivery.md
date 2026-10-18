# Feature delivery workflow

**Trigger:** a new user-facing capability or cross-repository feature. **Inputs:** request, user/problem context, relevant specs, and any explicit implementation authorization.

1. Inspect root and affected submodule states and instructions. Read the constitution, existing feature artifacts, relevant code, and current conventions.
2. Ask Architect to assess boundaries and risks. Delegate read-only Frontend and Backend inventories when independent; provide exact files/questions and prohibit edits. Include DevOps or QA when the impact warrants it.
3. Use installed Spec Kit skills as appropriate: speckit-specify, speckit-clarify, speckit-plan, speckit-tasks, then speckit-checklist and speckit-analyze when useful. Follow their current instructions and generated paths.
4. Return a reviewable feature spec, architecture and API/data decisions, affected repositories, risks, acceptance criteria, plan, and dependency-ordered tasks. Stop at the human approval gate.
5. After explicit implementation approval, assign task ownership by repository and file. Use speckit-implement; do not run concurrent edits on shared contracts/migrations. Use QA and Reviewer for independent verification/review.
6. Map acceptance criteria to code and evidence; report checks, skips, risks, and remaining tasks. Update approved documents through review and hand off if needed.

**Expected output:** either a docs/plan package awaiting approval or, after approval, scoped implementation plus verification report. **Safety:** no unapproved app code, no Git history/remote action, no secret access, and no claimed delegation/check without evidence.
