#!/usr/bin/env bash
set -euo pipefail

HOSTS_FILE="${HOSTS_FILE:-/etc/hosts}"
IP='127.0.0.1'
DOMAINS=(dreamday.local api.dreamday.local media.dreamday.local)
BEGIN_MARK='# BEGIN dreamday-local'
END_MARK='# END dreamday-local'
DESIRED_LINE="$IP ${DOMAINS[*]}"

usage() {
  printf 'Usage: %s [apply|check]\n' "$0" >&2
  printf '  apply  Ensure local Dreamday domains map to %s (default)\n' "$IP" >&2
  printf '  check  Exit 0 when all domains are already mapped\n' >&2
}

domain_mapped() {
  local domain="$1"
  # Use a string pattern: a bare /^#/ would start an awk comment.
  # Keep the status in END — awk still runs END after `exit`.
  awk -v ip="$IP" -v host="$domain" '
    $1 ~ "^#" { next }
    $1 != ip { next }
    {
      for (i = 2; i <= NF; i++) {
        if ($i == host) {
          found = 1
          exit
        }
      }
    }
    END { exit found ? 0 : 1 }
  ' "$HOSTS_FILE"
}

all_mapped() {
  local domain
  for domain in "${DOMAINS[@]}"; do
    domain_mapped "$domain" || return 1
  done
  return 0
}

write_hosts() {
  local tmp
  tmp="$(mktemp)"
  awk -v begin="$BEGIN_MARK" -v end="$END_MARK" '
    $0 == begin { in_block = 1; next }
    in_block && $0 == end { in_block = 0; next }
    !in_block { print }
  ' "$HOSTS_FILE" >"$tmp"

  {
    printf '\n%s\n%s\n%s\n' "$BEGIN_MARK" "$DESIRED_LINE" "$END_MARK"
  } >>"$tmp"

  if [[ -w "$HOSTS_FILE" ]]; then
    cat "$tmp" >"$HOSTS_FILE"
  else
    sudo tee "$HOSTS_FILE" <"$tmp" >/dev/null
  fi
  rm -f "$tmp"
}

cmd="${1:-apply}"

case "$cmd" in
  -h | --help | help)
    usage
    exit 0
    ;;
  check)
    if all_mapped; then
      printf 'Local Dreamday domains are already mapped in %s\n' "$HOSTS_FILE"
      exit 0
    fi
    printf 'Missing Dreamday domain mapping in %s\n' "$HOSTS_FILE" >&2
    printf 'Run: %s apply\n' "$0" >&2
    exit 1
    ;;
  apply)
    if all_mapped; then
      printf 'Local Dreamday domains are already mapped in %s\n' "$HOSTS_FILE"
      exit 0
    fi
    write_hosts
    printf 'Mapped %s to %s in %s\n' "${DOMAINS[*]}" "$IP" "$HOSTS_FILE"
    ;;
  *)
    usage
    exit 2
    ;;
esac
