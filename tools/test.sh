#!/usr/bin/env bash
# ai-tools sandboxed test suite — a development check, not an installation
# process (outside the contract of README rules 25-27), with the same standing
# as tools/lint.sh. Proves the install/remove/update/verify contract
# mechanically, against a disposable fake $HOME, never against the real one.
#
# Usage: tools/test.sh [--help] [--case <name>]... [--keep]
#
# Run from anywhere; it resolves its own repository root. Exit: 0 clean,
# 1 aborted on a precondition, 2 finished with failures.
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AI_TOOLS=$(cd "$SCRIPT_DIR/.." && pwd)
export AI_TOOLS
. "$AI_TOOLS/scripts/shell/lib.sh"
. "$AI_TOOLS/tools/test/lib.sh"

# --- Case discovery by glob ---------------------------------------------------
# Every tools/test/*.sh other than lib.sh is a case file: it defines one or
# more case_* functions, which this runner sources and calls. Nothing
# registers a case in a central list — a new case file needs no edit here.

t_discover_case_files() {
  local f
  for f in "$AI_TOOLS"/tools/test/*.sh; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "lib.sh" ] && continue
    echo "$f"
  done
}

t_discover_case_functions() {
  declare -F | awk '{print $3}' | grep '^case_' | LC_ALL=C sort
}

# T_CASE_MAP: one line per case file, "<basename-without-.sh>: <fn1> <fn2> ...",
# built by t_source_case_files. Lets --case <name> resolve a case-file
# basename to every case_* function it defines.
T_CASE_MAP=""

t_case_functions_for_file() {
  # usage: t_case_functions_for_file <file-basename-without-.sh>
  # Echoes its space-separated case_* functions, or nothing if no such file.
  printf '%s\n' "$T_CASE_MAP" | awk -F': ' -v b="$1" '$1==b {print $2; exit}'
}

t_source_case_files() {
  local f base before after new
  T_CASE_MAP=""
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    base=$(basename "$f" .sh)
    before=$(t_discover_case_functions)
    # shellcheck source=/dev/null # case file path is discovered at run time, not constant
    . "$f"
    after=$(t_discover_case_functions)
    new=$(printf '%s\n' "$after" | grep -vFxf <(printf '%s\n' "$before") | LC_ALL=C sort | tr '\n' ' ')
    new=${new% }
    if [ -z "$T_CASE_MAP" ]; then
      T_CASE_MAP="$base: $new"
    else
      T_CASE_MAP="$T_CASE_MAP
$base: $new"
    fi
  done < <(t_discover_case_files)
}

t_resolve_case() {
  # usage: t_resolve_case <name> -- echoes the space-separated case_*
  # function(s) <name> selects and returns 0, or returns 1 with no output.
  # Resolved as a case-file basename (with or without ".sh") first, then as
  # a single case_* function name.
  local name="$1" base funcs
  base="${name%.sh}"
  funcs=$(t_case_functions_for_file "$base")
  if [ -n "$funcs" ]; then
    printf '%s\n' "$funcs"
    return 0
  fi
  if printf '%s\n' "$ALL_CASES" | grep -qx "$name"; then
    printf '%s\n' "$name"
    return 0
  fi
  return 1
}

usage() {
  cat <<'EOF'
usage: test.sh [--help] [--case <name>]... [--keep]

Development check: builds a disposable fake $HOME per case and runs the
scripts under scripts/shell against it. Not an installation process
(README rules 25-27); introduces no dependency beyond git, grep, awk, sed,
cmp, diff, find, and tar.

  --case <name>   run one case; repeatable. <name> is either a case-file
                  basename under tools/test/ (with or without ".sh"), which
                  runs every case_* function in that file, or one case_*
                  function name
  --keep          do not delete sandboxes when a case finishes; print paths

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with failures.

Discovered cases (file: functions):
EOF
  t_source_case_files
  printf '%s\n' "$T_CASE_MAP" | sed 's/^/  /'
}

CASES="" KEEP=0
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --case)
      shift
      [ $# -gt 0 ] || fatal "--case requires a name argument (see --help)"
      CASES="$CASES $1"
      ;;
    --keep) KEEP=1 ;;
    *) fatal "unknown flag: $1 (see --help)" ;;
  esac
  shift
done
export KEEP

t_source_case_files
ALL_CASES=$(t_discover_case_functions)
[ -n "$ALL_CASES" ] || fatal "no case_* functions discovered under tools/test/*.sh"

RUN_CASES=""
if [ -n "$CASES" ]; then
  for c in $CASES; do
    resolved=$(t_resolve_case "$c") || fatal "unknown case: $c (see --help)"
    RUN_CASES="$RUN_CASES $resolved"
  done
else
  RUN_CASES="$ALL_CASES"
fi
# Vacuity guard, per run: fail loudly rather than reaching finish with a
# clean (zero-case) count. t_discover_case_functions above already covers
# empty discovery; this covers a resolved-but-empty run set.
[ -n "$(printf '%s' "$RUN_CASES" | tr -d '[:space:]')" ] || fatal "no cases resolved to run"

for T_CASE in $RUN_CASES; do
  info "case: $T_CASE"
  before_count=$((OK + WARN))
  "$T_CASE"
  # Vacuity guard, per case: a case that ran without moving OK or WARN
  # asserted nothing -- catches silent non-terminating failures and no-op
  # cases alike.
  after_count=$((OK + WARN))
  [ "$after_count" -gt "$before_count" ] || warn "$T_CASE: asserted nothing"
done

finish
