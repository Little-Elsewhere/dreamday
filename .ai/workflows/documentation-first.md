# Documentation-first workflow

Use this for new features and material changes to approved behavior.

## Sequence

1. **Classify and inspect.** Read root AGENTS.md, .ai/policies/, current root/submodule Git status, repository guidance, existing specs, and code. State which behavior is implemented, missing, planned, or unknown.
2. **Find the source of truth.** Read .specify/memory/constitution.md and feature artifacts. If the constitution still contains template placeholders, use the installed speckit-constitution skill to prepare a ratifiable project constitution and stop for human approval before treating it as authoritative. If no feature spec exists, use speckit-specify; do not infer a feature directory or replace managed files.
3. **Resolve requirements.** Capture users, outcomes, constraints, non-goals, data and permission rules, acceptance criteria, and cross-repository boundaries. Use speckit-clarify for consequential ambiguity.
4. **Design and plan.** Use speckit-plan to document architecture, contracts, data/migration and infrastructure impact, risks, and alternatives; use speckit-tasks for dependency-ordered tasks with repository ownership. Use checklist/analyze skills when useful and available.
5. **Present a reviewable proposal.** Show specification paths, changes, acceptance criteria, dependencies, affected repositories, risks, and plan/tasks. Stop for explicit human approval before application implementation unless the user already authorized this exact scope.
6. **After approval, implement.** Confirm approval scope and tasks. Use speckit-implement; delegate only disjoint tasks. Do not expand scope silently.
7. **Verify and reconcile.** Map each acceptance criterion to evidence. Run only relevant, authorized checks. Use speckit-converge when appropriate to identify remaining work; update docs through the approved review process.
8. **Report.** Summarize changes by repository, checks and results, skipped/unverified items, risks, and outstanding work. Record the handoff if switching tools.

## Approval meanings

A broad feature idea authorizes discovery and documentation preparation. It does not by itself waive the documented review gate. An explicit request to implement a named approved feature may authorize the implementation phase for that scope. If authorization is unclear or spec/acceptance criteria are not approved, pause before code changes.

Product-wide docs belong in a root documentation location. Feature-specific requirements, plan, and tasks belong in the feature directory created/resolved by the installed Spec Kit workflow. Approved specs must not be directly changed on main before review and approval.
