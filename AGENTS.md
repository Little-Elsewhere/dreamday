# Dreamday Infrastructure Agent Instructions

## Repository scope

This repository owns shared Docker Compose orchestration, the local proxy, infrastructure scripts, shared environment examples, and the configuration and pinned commits for its submodules. Application source belongs to the corresponding application repository; do not make application changes inside a submodule unless the task explicitly targets that checkout.

## Submodule boundaries

- Keep shared orchestration and infrastructure configuration in this repository.
- Keep frontend and backend application code in their source repositories.
- A submodule update is not recorded here until its gitlink change is committed in this repository. Check the selected submodule commit and remote URL before updating a gitlink.
- When editing inside a submodule, also follow any `AGENTS.md` or other project instructions that apply within that submodule.

<!-- devkit:codex:start -->
## Devkit (Codex adapter)

When the user explicitly asks to use Devkit for engineering work, the **main Codex session** acts as the Devkit Orchestrator:

1. Read `.devkit/agents/orchestrator.md` in full. Read `.devkit/workflows/README.md` to route the request, then read only the chosen existing workflow in full. Choose by the user's goal, not by keywords. Paths referenced as `agents/...` and `workflows/...` inside Devkit instructions are rooted at `.devkit/`.
2. Follow repository instructions and the actual Codex permission/sandbox policy. Do not assume Devkit can override them. Do not edit application code as Orchestrator.
3. Delegate required specialist stages using **actual Codex subagents**: `devkit_tester`, `devkit_developer`, and `devkit_reviewer`, registered in `.codex/agents/`. Give each a self-contained brief with scope, acceptance, verification, prohibited actions, relevant evidence, and the applicable workflow path.
4. Follow the chosen workflow for agent order, scope approval, checks, and stop rules. Use evidence for every completion claim.
5. For a verified change, give `devkit_developer` a final `PUBLISH` task with `CO_AUTHOR: Codex <noreply@openai.com>`. Developer uses Git to commit and push its task branch, and GitHub CLI (`gh pr create --base develop --head <task-branch>`) to open a PR, or `gh pr view` to identify an existing one. Include the approved diff, verification results and risks. Do not publish changes from read-only workflows or make empty commits. Follow actual tool access, authentication and repository permissions; never merge automatically.
6. Collect subagent outputs and independently decide the task disposition. If delegation or a required check is unavailable, say `BLOCKED` rather than imitating a subagent or claiming tests passed. Never invent a PR, approval, commit, or successful test.

These instructions apply to explicit Devkit requests; ordinary project work retains its existing behavior. Specialist TOMLs point to the role Markdown files in `.devkit/agents/`. Read those files at task start; do not rely on an old copy.
<!-- devkit:codex:end -->
