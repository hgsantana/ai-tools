#!/usr/bin/env bash
# ai-tools update — remove artifacts using the current clone, reset to
# origin/master, then install from the fresh tree.
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: update.sh [--harnesses <list>] [--overwrite] [--discard-local]
                 [--no-instructions] [--no-sweep] [--dry-run]

  --harnesses <list>   comma-separated harnesses in scope; omitted selects
                       detected harnesses; "all" selects every supported harness
  --overwrite          replace conflicting or locally modified installed copies
                       in the selected harnesses; never touches $HOME/AGENTS.md
  --discard-local      allow the reset to origin/master to discard local commits
                       and uncommitted edits inside $HOME/.ai-tools (shown first)
  --no-instructions    keep existing global instructions copies (do not remove
                       or reinstall them)
  --no-sweep           skip the stale-link sweep (links from older alpha layouts)
  --dry-run            report what would be done without changing anything

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

HARNESSES="" DISCARD_LOCAL=0 NO_INSTRUCTIONS=0 NO_SWEEP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harnesses)   HARNESSES="${2:-}"; [ -n "$HARNESSES" ] || fatal "--harnesses needs a value"; shift ;;
    --harnesses=*) HARNESSES="${1#*=}" ;;
    --overwrite)   OVERWRITE=1 ;;
    --discard-local) DISCARD_LOCAL=1 ;;
    --no-instructions) NO_INSTRUCTIONS=1 ;;
    --no-sweep)    NO_SWEEP=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; fatal "unknown option: $1" ;;
  esac
  shift
done

require_clone
report_discovery
set_scope "$HARNESSES"

# Refuse a discarding reset before stripping harness artifacts.
prepare_reset "$DISCARD_LOCAL"

# 1. Remove using this clone (the user's current version).
report_links
uninstall_agents
remove_skills
remove_grok_models
[ "$NO_SWEEP" = 1 ] || sweep_stale_links
[ "$NO_INSTRUCTIONS" = 1 ] || remove_instructions

# 2. Reset the clone to origin/master.
update_source "$DISCARD_LOCAL"

# 3. Install from the fresh tree.
if [ "$NO_INSTRUCTIONS" = 1 ]; then
  info "instructions refresh skipped (--no-instructions)"
else
  install_instructions
fi
install_agents
install_skills
install_grok_models

VERIFY_INSTRUCTIONS=$((1 - NO_INSTRUCTIONS)) verify_install
info "restart or reload harnesses that cache agents or skills"
finish
