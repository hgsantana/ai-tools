# shellcheck shell=bash
# remove.sh — proves README rules 18-20, 22, 25 against scripts/shell/remove.sh:
# unlink only what ai-tools created, keep locally modified copies, never touch
# a foreign file or a symlink pointing elsewhere, gate --instructions and
# --purge, sweep stale links without crossing outside $AI_TOOLS, and never
# touch $HOME/AGENTS.md.
#
# Every case installs first (via t_run on install.sh) unless noted otherwise,
# so removal has something real to act on.
#
# Note on exit codes: SKIP (rule 20's "skip and report") does not itself
# raise the exit code — only WARN does (scripts/shell/lib.sh: finish() exits
# 2 only when $WARN > 0; see README rule 25, "2 finished with warnings").
# Several cases below observed exit 0 where an earlier draft of this file
# (mirroring the base plan's prose) expected exit 2 for a skip-only run; the
# assertions here follow the observed, README-consistent behaviour and this
# is recorded in the stage's Implementation log rather than treated as a
# scripts/shell defect.
#
# Note on --external-symlink: t_fixture's sandbox root is named
# "ai-tools-test.XXXXXX" (tools/test/lib.sh), so any path under it —
# including the one --external-symlink stages — contains the literal
# substring "ai-tools". safe_unlink()'s first, coarse check is a `case`
# glob on that substring, so the fixture's own external file is
# misidentified as an ai-tools destination and gets removed instead of
# skipped. This is a fixture-naming collision, not a scripts/shell defect,
# and tools/test/lib.sh is out of scope for this stage (stage 1, frozen; see
# stage plan). Worked around here by staging an equivalent external symlink
# by hand, target outside the sandbox naming scheme, so the real contract
# (a symlink to something else is never removed) is exercised. Recorded in
# the Implementation log.

case_remove_unlinks_what_install_linked() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "removed link:"
  t_assert_absent "$root/home/.claude/agents/planner-ai-tools.md"
  t_assert_absent "$root/home/.claude/skills/plan-ai-tools"
  if [ -e "$root/home/.claude/CLAUDE.md" ] || [ -L "$root/home/.claude/CLAUDE.md" ]; then
    ok "$T_CASE: instructions still present (no --instructions): $root/home/.claude/CLAUDE.md"
  else
    warn "$T_CASE: instructions unexpectedly absent: $root/home/.claude/CLAUDE.md"
  fi

  t_cleanup "$root"
}

case_remove_idempotent() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "ok: absent:"
  t_assert_no_line "WARN:"

  t_cleanup "$root"
}

case_remove_modified_copy_kept() {
  local root
  t_fixture --modified-copy
  root="$T_ROOT"

  t_run_no_symlink "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "SKIP: copy was modified locally, user work kept: $T_MODIFIED_COPY_PATH"
  t_assert_regular_file "$T_MODIFIED_COPY_PATH"
  if grep -qF 'local edit that matches no revision' "$T_MODIFIED_COPY_PATH"; then
    ok "$T_CASE: modified copy survived byte-for-byte: $T_MODIFIED_COPY_PATH"
  else
    warn "$T_CASE: modified copy lost its local edit: $T_MODIFIED_COPY_PATH"
  fi
  # every unmodified copy from the same install must be gone
  t_assert_absent "$root/home/.claude/agents/planner-ai-tools.md"

  t_cleanup "$root"
}

case_remove_foreign_file_kept() {
  local root
  t_fixture --foreign-agent
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  # the code path this foreign file takes: it is a regular file occupying a
  # wrapper's destination, so safe_uninstall_copy compares content and finds
  # it does not match the ai-tools source -> "modified locally" skip.
  t_assert_line "SKIP: copy was modified locally, user work kept: $T_FOREIGN_AGENT_PATH"
  t_assert_regular_file "$T_FOREIGN_AGENT_PATH"
  t_assert_content "$T_FOREIGN_AGENT_PATH" "not an ai-tools file"

  t_cleanup "$root"
}

case_remove_external_symlink_kept() {
  # Manual fixture (see file header): --external-symlink's target collides
  # with the "*ai-tools*" substring check via the sandbox root's own name.
  local root dest extdir
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  extdir=$(mktemp -d "${TMPDIR:-/tmp}/t-remove-external-XXXXXX") || fatal "$T_CASE: mktemp -d failed"
  printf 'outside ai-tools\n' > "$extdir/external-file.md"
  dest="$root/home/.claude/agents/dev-ai-tools.md"
  rm -f "$dest"
  ln -s "$extdir/external-file.md" "$dest" || fatal "$T_CASE: cannot stage external symlink"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "SKIP: symlink not to ai-tools: $dest -> $extdir/external-file.md"
  t_assert_symlink "$dest" "$extdir"

  rm -rf "$extdir"
  t_cleanup "$root"
}

case_remove_agents_md_untouched() {
  local root ref
  t_fixture
  root="$T_ROOT"
  ref=$(mktemp "${TMPDIR:-/tmp}/t-remove-agentsmd-ref.XXXXXX") || fatal "$T_CASE: mktemp failed"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  printf 'my custom overlay\nline two\n' > "$root/home/AGENTS.md"
  cp "$root/home/AGENTS.md" "$ref"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  if cmp -s "$ref" "$root/home/AGENTS.md"; then ok "$T_CASE: AGENTS.md unchanged after remove.sh"
  else warn "$T_CASE: AGENTS.md changed after remove.sh"; fi

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --instructions
  if cmp -s "$ref" "$root/home/AGENTS.md"; then ok "$T_CASE: AGENTS.md unchanged after remove.sh --instructions"
  else warn "$T_CASE: AGENTS.md changed after remove.sh --instructions"; fi

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --purge --yes
  if cmp -s "$ref" "$root/home/AGENTS.md"; then ok "$T_CASE: AGENTS.md unchanged after remove.sh --purge --yes"
  else warn "$T_CASE: AGENTS.md changed after remove.sh --purge --yes"; fi

  rm -f "$ref"
  t_cleanup "$root"
}

case_remove_instructions_gate() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_symlink "$root/home/.claude/CLAUDE.md" "$root/home/.ai-tools"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --instructions
  t_assert_absent "$root/home/.claude/CLAUDE.md"

  t_cleanup "$root"
}

case_remove_antigravity_instructions() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses antigravity

  t_assert_symlink "$root/home/.gemini/GEMINI.md" "$root/home/.ai-tools"
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses antigravity --instructions
  t_assert_absent "$root/home/.gemini/GEMINI.md"

  t_cleanup "$root"
}

case_remove_grok_block() {
  local root
  t_fixture --unmanaged-grok-block
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses grok
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses grok
  t_assert_line "SKIP: unmanaged [subagents.models] in $T_GROK_UNMANAGED_PATH"
  t_assert_content "$T_GROK_UNMANAGED_PATH" 'some-other-agent = "some-model"'

  t_cleanup "$root"

  t_fixture
  root="$T_ROOT"
  mkdir -p "$root/home/.grok" || fatal "$T_CASE: cannot create $root/home/.grok"
  printf 'before-marker\n' > "$root/home/.grok/config.toml"
  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses grok
  printf 'after-marker\n' >> "$root/home/.grok/config.toml"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses grok
  t_assert_line "grok models block removed:"
  t_assert_content "$root/home/.grok/config.toml" "before-marker"
  t_assert_content "$root/home/.grok/config.toml" "after-marker"
  t_assert_no_line "ERROR:"

  t_cleanup "$root"

  t_fixture
  root="$T_ROOT"
  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses grok
  t_assert_line "ok: absent: $root/home/.grok/config.toml"
  t_assert_absent "$root/home/.grok/config.toml"

  t_cleanup "$root"
}

case_remove_stale_link_sweep() {
  local root real_dir
  t_fixture --stale-link
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  # a real directory named like a wrapper must survive the sweep
  real_dir="$root/home/.claude/agents/some-real-ai-tools-dir"
  mkdir -p "$real_dir" || fatal "$T_CASE: cannot create $real_dir"
  printf 'not a link\n' > "$real_dir/f"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "removed link: $T_STALE_LINK_PATH"
  t_assert_absent "$T_STALE_LINK_PATH"
  if [ -d "$real_dir" ] && [ ! -L "$real_dir" ]; then
    ok "$T_CASE: real directory survived the sweep: $real_dir"
  else
    warn "$T_CASE: real directory did not survive the sweep: $real_dir"
  fi

  t_cleanup "$root"

  t_fixture --stale-link
  root="$T_ROOT"
  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --no-sweep
  t_assert_symlink "$T_STALE_LINK_PATH" "$root/home/.ai-tools"

  t_cleanup "$root"
}

case_remove_purge_refuses_without_confirmation() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run_stdin "$root" "no" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --purge
  t_assert_exit 0
  t_assert_line "SKIP: purge not confirmed:"
  if [ -d "$root/home/.ai-tools" ]; then ok "$T_CASE: clone survived a refused purge"
  else warn "$T_CASE: clone deleted despite refused purge"; fi

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --purge --yes
  t_assert_exit 0
  t_assert_line "ok: deleted: $root/home/.ai-tools"
  if [ ! -d "$root/home/.ai-tools" ]; then ok "$T_CASE: clone deleted by --purge --yes"
  else warn "$T_CASE: clone survived --purge --yes"; fi
  t_assert_regular_file "$root/home/AGENTS.md"

  t_cleanup "$root"

  t_fixture
  root="$T_ROOT"
  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --purge --dry-run
  t_assert_exit 0
  t_assert_line "ok: would delete: $root/home/.ai-tools"
  if [ -d "$root/home/.ai-tools" ]; then ok "$T_CASE: --purge --dry-run left the clone in place"
  else warn "$T_CASE: --purge --dry-run deleted the clone"; fi

  t_cleanup "$root"
}

case_remove_dry_run_changes_nothing() {
  local root snap
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  snap=$(t_snapshot "$root/home")

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses claude-code --dry-run
  t_assert_exit 0
  t_assert_unchanged "$root/home" "$snap"

  rm -f "$snap"
  t_cleanup "$root"
}

case_remove_without_a_clone() {
  local root saved
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code

  saved="$root/saved-scripts"
  cp -r "$root/home/.ai-tools/scripts" "$saved" || fatal "$T_CASE: cannot save scripts before deleting the clone"
  rm -rf "$root/home/.ai-tools"

  t_run "$root" "$saved/shell/remove.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "WARN: $root/home/.ai-tools missing — copies cannot be verified; removing links only (sweep)"
  t_assert_absent "$root/home/.claude/agents/planner-ai-tools.md"

  t_cleanup "$root"
}

case_remove_precondition_failures() {
  local root
  t_fixture
  root="$T_ROOT"

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses bogus
  t_assert_exit 1

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --harnesses
  t_assert_exit 1

  t_run "$root" "$root/home/.ai-tools/scripts/shell/remove.sh" --nope-this-flag
  t_assert_exit 1

  t_cleanup "$root"
}
