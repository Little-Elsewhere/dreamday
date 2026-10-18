# Agent coordination policy

## Orchestrator

The main session remains responsible for task classification, applicable specs, approval status, repository status, delegation, dependency order, conflict resolution, verification, and the final report. It must not claim delegated work ran unless it actually did.

## Delegation

Delegate when work is meaningfully independent and parallel results reduce time or improve coverage. Do not delegate trivial, sequential, or shared-file work. Give each agent a bounded question, required inputs, exact output, repository/file ownership, dependency, and read/write boundary. Prefer read-only discovery while requirements are being prepared.

Before concurrent edits, reserve disjoint files or directories and tell each agent what it owns. Sequence changes to shared schemas, migrations, root configuration, or contracts. Wait for dependencies before integrating. If native subagents are unavailable or not worth their cost, follow the same assignments sequentially and say so.

## Reconciliation and safety

Ask specialists to cite paths and symbols, separate observed facts from inference, and identify unknowns. The orchestrator compares recommendations against the same approved artifacts, resolves conflicts using .ai/roles/ and .ai/policies/, and escalates product decisions or conflicting approvals to the user. Agent instructions do not expand user authorization.

Codex agents inherit the parent session's sandbox and approval settings; use a read-only parent session for enforceable read-only reviews. Claude adapters restrict Architect and Reviewer tools to Read, Glob, and Grep. Other Claude agents inherit the session's tools and remain bound by their role files and approval gates.

When recommendations conflict, explicit user scope and approved requirements govern product behavior; security/privacy rules take priority on data boundaries. For frontend implementation details, retain the local guidance priority: accessibility, performance, architecture, visual UX, and i18n in their stated domains; QA reports coverage issues and escalates. If requirements, local rules, or policies cannot be reconciled, stop and ask the user to decide.
