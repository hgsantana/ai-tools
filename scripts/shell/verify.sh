#!/usr/bin/env bash
# ai-tools verification — the README's install checks, standalone and read-only.
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: verify.sh [--harnesses <list>]

  --harnesses <list>   comma-separated harnesses in scope; omitted selects
                       detected harnesses; "all" selects every supported harness

Read-only. Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

HARNESSES=""
while [ $# -gt 0 ]; do
  case "$1" in
    --harnesses)   HARNESSES="${2:-}"; [ -n "$HARNESSES" ] || fatal "--harnesses needs a value"; shift ;;
    --harnesses=*) HARNESSES="${1#*=}" ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; fatal "unknown option: $1" ;;
  esac
  shift
done

require_clone
set_scope "$HARNESSES"
verify_install
finish
