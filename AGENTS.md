# Dreamday Infrastructure Agent Instructions

## Repository scope

This repository owns shared Docker Compose orchestration, the local proxy, infrastructure scripts, shared environment examples, and the configuration and pinned commits for its submodules. Application source belongs to the corresponding application repository; do not make application changes inside a submodule unless the task explicitly targets that checkout.

## Submodule boundaries

- Keep shared orchestration and infrastructure configuration in this repository.
- Keep frontend and backend application code in their source repositories.
- A submodule update is not recorded here until its gitlink change is committed in this repository. Check the selected submodule commit and remote URL before updating a gitlink.
- When editing inside a submodule, also follow any `AGENTS.md` or other project instructions that apply within that submodule.
