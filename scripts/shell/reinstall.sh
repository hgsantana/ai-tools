#!/usr/bin/env bash
# ai-tools reinstallation — README "Reinstallation" as an executable procedure:
# a full removal + installation pass against a fresh origin/master.
# Physical artifacts are removed and re-created from the refreshed source.
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: reinstall.sh [--harnesses <list>] [--discard-local] [--no-instructions]
                    [--overwrite] [--no-sweep] [--dry-run]

  --harnesses <list>   comma-separated harnesses in scope; omitted selects
                       detected harnesses; "all" selects every supported harness
  --overwrite          replace conflicting or locally modified installed copies
                       in the selected harnesses; never touches $HOME/AGENTS.md
  --discard-local      allow the reset to origin/master to discard local commits
                       and uncommitted edits inside $HOME/.ai-tools (shown first)
  --no-instructions    do not refresh the global instructions copies
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

# 1. Update the source first, so destinations match the published agent set.
ensure_clone
if [ "$FRESH_CLONE" = 1 ]; then
  info "fresh clone — already at origin/master, reset skipped"
else
  update_source "$DISCARD_LOCAL"
fi

report_discovery
set_scope "$HARNESSES"

# Refresh copies that still match the pre-reset revision. This distinguishes
# unmodified installed artifacts from user edits before the remove/reinstall pass.
refresh_copies "$((1 - NO_INSTRUCTIONS))"

# 2. Remove: agents, skills, grok block, stale links, optionally instructions.
uninstall_agents
remove_skills
remove_grok_models
[ "$NO_SWEEP" = 1 ] || sweep_stale_links
[ "$NO_INSTRUCTIONS" = 1 ] || remove_instructions

# 3. Install against the fresh tree.
if [ "$NO_INSTRUCTIONS" = 1 ]; then
  info "instructions refresh skipped (--no-instructions)"
else
  install_instructions
fi
install_agents
install_skills
install_grok_models

# 4. Verify: full install checks, and no stale links left behind.
VERIFY_INSTRUCTIONS=$((1 - NO_INSTRUCTIONS)) verify_install
info "restart or reload harnesses, then confirm the agents and skill slash commands appear"
finish
