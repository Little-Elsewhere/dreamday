# DreamDay AI development system

## Architecture

The .ai directory is the canonical, provider-neutral source for roles, policies, workflows, and handoffs. Root AGENTS.md gives Codex and compatible tools the shared entry point. Root CLAUDE.md imports AGENTS.md using Claude Code's supported @path syntax. Codex and Claude Code agent files are small adapters that point back to the canonical role files.

    .ai/roles/       Six canonical role definitions
    .ai/policies/    Engineering, security, Git, coordination, and Change Request rules
    .ai/workflows/   Feature, change, bug, review, docs-first, and smoke-test procedures
    .ai/templates/   Change Request template
    .ai/change-requests/ Change Request records and lifecycle guidance
    .ai/HANDOFF.md   One human-maintained cross-tool handoff slot
    .agents/skills/  Canonical shared skills plus existing Spec Kit skills
    .codex/          Codex project settings and thin TOML role adapters
    .claude/         Claude Markdown/YAML role adapters and thin skill wrappers
    .specify/        Existing Spec Kit configuration and managed integrations
    specs/           Feature documents created by the installed workflow when needed
    apps/frontend/   Independent frontend Git submodule
    apps/backend/    Independent backend Git submodule

The root is the infrastructure repository and workspace orchestrator. Frontend and backend are independent Git repositories mounted as submodules. Each repository owns its code, tests, branch, and release history. A submodule gitlink changes only when the root records a new pinned commit.

The submodules retain their own instructions and skills. For example, the frontend AGENTS.md contains specialized architecture, UI/UX, security/data, accessibility, performance, i18n, and quality guidance. These remain useful domain rules under the shared Frontend, Backend, QA, and Reviewer roles; they are not another workspace-level role registry. The backend has a Library Skills management skill under its own .agents/ and .claude/ directories. Preserve these repository-local artifacts and read them when working in that repository.

## Shared roles

| Role | Default ownership | Main use |
| --- | --- | --- |
| Architect | Workspace-wide design | Requirements, boundaries, contracts, data and infrastructure impact, plan review |
| Frontend | apps/frontend/ | Next.js, TypeScript, UI, accessibility, API integration, frontend checks |
| Backend | apps/backend/ | FastAPI, domain logic, data, migrations, APIs, backend checks |
| Reviewer | Read-only across affected repositories | Independent requirement, correctness, regression, security, and maintainability review |
| QA | Cross-repository acceptance | Test strategy, coverage, edge cases, verification reports |
| DevOps | Root infrastructure | Docker Compose, Nginx, local development, CI/CD, infrastructure docs |

Each role file defines purpose, responsibilities, ownership, required context, allowed and forbidden operations, deliverables, collaboration, escalation, and Definition of Done. Read the role file before delegation; adapters do not repeat the full policy.

## Provider adapters

### Codex

- .codex/config.toml enables native multi-agent support and caps a session at four concurrent subagents. It does not select a model; agents inherit the session model and permissions.
- .codex/agents/*.toml uses Codex's standalone custom-agent schema: name, description, and developer_instructions. Start Codex at the workspace root and trust the project so project .codex settings load.
- Codex subagents inherit the parent session's sandbox and approval settings. Reviewer and Architect instructions request read-only work, but this is not a per-agent sandbox. For a strictly read-only Codex review, set the parent session to read-only.
- Codex discovers canonical skills in .agents/skills/. Invoke a skill by name or through the skill picker, for example $feature-delivery or $speckit-specify.

### Claude Code

- .claude/agents/*.md uses Claude Code's YAML-frontmatter subagent format. Architect and Reviewer have a read-only tool allowlist (Read, Glob, Grep); other agents inherit session tools and remain governed by their shared role instructions.
- Claude Code loads root CLAUDE.md, which imports AGENTS.md. Start it from the workspace root. Each adapter also tells the agent to read its canonical role file explicitly.
- Claude Code skills are discovered under .claude/skills/<name>/SKILL.md. The six small wrappers direct Claude to the canonical skill under .agents/skills/. Existing Spec Kit generated skills remain in place.
- Invoke a skill by its slash name, such as /feature-delivery or /speckit-specify, or ask Claude Code to select it for the task.

The formats and security controls differ. Claude's tool allowlist can narrow read-only roles; Codex custom agents inherit the parent's session permissions and cannot set a separate sandbox. Neither tool shares live conversation state with the other.

The existing frontend agent guidance defines a useful priority for local specialist conflicts: security/data, accessibility, performance, architecture, visual UX, localization, then QA escalation. Apply those local priorities within the shared roles and escalate conflicts with approved requirements or shared security policy.

## Shared skills

Canonical implementations live in .agents/skills/<name>/SKILL.md:

- feature-delivery — documentation-first path for a new feature.
- change-request — traceable proposal and approved change lifecycle.
- bug-fix — investigation, spec impact, authorization, fix, and verification.
- code-review — independent, read-only review.
- spec-sync — keep approved specifications aligned through an approved lifecycle.
- session-handoff — conflict-aware update of .ai/HANDOFF.md.

Claude wrappers identify and load the canonical file; they do not copy its procedure. Existing Spec Kit skills under .agents/skills/speckit-* and their generated Claude counterparts are managed by the installed Spec Kit integration. Do not overwrite them by hand.

## Spec Kit lifecycle and approval gates

Spec Kit remains the source of truth for approved feature requirements and technical planning. The installed skills provide the current lifecycle: constitution, specify, clarify, plan, tasks, checklist, analyze, implement, and converge. Use the actual skills and their current instructions rather than inventing CLI commands. The installed CLI's read-only integration check is:

specify integration status

At this workspace snapshot, .specify/memory/constitution.md still contains template placeholders. Ratify the project principles with the installed speckit-constitution skill before treating that file as an approved constitution or using it to resolve product decisions.

For a new feature:

1. Inspect affected repositories, existing specifications, the constitution, and applicable local guidance.
2. Use speckit-specify to create or update a feature spec, then speckit-clarify for material ambiguity.
3. Use speckit-plan and speckit-tasks; use speckit-checklist and speckit-analyze where appropriate.
4. Present affected repositories, risks, acceptance criteria, plan, and tasks. Stop for human approval before application implementation unless the user already explicitly authorized that exact scope.
5. After approval, use speckit-implement, verify acceptance criteria, and use speckit-converge when checking for remaining work.

Product-wide documentation belongs in the root documentation area chosen for that purpose. Feature-specific requirements and plans belong under the path produced by the installed Spec Kit workflow (the configured defaults use sequential numbering under specs/). Do not infer or manually recreate a managed feature path. Keep approved specifications unchanged on the main branch until review and approval. See workflows/documentation-first.md for the full gate sequence.

At initial inspection on 2026-10-18, the root had no feature-specific specs. The frontend tree included trip creation/list and itinerary UI components plus auth utilities. The backend source tree included auth routes and trip schema files, but no trip model or trip route source file was visible. This is only a discovery snapshot: re-inspect source and specs before any feature decision.

## Examples

### 1. Plan a new feature

From the workspace root, ask:

    Use the feature-delivery skill. Plan collaborative itinerary scheduling. Inspect current code and specifications in both submodules, delegate independent read-only frontend and backend inventories, then prepare the Spec Kit specification, architecture impacts, plan, tasks, and acceptance criteria. Stop before implementation and show the approval gate.

The orchestrator checks repository status first, gives each reader disjoint ownership, waits for results, and reconciles them. This is preparation, not implementation approval.

### 2. Implement an approved feature

Ask:

    Implement the approved feature at specs/<actual-feature-dir>/ according to its approved tasks. Approval is for this implementation scope only. Use frontend and backend agents on disjoint task groups, preserve each submodule's Git state, run relevant checks, and report acceptance-criteria evidence.

The orchestrator verifies that the cited approval and task artifacts exist before delegating writes. If parallel work would touch shared files or migrations, sequence those tasks.

### 3. Create a Change Request

Ask:

    Use change-request to propose a change to <approved behavior>. Inspect existing specs, allocate a unique CR ID, fill the template, assess both submodules, and stop with status Proposed. Do not edit the approved spec or code.

Approve the requirements change first. Then update the living specification on a reviewable branch and get separate implementation approval before code changes. See workflows/change-request.md and templates/CHANGE_REQUEST.md.

### 4. Review a pull request

Ask:

    Use code-review and the Reviewer role to review <base>...<head> against the approved spec and tasks. Stay read-only, report actionable findings with file/line evidence, and include test gaps and unverified areas.

Run Codex with a read-only parent sandbox for enforceable read-only execution. Claude's Reviewer adapter only receives Read, Glob, and Grep.

### 5. Continue in the other tool

At session start, read .ai/HANDOFF.md. If it contains another active objective, do not replace it; report the conflict. At session end, use session-handoff to update the file after checking for conflicts. Keep current decisions, paths, completed work, next tasks, verification, and blockers. Never paste credentials, private user data, or chat transcripts. The file is an explicit handoff record, not shared live memory.

## Safe read-only smoke scenario

workflows/read-only-smoke-test.md contains a ready-to-run architecture inventory prompt assigning Architect, Frontend, Backend, and Reviewer separate read-only responsibilities. It is a demonstration template, not evidence that any agent has run. Keep the task read-only and report code evidence separately from planned behavior.

## Extending the system

To add a role, write its complete contract in .ai/roles/<role>.md, then add small Codex TOML and Claude Markdown/YAML adapters that point to it. Update this registry and orchestration guidance; validate discovery and permissions. Avoid model pins unless an approved operational need exists.

To add a shared skill, implement it once under .agents/skills/<skill>/SKILL.md with purpose, trigger, inputs, steps, outputs, safety, and approval sections. Add a thin Claude wrapper that points to canonical content. For another tool, preserve .ai/ as the source of truth and add only its native entry point plus a documented discovery/permission comparison.

## Troubleshooting

- Codex does not load project config: trust the workspace and launch Codex from the root; project .codex settings are ignored for untrusted projects. Check codex --version and parse config.toml.
- Codex does not find an agent: verify the standalone .codex/agents/<name>.toml has name, description, and developer_instructions; start a new session after config edits.
- Claude does not load root guidance: start from the workspace root, verify the supported @AGENTS.md import, and use /context to inspect loaded memory files.
- Claude does not find an agent or skill: verify exact paths, YAML frontmatter, and wrapper targets; start a new session after creating the first .claude/agents or .claude/skills directory.
- Spec Kit files look different: check specify --version and specify integration status. Treat manifests as authoritative; do not install, upgrade, or uninstall just to troubleshoot.
- Submodule context differs: start at root for shared roles, then read that submodule's own guidance and status before work.
