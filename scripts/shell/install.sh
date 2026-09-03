#!/usr/bin/env bash
# ai-tools installation — README "Installation" as an executable procedure.
# First clone: scripts/shell/install-bash.sh | bash (or install-zsh.sh | zsh).
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
. "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
usage: install.sh [--harnesses <list>] [--overwrite] [--no-instructions]
                  [--dry-run]

  --harnesses <list>   comma-separated harnesses to install into
                       (claude-code,grok,codex,copilot,cursor,antigravity);
                       omitted selects detected harnesses; "all" selects every
                       supported harness, whether detected or not
  --overwrite          replace conflicting or locally modified installed copies
                       in the selected harnesses; never touches $HOME/AGENTS.md
  --no-instructions    skip copying USER-AGENTS.md as global instructions
  --dry-run            report what would be done without changing anything

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

HARNESSES="" NO_INSTRUCTIONS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harnesses)   HARNESSES="${2:-}"; [ -n "$HARNESSES" ] || fatal "--harnesses needs a value"; shift ;;
    --harnesses=*) HARNESSES="${1#*=}" ;;
    --overwrite)   OVERWRITE=1 ;;
    --no-instructions) NO_INSTRUCTIONS=1 ;;
    --dry-run)     DRY_RUN=1 ;;
    -h|--help)     usage; exit 0 ;;
    *)             usage >&2; fatal "unknown option: $1" ;;
  esac
  shift
done

ensure_clone
report_discovery
set_scope "$HARNESSES"

if [ "$NO_INSTRUCTIONS" = 1 ]; then
  info "instructions install skipped (--no-instructions)"
else
  install_instructions
fi
install_agents
install_skills
install_grok_models

VERIFY_INSTRUCTIONS=$((1 - NO_INSTRUCTIONS)) verify_install
info "restart or reload harnesses that cache agents or skills, then check the agent list and skill slash commands"
finish
