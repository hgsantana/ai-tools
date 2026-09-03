# shellcheck shell=bash
# verify.sh case file — README rules 19-24, 27 against scripts/shell/verify.sh.
# verify.sh is read-only: every case snapshots the sandboxed $HOME before the
# run under test and asserts it is byte-for-byte unchanged afterward.

t_verify() {
  # usage: t_verify <root> [args...] -- runs verify.sh under test
  local root="$1"
  shift
  t_run "$root" "$root/home/.ai-tools/scripts/shell/verify.sh" "$@"
}

case_verify_clean() {
  local root before
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0

  before=$(t_snapshot "$root/home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_no_line "WARN:"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_agent_absent() {
  local root before dest
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0

  dest="$root/home/.claude/agents/planner-ai-tools.md"
  rm -f "$dest" || fatal "$T_CASE: cannot remove $dest"

  before=$(t_snapshot "$root/home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN: agent absent: $dest"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_agent_differs() {
  local root before dest
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0

  dest="$root/home/.claude/agents/planner-ai-tools.md"
  rm -f "$dest" || fatal "$T_CASE: cannot remove $dest"
  printf 'unrelated regular file\n' > "$dest"

  before=$(t_snapshot "$root/home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN: agent differs from source: $dest"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_rejects_legacy_symlinks() {
  local root before home
  t_fixture
  root="$T_ROOT"
  home="$root/home"

  ln -s "$home/.ai-tools/agents/claude-code/planner-ai-tools.md" "$home/.claude/agents/planner-ai-tools.md"
  ln -s "$home/.ai-tools/skills/plan-ai-tools" "$home/.claude/skills/plan-ai-tools"
  ln -s "$home/.ai-tools/USER-AGENTS.md" "$home/.claude/CLAUDE.md"

  before=$(t_snapshot "$home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN:"
  t_assert_unchanged "$home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_all_harnesses() {
  local root before home
  t_fixture
  root="$T_ROOT"
  home="$root/home"

  t_run "$root" "$home/.ai-tools/scripts/shell/install.sh" --harnesses all
  t_assert_exit 0
  before=$(t_snapshot "$home")
  t_verify "$root" --harnesses all
  t_assert_exit 0
  t_assert_no_line "WARN:"
  t_assert_unchanged "$home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_instructions_cap() {
  local root before instructions
  t_fixture
  root="$T_ROOT"
  instructions="$root/home/.ai-tools/USER-AGENTS.md"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0

  printf '%02048d\n' 0 >> "$instructions"
  before=$(t_snapshot "$root/home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN: USER-AGENTS.md exceeds 8000 chars (repository limit):"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_verify_no_clone() {
  local root before
  t_fixture
  root="$T_ROOT"
  rm -rf "$root/home/.ai-tools/.git" || fatal "$T_CASE: cannot remove fixture .git"

  before=$(t_snapshot "$root/home")
  t_verify "$root" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "is missing or not a clone"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}
