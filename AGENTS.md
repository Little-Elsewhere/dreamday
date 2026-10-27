# Dreamday Infrastructure Agent Instructions

## Project purpose

Dreamday is a travel-planning product. This repository integrates and pins the frontend and backend Git submodules. It owns the shared local Docker Compose stack, Nginx proxy, infrastructure scripts, shared environment templates, and submodule metadata. Application source belongs to the corresponding app repository.

## Architecture and file map

- `apps/frontend` is the Next.js application; `apps/backend` is the FastAPI API and Alembic migration project. Both are Git submodules.
- `compose.yaml` is the local integration stack. It builds the apps with their `docker/dev/Dockerfile` files and starts PostgreSQL, Mailpit, the migration job, and Nginx. It does not use the apps' production Compose configurations.
- The root stack exposes the frontend on port `4000`, the backend on `8000`, and PostgreSQL and Mailpit on loopback ports `5432`, `1025`, and `8025`. Nginx listens on `127.0.0.1:80` and routes `dreamday.local` to the frontend and `api.dreamday.local` to the backend.
- `nginx/` contains the proxy configuration. `scripts/` contains helpers for building and managing the root Compose stack; `deploy.sh` builds and starts containers on the current Docker host.
- `env/frontend/.env.example` and `env/backend/.env.example` are templates for the root stack's runtime environment files. The root `README.md` is the runbook for setup, commands, and troubleshooting.

## Change boundaries

- Keep shared orchestration, proxy configuration, infrastructure scripts, shared environment templates, and submodule metadata in this repository.
- Make application source or app-specific configuration changes inside the relevant submodule only when the task explicitly targets that app. Follow its `AGENTS.md`, README, and other applicable local instructions.
- Do not change a submodule's recorded commit as a side effect. When a task includes updating a submodule pin, verify its configured remote and intended commit first.
- When changing a shared service, port, path, or environment variable, keep the affected Compose configuration, proxy settings, templates, and root README consistent.
- Never commit local `.env` files, credentials, or machine-specific values. Update the relevant example template and documentation when configuration keys change.
- Use the root README for infrastructure workflows and the relevant submodule documentation for app-specific workflows.
