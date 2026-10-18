# Change Request records

Store one file per significant proposed change to approved behavior or an approved feature specification, using .ai/templates/CHANGE_REQUEST.md.

Use IDs of the form CR-YYYYMMDD-NNN. Before assigning one, inspect this directory and choose an unused suffix for that date. A Change Request is a proposal until its requirements change is explicitly approved.

## Lifecycle

1. **Proposed:** record the justification, affected specifications and repositories, risks, and acceptance criteria. Do not alter the approved living specification or implementation.
2. **Requirements approved:** record approver and date. Update the living specification on a reviewable branch or pull request, add a Change Request History entry, and create or update the plan and tasks. This approval covers requirements only.
3. **Implementation approved:** after separate explicit human approval, implement accepted tasks. Update implementation status and attach verification evidence.
4. **Verified and merged/released:** record final verification and reference the owning repository's release changelog when user-visible behavior ships. For docs-only changes, reference the merged documentation PR or mark a release entry not applicable with a reason. Do not create release notes for a proposal or unverified implementation.
5. **Rejected or superseded:** record the decision and rationale; preserve historical artifacts.

An approved spec change is still reviewed through the normal branch/pull-request process. Never edit an approved specification directly on the main branch before approval and review.
