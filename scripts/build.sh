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
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" build "$1"
    ;;
  all)
    docker compose --project-directory "$ROOT_DIR" -f "$COMPOSE_FILE" build
    ;;
  *)
    usage
    exit 2
    ;;
esac
