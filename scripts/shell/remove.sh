#!/usr/bin/env bash
# ai-tools removal — README "Removal" as an executable procedure.
# Removal means "unlink from harnesses", not "delete the config repo".
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: remove.sh [--harnesses <list>] [--instructions] [--no-sweep]
                 [--purge [--yes]] [--dry-run]

  --harnesses <list>   comma-separated harnesses in scope; "all" or the default
                       selects every detected harness
  --instructions       also unlink the global instructions (USER-AGENTS.md links);
                       never touches $HOME/AGENTS.md
  --no-sweep           skip the stale-link sweep (links from older alpha layouts)
  --purge              delete $HOME/.ai-tools itself after unlinking (asks for
                       confirmation; --yes skips the prompt)
  --dry-run            report what would be done without changing anything

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

HARNESSES="" INSTRUCTIONS=0 NO_SWEEP=0 PURGE=0 YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harnesses)   HARNESSES="${2:-}"; [ -n "$HARNESSES" ] || fatal "--harnesses needs a value"; shift ;;
    --harnesses=*) HARNESSES="${1#*=}" ;;
    --instructions) INSTRUCTIONS=1 ;;
    --no-sweep)    NO_SWEEP=1 ;;
    --purge)       PURGE=1 ;;
    --yes)         YES=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; fatal "unknown option: $1" ;;
  esac
  shift
done

set_scope "$HARNESSES"

if [ -d "$AI_TOOLS" ]; then
  report_links
  uninstall_agents
  remove_skills
  remove_grok_models
else
  warn "$AI_TOOLS missing — copies cannot be verified; removing links only (sweep)"
fi

[ "$NO_SWEEP" = 1 ] || sweep_stale_links
[ "$INSTRUCTIONS" = 1 ] && remove_instructions

verify_removal
[ "$PURGE" = 1 ] && purge_clone "$YES"

info "restart or reload harnesses; the agents and skill slash commands should disappear"
finish
