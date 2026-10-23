# Dreamday infrastructure

This repository coordinates the frontend and backend Git submodules and runs their Docker containers on the local Docker host. Images are built locally; this repository does not publish them to a container registry.

## Repository layout

```text
.
├── apps/
│   ├── frontend/                 # Git submodule
│   └── backend/                  # Git submodule
├── env/
│   ├── frontend/.env.example
│   └── backend/.env.example
├── compose.yaml                 # Local Docker Compose stack
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

Compose loads per-service variables from these files using `env_file`. Variables needed while building an image must also be made available by that project's Dockerfile/build process, because Compose `env_file` supplies variables at container runtime.

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

This infrastructure stack runs the dev environment from each submodule, using `docker/dev/Dockerfile`. The Dockerfile path is relative to that service's build context. The submodules' production Dockerfiles are not used by this stack. The root Compose file also starts PostgreSQL 18 and Mailpit for the backend, applies Alembic migrations before the API starts, and exposes the local Mailpit inbox at <http://localhost:8025>.

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

The Nginx container listens on `127.0.0.1:80`, so the local domains are not
published on other network interfaces. If port 80 is already in use, stop the
service using it before starting this Compose stack. The frontend submodule's
standalone dev Compose file also binds port 80; stop that stack before starting
the root Compose stack.

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

Create the local files from their examples before starting Compose. The frontend
template groups public application metadata, runtime behavior, analytics, and
development settings. The backend template groups application, database,
authentication, email verification, and SMTP settings. Keep local `.env` files
out of Git. In `env/backend/.env`, set the database credentials and generate a
`JWT_SECRET_KEY` with at least 32 characters. The example points
`EMAIL_VERIFICATION_URL` at the frontend's local English confirmation route;
adjust it if that route changes. The backend connects to PostgreSQL and Mailpit
using the Compose service names `backend-db` and `backend-mailpit`.

```sh
cp env/frontend/.env.example env/frontend/.env
cp env/backend/.env.example env/backend/.env
```

Compose loads each service's variables with `env_file`; keep service environment
values in these files instead of adding an `environment` section to Compose.

## Troubleshooting

- **Submodule directory is empty:** run `git submodule update --init --recursive` and confirm Git can access both repositories.
- **Compose reports a missing env file:** copy the matching `.env.example` to `.env` under the `env` directory.
- **Compose cannot find a Dockerfile:** check the Dockerfile path inside the submodule and update the service's `dockerfile:` setting.
- **Backend waits for migrations or fails its health check:** check the database credentials and `DB_HOST` in `env/backend/.env`, then inspect the `backend-db`, `backend-migrate`, and `backend` logs.
- **A service cannot reach the other:** use its Compose service name and the port the application listens on inside the container; host `localhost` addresses are for clients outside the Docker network.
