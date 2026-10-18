# Git and repository workflow

Treat the root workspace, apps/frontend/, and apps/backend/ as independent Git repositories. The directories are connected by submodule gitlinks, not one shared branch.

Before work, inspect git status --short --branch in the root and each affected submodule, plus git submodule status at root. Record existing user changes and avoid overwriting them. Confirm the exact repository owns every proposed file. Respect detached HEAD and pinned submodule commits; do not switch branches to make work convenient.

Never automatically switch branches, reset, clean, commit, push, merge, rebase, or update/pin submodules. Perform these only after explicit authorization. A remote command or root gitlink update is not implied by an application change. Keep parallel writers in disjoint repositories or disjoint files and state ownership before starting.

For review, inspect the intended diff and base commit without modifying the worktree. For handoffs, include repository and branch/commit identifiers only when useful and safe; never include credentials or secrets.
