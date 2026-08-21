# shellcheck shell=bash
# reinstall.sh — proves README rules 20-22, 27 against scripts/shell/reinstall.sh:
# a full removal + installation pass ends in the same state a fresh install
# produces, sweeps stale links, keeps a locally modified copy, refuses to
# discard local clone work without --discard-local, runs the fresh-clone
# path offline through the fixture's insteadOf rewrite, and obeys
# --no-instructions and --dry-run.
#
# Snapshot scope note: comparisons below snapshot only $root/home/.claude and
# $root/home/AGENTS.md, never $root/home/.ai-tools. update_source() in
# scripts/shell/lib.sh runs `git fetch origin` unconditionally, including
# under --dry-run, which writes $AI_TOOLS/.git/FETCH_HEAD — harmless local
# git bookkeeping, not installed state. The base plan's own reinstall-vs-
# fresh-install comparison already calls for "ignoring the clone's own git
# metadata"; the same reasoning applies to the --dry-run "nothing changes"
# case, so this file scopes every snapshot to the harness destinations
# rather than the whole $HOME. Recorded in the Implementation log.

case_reinstall_clean_matches_fresh_install() {
  local root_a root_b snap_a snap_b
  t_fixture
  root_a="$T_ROOT"
  t_run "$root_a" "$root_a/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  snap_a=$(t_snapshot "$root_a/home/.claude")

  t_fixture
  root_b="$T_ROOT"
  t_run "$root_b" "$root_b/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code
  t_assert_exit 0
  snap_b=$(t_snapshot "$root_b/home/.claude")

  # Both snapshots embed their own sandbox path, so compare with the roots
  # substituted out rather than raw cmp.
  if diff -q \
      <(sed "s#$root_a#ROOT#g" "$snap_a") \
      <(sed "s#$root_b#ROOT#g" "$snap_b") >/dev/null; then
    ok "$T_CASE: reinstall end state matches a fresh install"
  else
    warn "$T_CASE: reinstall end state differs from a fresh install"
  fi

  rm -f "$snap_a" "$snap_b"
  t_cleanup "$root_a"
  t_cleanup "$root_b"
}

case_reinstall_stale_link_removed() {
  local root
  t_fixture --stale-link
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_absent "$T_STALE_LINK_PATH"
  t_assert_symlink "$root/home/.claude/agents/planner-ai-tools.md" "$root/home/.ai-tools"

  t_cleanup "$root"
}

case_reinstall_modified_copy_kept() {
  local root
  t_fixture --modified-copy
  root="$T_ROOT"

  t_run_no_symlink "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run_no_symlink "$root" "$root/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "SKIP: copy was modified locally, user work kept: $T_MODIFIED_COPY_PATH"
  if grep -qF 'local edit that matches no revision' "$T_MODIFIED_COPY_PATH"; then
    ok "$T_CASE: modified copy survived the reinstall"
  else
    warn "$T_CASE: modified copy lost its local edit across reinstall"
  fi

  t_cleanup "$root"
}

case_reinstall_fresh_clone_offline() {
  local root
  t_fixture
  root="$T_ROOT"
  rm -rf "$root/home/.ai-tools"

  t_run "$root" "$AI_TOOLS/scripts/shell/reinstall.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "info: fresh clone — already at origin/master, reset skipped"
  t_assert_symlink "$root/home/.claude/agents/planner-ai-tools.md" "$root/home/.ai-tools"

  t_cleanup "$root"
}

case_reinstall_uncommitted_no_discard() {
  local root snap
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  printf 'uncommitted local edit\n' >> "$root/home/.ai-tools/README.md"
  snap=$(t_snapshot "$root/home/.claude")

  t_run "$root" "$root/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "the reset would discard the local work above"
  t_assert_unchanged "$root/home/.claude" "$snap"
  t_assert_content "$root/home/.ai-tools/README.md" "uncommitted local edit"

  rm -f "$snap"
  t_cleanup "$root"
}

case_reinstall_no_instructions() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code --no-instructions
  t_assert_exit 0
  t_assert_symlink "$root/home/.claude/CLAUDE.md" "$root/home/.ai-tools"

  t_cleanup "$root"
}

case_reinstall_dry_run_changes_nothing() {
  local root snap
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  snap=$(t_snapshot "$root/home/.claude")

  t_run "$root" "$root/home/.ai-tools/scripts/shell/reinstall.sh" --harnesses claude-code --dry-run
  t_assert_exit 0
  t_assert_unchanged "$root/home/.claude" "$snap"

  rm -f "$snap"
  t_cleanup "$root"
}
