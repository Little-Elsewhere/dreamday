# Dreamday Infrastructure

Orchestration repo only: it pins the `apps/frontend` and `apps/backend` submodules and owns the shared local stack (Compose, Nginx, scripts, env templates). App code, app docs, and agent rules belong in the relevant submodule; follow its own `AGENTS.md` / `CLAUDE.md`.

## Submodules

- Change app code inside the submodule, commit and push there first, then commit the new gitlink here as a separate `chore: pin …` commit.
- Never bump a pin as a side effect; verify the submodule commit exists on its remote before pinning.

## Shared stack

- When changing a service, port, path, or env key, update `compose.yaml`, `nginx/`, `env/*/.env.example`, and `README.md` together.
- `env/*/.env` feed the root stack; `apps/*/.env` feed each submodule's standalone stack. Never commit either; update the matching `.env.example` when keys change.
- Inside Docker, services reach each other by Compose service name, not `localhost`.

## Docs

`docs/` holds FE↔BE contracts (API, ERD); `apps/backend` is the source of truth. Datetimes are UTC: `timestamptz` in the DB, ISO-8601 with `Z` on the wire.
