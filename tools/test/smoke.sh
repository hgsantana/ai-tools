# shellcheck shell=bash
# smoke.sh — proves the fixture and the sandboxed runner work end to end,
# and that a run against the fixture never writes into the caller's real
# $HOME. Later stages add contract cases (rules 17-24) as sibling files;
# this one only proves the harness itself.

case_smoke() {
  local root dir marker changed

  t_fixture
  root="$T_ROOT"

  for dir in $T_HARNESS_DIRS; do
    if [ -d "$root/home/$dir" ]; then
      ok "$T_CASE: harness dir present: $dir"
    else
      warn "$T_CASE: harness dir missing: $dir"
    fi
  done

  if [ -d "$root/home/.ai-tools/.git" ]; then
    ok "$T_CASE: fixture clone has .git: $root/home/.ai-tools"
  else
    warn "$T_CASE: fixture clone missing .git: $root/home/.ai-tools"
  fi

  if git -C "$root/home/.ai-tools" rev-parse --verify -q origin/master >/dev/null 2>&1; then
    ok "$T_CASE: origin/master resolves"
  else
    warn "$T_CASE: origin/master does not resolve"
  fi

  # Nothing is installed yet: verify.sh must report rather than fail, which
  # also proves the sandbox is genuinely empty.
  marker=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-marker.XXXXXX") || fatal "$T_CASE: mktemp failed"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/verify.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN: agent absent:"

  changed=$(find "$HOME" -maxdepth 1 -newer "$marker" 2>/dev/null)
  if [ -z "$changed" ]; then
    ok "$T_CASE: real \$HOME untouched"
  else
    warn "$T_CASE: real \$HOME changed: $changed"
  fi
  rm -f "$marker"

  t_cleanup "$root"
}
