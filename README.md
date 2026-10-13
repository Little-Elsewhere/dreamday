# Dreamday infrastructure

This repository coordinates the frontend and backend Git submodules and runs their Docker containers on the local Docker host. Images are built locally; this repository does not publish them to a container registry.

## Repository layout

```text
.
├── apps/
│   ├── frontend/                 # Git submodule
│   └── backend/                  # Git submodule
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
- Existing `apps/frontend/.env` and `apps/backend/.env` files.

The env files belong to their respective projects. Compose loads them using `env_file`; this repository does not create them or duplicate their application variables. Variables needed while building an image must also be made available by that project's Dockerfile/build process, because Compose `env_file` supplies variables at container runtime.

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

The Compose file expects a `Dockerfile` at the root of each submodule. If a Dockerfile lives elsewhere, edit the corresponding `dockerfile:` path in `compose.yaml`; it is relative to that service's build context.

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

The frontend is available at `http://localhost:3000` and the backend at `http://localhost:8000`. Both services share a local Docker network; containers can reach each other by Compose service name.

To rebuild selected images and start those services on this machine:

```sh
./scripts/deploy.sh frontend
./scripts/deploy.sh backend
./scripts/deploy.sh all
```

These commands build and run containers on the current Docker host. They do not publish or pull application images from a registry, or connect to a VPS. Stop the stack with `./scripts/dev.sh down`.

## Environment files

| Service | Env file | Compose file |
| --- | --- | --- |
| Frontend | `apps/frontend/.env` | `compose.yaml` |
| Backend | `apps/backend/.env` | `compose.yaml` |

Keep application settings in each subproject. Do not add a root `.env` file for this infrastructure repository.

## Troubleshooting

- **Submodule directory is empty:** run `git submodule update --init --recursive` and confirm Git can access both repositories.
- **Compose reports a missing env file:** ensure the submodule is initialized and its root `.env` exists at the path listed above.
- **Compose cannot find a Dockerfile:** check the Dockerfile path inside the submodule and update the service's `dockerfile:` setting.
- **A service cannot reach the other:** use its Compose service name and the port the application listens on inside the container; host `localhost` addresses are for clients outside the Docker network.
