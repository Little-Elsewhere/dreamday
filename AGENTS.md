# Dreamday Infrastructure

Orchestration and specs repo: it pins the `apps/frontend` and `apps/backend` submodules, owns the shared local stack (Compose, Nginx, scripts, env templates), and holds the product specs in `openspec/`. App code, app docs, and app-specific agent rules belong in the relevant submodule; follow its own `AGENTS.md` / `CLAUDE.md`. Root `.claude/` holds only the OpenSpec commands and skills.

## Specs

- `openspec/` is the source of truth for product behavior across FE and BE. The system is being rebuilt from these specs; existing app code is reference only.
- Follow `openspec/config.yaml` for project-wide rules. Work flows propose → specs → tests (red) → implement → archive; do not implement behavior that no approved spec requires.

## Submodules

- Change app code inside the submodule, commit and push there first, then commit the new gitlink here as a separate `chore: pin …` commit.
- Never bump a pin as a side effect; verify the submodule commit exists on its remote before pinning.

## Shared stack

- When changing a service, port, path, or env key, update `compose.yaml`, `nginx/`, `env/*/.env.example`, and `README.md` together.
- `env/*/.env` feed the root stack; `apps/*/.env` feed each submodule's standalone stack. Never commit either; update the matching `.env.example` when keys change.
- Inside Docker, services reach each other by Compose service name, not `localhost`.

## Docs

`docs/` describes the legacy implementation's FE↔BE contracts (API, ERD); use it as reference only, not as a spec.
