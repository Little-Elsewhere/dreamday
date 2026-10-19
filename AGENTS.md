# Dreamday Infrastructure Agent Instructions

## Repository scope

This repository owns shared Docker Compose orchestration, the local proxy, infrastructure scripts, shared environment examples, and the configuration and pinned commits for its submodules. Application source belongs to the corresponding application repository; do not make application changes inside a submodule unless the task explicitly targets that checkout.

## Shared project documentation and AI workflow

[`apps/devkit`](apps/devkit) is the shared developer workflow and GitHub Spec Kit submodule. Treat its instructions, role skills, Spec Kit skills, and templates as the shared workflow source for this project.

[`apps/devkit/docs/README.md`](apps/devkit/docs/README.md) is the index for Dreamday-wide living documentation. For project context, read it and [`apps/devkit/docs/agent-workflow.md`](apps/devkit/docs/agent-workflow.md) before analyzing work that spans or affects the parent infrastructure repository, frontend, or backend.

For product feature work, requirement changes, or bugs:

1. Read [`apps/devkit/AGENTS.md`](apps/devkit/AGENTS.md) and the [Project Manager skill](apps/devkit/.agents/skills/project-manager/SKILL.md) first.
2. Have the Project Manager select only the relevant role skills from `apps/devkit/.agents/skills/` and the relevant Spec Kit skills from the same directory.
3. Follow the approval gates in the shared workflow: get explicit approval for the spec before planning, and for the plan before creating or changing tasks or implementation. After QA passes, reconcile affected project maps as described in the shared workflow.

Resolve paths mentioned inside devkit instructions relative to `apps/devkit/`. Keep Dreamday-wide living maps and workflow documentation under `apps/devkit/docs/`. When a product work item needs Spec Kit artifacts, keep its specs, plans, and tasks under `apps/devkit/specs/<feature>/` in the devkit submodule; do not create a parallel Dreamday `specs/` tree in the parent or application submodules. The `.specify/` configuration and scripts live under `apps/devkit/.specify/`, so their default feature directory belongs under the devkit project root. Before running a write helper, verify that its resolved project and feature paths point into `apps/devkit/`. Use the devkit templates and skill guidance without editing the submodule unless the task explicitly targets devkit itself.

For routine documentation or infrastructure maintenance that does not change product behavior or approved requirements, use the smallest relevant role and avoid creating unnecessary feature artifacts.

## Submodule boundaries

- Keep shared orchestration and infrastructure configuration in this repository.
- Keep frontend and backend application code in their source repositories.
- A submodule update is not recorded here until its gitlink change is committed in this repository. Check the selected submodule commit and remote URL before updating a gitlink.
- When editing inside a submodule, also follow any `AGENTS.md` or other project instructions that apply within that submodule.
