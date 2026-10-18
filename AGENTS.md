# DreamDay workspace guidance

This root repository coordinates the local infrastructure and the two independent application repositories: `apps/frontend/` and `apps/backend/`. Treat each as a separate Git repository. Product context in docs is not evidence that a capability exists; inspect code and approved specifications before making claims.

## Shared AI system

`.ai/` is the source of truth for roles, policies, and workflows. Before work, read this file, the applicable `.ai/policies/*.md`, the relevant `.ai/workflows/*.md`, and the matching `.ai/roles/*.md` when using a specialist. Claude Code imports this file through root `CLAUDE.md`.

Submodule instructions remain required context. Their local framework rules and specialist personas are domain guidance beneath the six shared workspace roles, not a competing top-level role registry. Preserve their concrete conventions; if a local rule conflicts with an approved requirement or shared safety policy, surface the conflict instead of silently choosing.

## Work rules

- Inspect `git status --short --branch` at the root and in every affected submodule before work. Preserve existing changes and respect each repository's own `AGENTS.md`, `CLAUDE.md`, and engineering conventions.
- Keep root infrastructure changes in the root repository and frontend/backend application changes in their respective submodules. Do not assume a submodule has an active branch or that its gitlink should be updated.
- Treat `.specify/` and generated Spec Kit integration files as managed. Use the existing `speckit-*` skills and installed workflow; do not overwrite, regenerate, or uninstall managed files as part of unrelated work.
- For new or materially changed product behavior, follow the documentation-first Spec Kit lifecycle. Stop at the documented human approval gate before implementation unless the user has explicitly authorized implementation for that exact scope.
- Never switch branches, reset, clean, commit, push, merge, rebase, deploy, or change remote infrastructure without explicit authorization.
- Never read, print, copy, or place secrets in prompts, specs, logs, or handoffs. Use examples and variable names instead.
- Delegate only when independent bounded work has measurable value. Give each agent inputs, output format, ownership, dependencies, and a read/write boundary. Keep concurrent writes to disjoint files; use a sequential fallback when subagents are unavailable.
- Report evidence, verification actually performed, skipped checks, and unresolved questions. Do not imply a delegated task or check ran if it did not.

See `.ai/README.md` for invocation examples and tool-specific behavior.
