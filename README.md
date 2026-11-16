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
│   └── frontend/.env.example
├── compose.yaml                 # Local integration stack
├── nginx/                       # Local reverse proxy configuration
├── scripts/
│   ├── build.sh
│   ├── deploy.sh
│   ├── dev.sh
│   └── setup-hosts.sh
└── README.md
```

Each submodule is pinned to a commit recorded by this repository. Updating a submodule does not update the recorded commit until you commit the changed gitlink here.

## Prerequisites

- Git access to both submodule repositories.
- Docker Engine and Docker Compose v2 (OrbStack on macOS).
- Local env files copied from `env/frontend/.env.example` and
  `apps/backend/docker/dev/.env.example`.

### New macOS machine

Tool setup lives in the repository, so every machine is set up the same way:

1. Install the tools listed in `Brewfile`:

   ```sh
   brew bundle
   ```

2. Homebrew installs `rustup` keg-only, so add its binaries to `PATH` once (then open a new shell):

   ```sh
   echo 'export PATH="$(brew --prefix rustup)/bin:$PATH"' >> ~/.zshrc
   ```

3. Run any `cargo` command inside `apps/backend`. `rustup` reads `apps/backend/rust-toolchain.toml` and installs the pinned channel and components on first use.

Check a machine with `brew bundle check`, and `cargo --version` and `cargo clippy --version` inside `apps/backend`.

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

Each submodule is an independent product with its own `docker/dev` and `docker/prod` setup, and deploys on its own. This root stack is only for local development across repos. It reuses the backend's dev stack directly: `compose.yaml` pulls in `apps/backend/docker/dev/compose.yaml` with `include`, so the `backend` and `backend-db` services, their Dockerfile and their env file are defined once, in the backend repo. The frontend keeps its own service definition here until it is rebuilt. The root stack adds Mailpit (inbox at <http://localhost:8025>), RustFS and Nginx.

The backend container watches `src/`, `migrations/`, `Cargo.toml` and `Cargo.lock` with `watchexec` and recompiles and restarts the API on save. Migrations run when the API starts. PostgreSQL data persists in the `backend_postgres18_data` volume; `./scripts/dev.sh down` keeps this volume.

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

Map the local domains to loopback (writes `/etc/hosts`; prompts for `sudo` when
needed). Safe to re-run:

```sh
./scripts/setup-hosts.sh
```

That ensures:

```text
127.0.0.1 dreamday.local api.dreamday.local media.dreamday.local
```

Verify without changing the file with `./scripts/setup-hosts.sh check`.

The local stack runs **RustFS** (`backend-rustfs` on ports `9000`/`9001`) as the S3-compatible store, served at `http://media.dreamday.local`. The backend does not use it or Mailpit yet; their buckets and env keys arrive with the features that need them.

Nginx listens on `127.0.0.1:80`, and PostgreSQL and Mailpit ports are also bound
to loopback. The frontend and backend ports are published as `4000:4000` and
`8000:8000` without a host IP, so Docker binds them on all host interfaces.
If port 80 is already in use, stop the service using it before starting this
Compose stack.

The standalone frontend dev stack uses host port `4000`. The standalone backend
dev stack uses `8000` and `5432`. Stop those stacks before starting the root
stack to avoid port conflicts.

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

| Service | Env file | Defined in |
| --- | --- | --- |
| Frontend | `env/frontend/.env` | `compose.yaml` |
| Backend, backend-db | `apps/backend/docker/dev/.env` | `apps/backend/docker/dev/compose.yaml` |

The backend uses the same env file whether its dev stack runs on its own or through this root stack; see `apps/backend/docker/README.md` for its keys. `DATABASE_URL` there points at `backend-db`, the Compose service name.

```sh
cp env/frontend/.env.example env/frontend/.env
cp apps/backend/docker/dev/.env.example apps/backend/docker/dev/.env
```

Keep local `.env` files out of Git, and keep them in sync with their examples when configuration keys change.

## Troubleshooting

- **Submodule directory is empty:** run `git submodule update --init --recursive` and confirm Git can access both repositories.
- **Compose reports a missing env file:** copy the matching `.env.example` to `.env` (see the table above).
- **Compose cannot find a Dockerfile:** check the Dockerfile path inside the submodule and update the service's `dockerfile:` setting.
- **Backend exits with `password authentication failed`:** the `backend_postgres18_data` volume keeps the password it was first created with. Use that password in `apps/backend/docker/dev/.env`, or drop the volume with `docker compose down -v` to start with an empty database. Inspect the `backend-db` and `backend` logs.
- **A service cannot reach the other:** use its Compose service name and the port the application listens on inside the container; host `localhost` addresses are for clients outside the Docker network.
