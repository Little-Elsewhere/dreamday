# Code review workflow

**Trigger:** request to review a pull request, branch, or diff. **Inputs:** base/head or diff, approved requirements/Change Request, and repository scope.

1. Inspect Git status in root and affected submodules. Identify the intended diff without altering the worktree.
2. Read approved specs, plan/tasks, security and Git policies, and affected repositories' local instructions.
3. Reviewer stays read-only. Assign independent review topics only when useful and keep them disjoint (for example, security, acceptance coverage, and API compatibility).
4. Review behavior, boundaries, authorization, failure cases, regressions, and criteria. Verify exact claims from code/tests; do not rely on a green check whose scope is unknown.
5. Return actionable findings first, ordered by severity, with file/line references and impact. Then state residual risks, coverage gaps, reviewed scope, and what was not verified.

**Expected output:** review report with findings or an explicit no-findings statement and scope. **Safety:** no edits, auto-fixes, write-formatters, commits, or merges; do not elevate style preferences into defects.
