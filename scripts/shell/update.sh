#!/usr/bin/env bash
# ai-tools update — README "Update" as an executable procedure.
# Brings $HOME/.ai-tools to origin/master and re-synchronizes what is installed.
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: update.sh [--harnesses <list>] [--discard-local] [--no-reset] [--dry-run]

  --harnesses <list>   comma-separated harnesses in scope; "all" or the default
                       selects every detected harness
  --discard-local      allow the reset to origin/master to discard local commits
                       and uncommitted edits inside $HOME/.ai-tools (shown first)
  --no-reset           skip the reset; only re-synchronize from the current tree
  --dry-run            report what would be done without changing anything

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
Use reinstall.sh instead when the install is broken, comes from an older
alpha layout, or the set of harnesses changed.
EOF
}

HARNESSES="" DISCARD_LOCAL=0 NO_RESET=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harnesses)   HARNESSES="${2:-}"; [ -n "$HARNESSES" ] || fatal "--harnesses needs a value"; shift ;;
    --harnesses=*) HARNESSES="${1#*=}" ;;
    --discard-local) DISCARD_LOCAL=1 ;;
    --no-reset)    NO_RESET=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; fatal "unknown option: $1" ;;
  esac
  shift
done

require_clone
set_scope "$HARNESSES"

if [ "$NO_RESET" = 1 ]; then
  info "reset skipped (--no-reset); synchronizing from the current tree"
else
  update_source "$DISCARD_LOCAL"
fi

refresh_copies
# Link anything newly shipped — every install step is idempotent.
install_instructions
install_agents
install_skills
install_grok_models

verify_install
info "restart or reload harnesses that cache agents or skills"
finish
