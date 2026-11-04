# Dreamday Infrastructure Agent Instructions

This repo pins the frontend/backend Git submodules and owns the shared local stack (Compose, Nginx, scripts, env templates). App source lives in the submodules. Setup, ports, and commands: see root `README.md`.

## Layout

- `apps/frontend` — Next.js (submodule)
- `apps/backend` — FastAPI + Alembic (submodule)
- `compose.yaml`, `nginx/`, `scripts/`, `env/` — root orchestration only
- `.cursor/rules/frontend/` — Cursor rules scoped to `apps/frontend`

For app-specific guidance, follow that submodule's `AGENTS.md` and README.

## Change boundaries

- Keep orchestration, proxy, scripts, env templates, and submodule pins in this repo.
- Change app code only in the relevant submodule when the task targets that app.
- Do not bump a submodule pin as a side effect; verify remote and intended commit first.
- When changing a shared service, port, path, or env key, update Compose, Nginx, templates, and README together.
- Never commit local `.env` files or credentials; update the example templates when keys change.
