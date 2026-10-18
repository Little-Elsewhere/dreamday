# Change Request policy

Use a Change Request for a significant modification to approved feature behavior, acceptance criteria, API/data contracts, or a cross-repository decision. Trivial wording fixes that do not alter intent can follow normal documentation review.

Every request records a unique ID; description and justification; affected specifications; impact and affected repositories; risk assessment; acceptance criteria; approval status and approver/date; implementation status; verification results/evidence; and changelog reference. Use .ai/templates/CHANGE_REQUEST.md and the lifecycle in .ai/change-requests/README.md.

Separate two approvals:

1. Requirements approval authorizes a reviewable update to the living specification, history, plan, and tasks. It does not authorize application code.
2. Implementation approval authorizes code and test changes for the named scope.

Keep the approved main-branch specification unchanged until the proposed requirements change is accepted and reviewed. Implement the updated spec on a branch/pull request. Add the Change Request ID to its history so later work can trace the decision. Record verification after checks actually run. Add user-facing changelog entries only when verified work is merged/released; reference the affected repository's established changelog. A docs-only change should point to its merged pull request or state why a release entry does not apply.
