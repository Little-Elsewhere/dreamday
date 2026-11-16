# Dreamday Infrastructure

Orchestration and specs repo: it pins the `apps/frontend` and `apps/backend` submodules, owns the shared local stack (Compose, Nginx, scripts, env templates), and holds the product specs in `openspec/`. App code, app docs, and app-specific agent rules belong in the relevant submodule; follow its own `AGENTS.md` / `CLAUDE.md`. Root `.claude/` holds only the OpenSpec commands and skills.

## Code style

- No explanatory comments in any file across this repo and its submodules (code, Dockerfiles, YAML, shell, SQL, env templates), except `.gitignore`. Explain intent through naming, commit messages, and docs instead.
- Comments that a tool reads are allowed when needed: shebangs, Dockerfile parser directives (`# syntax=…`), `# shellcheck …`, lint or compiler directives. Generated files (e.g. `Cargo.lock`) are left as generated.

## Specs

- `openspec/` is the source of truth for product behavior across FE and BE. The system is being rebuilt from these specs; existing app code is reference only.
- Follow `openspec/config.yaml` for project-wide rules. Work flows propose → specs → tests (red) → implement → archive; do not implement behavior that no approved spec requires.

## Submodules

- Change app code inside the submodule, commit and push there first, then commit the new gitlink here as a separate `chore: pin …` commit.
- Never bump a pin as a side effect; verify the submodule commit exists on its remote before pinning.

## Shared stack

- Each submodule is an independent product: it ships its own `docker/dev` and `docker/prod` Dockerfile and `compose.yaml`, builds and runs standalone, and deploys to its own server. The root stack exists only for local development across repos; never make a submodule depend on it.
- When changing a service, port, path, or env key, update `compose.yaml`, `nginx/`, `env/*/.env.example`, and `README.md` together.
- `env/frontend/.env` feeds the root stack's frontend. The root stack `include`s each rebuilt submodule's `docker/dev/compose.yaml`, so those services use the submodule's own env file. In each submodule, `.env` is for tools run on the host, `docker/dev/.env` feeds its dev stack and `docker/prod/.env` its prod stack. Never commit any of them; update the matching `.example` file when keys change.
- Inside Docker, services reach each other by Compose service name, not `localhost`.
