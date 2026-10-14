#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/compose.yaml"

usage() {
  printf 'Usage: %s {frontend|backend|all}\n' "$0" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

case "$1" in
  frontend|backend)
    BUILD_SERVICES=("$1")
    START_SERVICES=("$1")
    ;;
  all)
    BUILD_SERVICES=(frontend backend)
    START_SERVICES=(frontend backend nginx)
    ;;
  *)
    usage
    exit 2
    ;;
esac

docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" build --no-cache "${BUILD_SERVICES[@]}"
docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" up -d --no-build "${START_SERVICES[@]}"
