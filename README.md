# Dreamday infrastructure

This repository coordinates the frontend and backend Git submodules and runs their Docker containers on the local Docker host. Images are built locally; this repository does not publish them to a container registry.

## Repository layout

```text
.
├── .gitmodules                  # Submodule remotes and tracked branches
├── apps/
│   ├── frontend/                 # Git submodule
│   └── backend/                  # Git submodule
├── env/
│   ├── frontend/.env.example
│   └── backend/.env.example
├── compose.yaml                 # Local integration stack
├── nginx/                       # Local reverse proxy configuration
├── scripts/
│   ├── build.sh
│   ├── deploy.sh
│   └── dev.sh
└── README.md
```

Each submodule is pinned to a commit recorded by this repository. Updating a submodule does not update the recorded commit until you commit the changed gitlink here.

## Prerequisites

- Git access to both submodule repositories.
- Docker Engine and Docker Compose v2.
- Local env files copied from `env/frontend/.env.example` and
  `env/backend/.env.example`.

The root Compose stack loads per-service variables from these files using `env_file`. These values are available to containers at runtime; values needed while building an image must be provided through that image's build configuration.

## Clone and update submodules

Clone with submodules initialized:

```sh
git clone --recurse-submodules git@github.com:Little-Elsewhere/dreamday.git
cd dreamday
```

If the repository was cloned without submodules:

```sh
git submodule update --init --recursive
```

Update a submodule to the branch configured in `.gitmodules`, then commit the new gitlink:

```sh
git submodule update --remote apps/frontend
git add apps/frontend
git commit -m "chore: update frontend"
```

Repeat for `apps/backend`, or update both with `git submodule update --remote`. To see the pinned commits, run `git submodule status`.

The root integration stack runs the development environment from each submodule, using `docker/dev/Dockerfile`. The Dockerfile path is relative to that service's build context. This stack does not use the submodules' production Dockerfiles or their standalone Compose files. It also starts PostgreSQL 18 and Mailpit for the backend, applies Alembic migrations before the API starts, and exposes the local Mailpit inbox at <http://localhost:8025>. PostgreSQL data persists in the `backend_postgres18_data` volume; `./scripts/dev.sh down` keeps this volume.

## Build and run locally

Build both images on the local Docker host:

```sh
docker compose build
```

Or build selected services with the helper:

```sh
./scripts/build.sh frontend
./scripts/build.sh backend
./scripts/build.sh all
```

Start and manage the stack:

```sh
./scripts/dev.sh up
./scripts/dev.sh logs
./scripts/dev.sh restart
./scripts/dev.sh down
```

Nginx routes `http://dreamday.local` to the frontend and
`http://api.dreamday.local` to the backend. Both services also remain available
directly at `http://localhost:4000` and `http://localhost:8000`. Containers can
reach each other by Compose service name on the local Docker network.

Map both local domains to the host loopback address in `/etc/hosts`:

```text
127.0.0.1 dreamday.local api.dreamday.local
```

If `dreamday.local` is already mapped, add the API domain with:

```sh
printf '127.0.0.1 api.dreamday.local\n' | sudo tee -a /etc/hosts
```

Otherwise, add the full line shown above.

Nginx listens on `127.0.0.1:80`, and PostgreSQL and Mailpit ports are also bound
to loopback. The frontend and backend ports are published as `4000:4000` and
`8000:8000` without a host IP, so Docker binds them on all host interfaces.
If port 80 is already in use, stop the service using it before starting this
Compose stack.

The standalone frontend dev stack uses host port `4000`. The standalone backend
dev stack uses `8000`, `5432`, `1025`, and `8025`. Stop those stacks before
starting the root stack to avoid port conflicts.

To rebuild selected images and start those services on this machine:

```sh
./scripts/deploy.sh frontend
./scripts/deploy.sh backend
./scripts/deploy.sh all
```

The `all` command also starts the Nginx proxy. These commands build and run
containers on the current Docker host. They do not publish or pull application
images from a registry, or connect to a VPS. Stop the stack with
`./scripts/dev.sh down`.

## Environment files

| Service | Env file | Compose file |
| --- | --- | --- |
| Frontend | `env/frontend/.env` | `compose.yaml` |
| Backend | `env/backend/.env` | `compose.yaml` |

Create the root-level local files from their examples before starting the root
Compose stack. The frontend template groups public application metadata, runtime
behavior, analytics, and development settings. The backend template groups
application, database, authentication, email verification, and SMTP settings.
Keep local `.env` files out of Git. In `env/backend/.env`, set the database
credentials and generate a `JWT_SECRET_KEY` with at least 32 characters. The
example points `EMAIL_VERIFICATION_URL` at the frontend's local English
confirmation route (`/en/auth/confirm`) and `PASSWORD_RESET_URL` at
`/en/auth/reset-password`; adjust them if those routes change. The
backend connects to PostgreSQL and Mailpit using the Compose service names
`backend-db` and `backend-mailpit`.

These root-level env files are for the root integration stack. The standalone
Compose stacks inside the submodules load `apps/frontend/.env` or
`apps/backend/.env`; follow the corresponding app README to create those files.

```sh
cp env/frontend/.env.example env/frontend/.env
cp env/backend/.env.example env/backend/.env
```

Compose currently loads each application service's variables with `env_file`;
keep these files and their examples in sync when configuration keys change.

## Documentation

- [Authentication API (frontend contract)](docs/auth-api.md) — register / verify / login / refresh flows, message codes, and FE implementation notes.
- [Database ERD](docs/database-erd.md) — PostgreSQL tables and relationships for the current backend schema.

## Troubleshooting

- **Submodule directory is empty:** run `git submodule update --init --recursive` and confirm Git can access both repositories.
- **Compose reports a missing env file:** copy the matching `.env.example` to `.env` under the `env` directory.
- **Compose cannot find a Dockerfile:** check the Dockerfile path inside the submodule and update the service's `dockerfile:` setting.
- **Backend waits for migrations or fails its health check:** check the database credentials and `DB_HOST` in `env/backend/.env`, then inspect the `backend-db`, `backend-migrate`, and `backend` logs.
- **A service cannot reach the other:** use its Compose service name and the port the application listens on inside the container; host `localhost` addresses are for clients outside the Docker network.
