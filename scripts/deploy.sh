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
    SERVICES=("$1")
    ;;
  all)
    SERVICES=(frontend backend)
    ;;
  *)
    usage
    exit 2
    ;;
esac

docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" build --no-cache "${SERVICES[@]}"
docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" up -d --no-build "${SERVICES[@]}"
