# Bug-fix workflow

**Trigger:** an observed defect or regression. **Inputs:** observed/expected behavior, reproduction details, environment, and explicit request scope.

1. Inspect repository states, local instructions, relevant approved specs, code path, and available logs without exposing secrets or personal data.
2. Ask QA or the relevant specialist for an independent read-only reproduction/impact analysis when it adds value. Distinguish confirmed causes from hypotheses.
3. Decide whether the correction restores approved behavior or changes it. If it changes an approved requirement, create a Change Request and follow its gates before implementation.
4. Report cause, evidence, affected repository, proposed fix, acceptance criteria, and verification approach. If the user asked only to investigate, stop before changes. If the user explicitly authorized a scoped fix, proceed within that scope.
5. Implement in the owning repository, add/update tests only within authorized scope, and verify the reported behavior using relevant non-destructive checks.
6. Request read-only Reviewer analysis when useful; reconcile findings and report exact files, evidence, skipped checks, and remaining risk.

**Expected output:** evidence-based diagnosis and proposed next step, or an authorized fix with verification. **Safety:** no speculative broad refactor, unapproved behavior change, secret exposure, or Git history/remote action.
