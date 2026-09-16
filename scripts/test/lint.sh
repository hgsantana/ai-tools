# shellcheck shell=bash
# lint.sh development-check cases. These invoke the real linter against this
# tree (not a harness fixture): they are not installation-process tests.

case_lint_invalid_base_is_warning() {
  local out
  out=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-out.XXXXXX") || fatal "$T_CASE: mktemp failed"
  "$AI_TOOLS/scripts/lint.sh" --base this-ref-does-not-exist >"$out" 2>&1
  # shellcheck disable=SC2034 # consumed by t_assert_exit / t_assert_line
  T_LAST_EXIT=$?
  # shellcheck disable=SC2034
  T_LAST_OUTPUT=$(cat "$out")
  rm -f "$out"
  t_assert_exit 2
  t_assert_line "version bump check: --base is not a commit: this-ref-does-not-exist"
  t_assert_no_line "version bump not required"
}
