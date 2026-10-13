#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/compose.yaml"

usage() {
  printf 'Usage: %s {up|down|logs|restart}\n' "$0" >&2
}

if [[ $# -ne 1 ]]; then
  usage
  exit 2
fi

case "$1" in
  up)
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" up -d
    ;;
  down)
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" down
    ;;
  logs)
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" logs --follow
    ;;
  restart)
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" restart
    ;;
  *)
    usage
    exit 2
    ;;
esac
