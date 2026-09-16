# shellcheck shell=bash
# install.sh case file — README rules 12-17, 20 against scripts/shell/install.sh.
# Each case builds its own fixture via t_fixture and passes an explicit
# --harnesses list so assertions can name exact destination paths.

t_install() {
  # usage: t_install <root> [args...] -- runs install.sh under test
  local root="$1"
  shift
  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" "$@"
}

case_install_fresh() {
  # Rule 12: fresh install physically copies every skill and instructions.
  local root f base
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0

  for f in "$root/home/.ai-tools/skills"/*-ai-tools; do
    [ -d "$f" ] || continue
    base=$(basename "$f")
    t_assert_regular_directory "$root/home/.claude/skills/$base"
    t_assert_same_content "$root/home/.claude/skills/$base" "$f"
  done

  t_assert_regular_file "$root/home/.claude/CLAUDE.md"
  t_assert_same_content "$root/home/.claude/CLAUDE.md" "$root/home/.ai-tools/USER-AGENTS.md"
  t_assert_line "copied:"
  t_assert_no_line "WARN:"

  t_cleanup "$root"
}

case_install_idempotent() {
  # Rule 15: running install.sh twice changes nothing on the second run.
  local root before
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0

  before=$(t_snapshot "$root/home/.claude")
  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "copy up to date:"
  t_assert_no_line "SKIP:"
  t_assert_no_line "WARN:"
  t_assert_unchanged "$root/home/.claude" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_foreign_file_skipped() {
  # Rules 13, 15, 20: a foreign directory on a destination is skipped, not
  # overwritten, and the run still finishes the rest of the skills.
  local root
  t_fixture --foreign-skill
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "SKIP: exists, not overwriting: $T_FOREIGN_SKILL_PATH"
  t_assert_content "$T_FOREIGN_SKILL_PATH/SKILL.md" "not an ai-tools file"
  t_assert_regular_directory "$root/home/.claude/skills/dev-ai-tools"

  t_cleanup "$root"
}

case_install_symlink_elsewhere_skipped() {
  # A symlink pointing outside ai-tools is skipped, not replaced.
  local root before_target
  t_fixture --external-symlink
  root="$T_ROOT"
  before_target=$(readlink "$T_EXTERNAL_SYMLINK_PATH")

  t_install "$root" --harnesses claude-code
  t_assert_exit 2
  if [ "$(readlink "$T_EXTERNAL_SYMLINK_PATH")" = "$before_target" ]; then
    ok "$T_CASE: symlink target unchanged: $T_EXTERNAL_SYMLINK_PATH"
  else
    warn "$T_CASE: symlink target changed: $T_EXTERNAL_SYMLINK_PATH"
  fi

  t_cleanup "$root"
}

case_install_overwrite_conflicts() {
  # Rule 13: --overwrite replaces only selected-harness artifact conflicts.
  local root external_target
  t_fixture --foreign-skill --foreign-instructions
  root="$T_ROOT"

  external_target="$root/external-skill"
  mkdir -p "$external_target" || fatal "$T_CASE: cannot create $external_target"
  printf 'external target stays intact\n' > "$external_target/SKILL.md"
  rm -rf "$root/home/.claude/skills/az-ai-tools"
  ln -s "$external_target" "$root/home/.claude/skills/az-ai-tools" \
    || fatal "$T_CASE: cannot stage foreign symlink"

  t_install "$root" --harnesses claude-code --overwrite
  t_assert_exit 0
  t_assert_regular_directory "$T_FOREIGN_SKILL_PATH"
  t_assert_same_content "$T_FOREIGN_SKILL_PATH" "$root/home/.ai-tools/skills/plan-ai-tools"
  t_assert_regular_directory "$root/home/.claude/skills/az-ai-tools"
  t_assert_same_content "$root/home/.claude/skills/az-ai-tools" "$root/home/.ai-tools/skills/az-ai-tools"
  t_assert_regular_file "$T_FOREIGN_INSTRUCTIONS_PATH"
  t_assert_same_content "$T_FOREIGN_INSTRUCTIONS_PATH" "$root/home/.ai-tools/USER-AGENTS.md"
  t_assert_content "$external_target/SKILL.md" "external target stays intact"

  t_cleanup "$root"
}

case_install_agents_md_absent() {
  # Rule 17: $HOME/AGENTS.md is not an install artifact — absent stays absent.
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_absent "$root/home/AGENTS.md"

  t_cleanup "$root"
}

case_install_agents_md_present() {
  # Rule 17: $HOME/AGENTS.md is user-owned and never touched when present.
  local root
  t_fixture
  root="$T_ROOT"
  printf 'user overrides\n' > "$root/home/AGENTS.md"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_content "$root/home/AGENTS.md" "user overrides"
  if [ -L "$root/home/AGENTS.md" ]; then
    warn "$T_CASE: AGENTS.md became a symlink: $root/home/AGENTS.md"
  else
    ok "$T_CASE: AGENTS.md is not a symlink: $root/home/AGENTS.md"
  fi

  t_cleanup "$root"
}

case_install_dry_run() {
  # Rule 20: --dry-run reports without changing anything.
  local root before
  t_fixture
  root="$T_ROOT"

  before=$(t_snapshot "$root/home")
  t_install "$root" --harnesses claude-code --dry-run
  t_assert_exit 0
  t_assert_line "would copy:"
  t_assert_line "(dry-run: nothing was changed)"
  t_assert_line "info: dry-run: verification skipped"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_legacy_symlinks_migrated() {
  # Rule 12: legacy links into ai-tools migrate to physical copies without --overwrite.
  local root source_skill
  t_fixture
  root="$T_ROOT"

  source_skill="$root/home/.ai-tools/skills/plan-ai-tools"
  ln -s "$source_skill" "$root/home/.claude/skills/plan-ai-tools"
  ln -s "$root/home/.ai-tools/USER-AGENTS.md" "$root/home/.claude/CLAUDE.md"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_regular_directory "$root/home/.claude/skills/plan-ai-tools"
  t_assert_same_content "$root/home/.claude/skills/plan-ai-tools" "$source_skill"
  t_assert_regular_file "$root/home/.claude/CLAUDE.md"
  t_assert_same_content "$root/home/.claude/CLAUDE.md" "$root/home/.ai-tools/USER-AGENTS.md"

  t_cleanup "$root"
}

case_install_antigravity_instructions() {
  # Antigravity uses GEMINI.md plus config/skills/. Do not install into the
  # retired Gemini CLI skills root ~/.gemini/skills.
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses antigravity
  t_assert_exit 0
  t_assert_regular_file "$root/home/.gemini/GEMINI.md"
  t_assert_regular_directory "$root/home/.gemini/config/skills/plan-ai-tools"
  t_assert_regular_directory "$root/home/.gemini/config/skills/az-ai-tools"
  t_assert_absent "$root/home/.gemini/skills/plan-ai-tools"

  t_cleanup "$root"
}

case_install_no_instructions() {
  # --no-instructions skips the instructions destination and its verification.
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code --no-instructions
  t_assert_exit 0
  t_assert_absent "$root/home/.claude/CLAUDE.md"
  t_assert_no_line "WARN:"

  t_cleanup "$root"
}

case_install_all_includes_undetected_harnesses() {
  # Explicit all selects every supported harness, even when none is detected.
  local root home
  t_fixture
  root="$T_ROOT"
  home="$root/home"
  rm -rf "$home/.claude" "$home/.grok" "$home/.codex" "$home/.copilot" "$home/.cursor" "$home/.gemini"

  t_install "$root" --harnesses all
  t_assert_exit 0
  t_assert_regular_directory "$home/.claude/skills/plan-ai-tools"
  t_assert_regular_directory "$home/.grok/skills/plan-ai-tools"
  t_assert_regular_directory "$home/.codex/skills/plan-ai-tools"
  t_assert_regular_directory "$home/.copilot/skills/plan-ai-tools"
  t_assert_regular_directory "$home/.cursor/skills/plan-ai-tools"
  t_assert_regular_directory "$home/.gemini/config/skills/plan-ai-tools"
  t_assert_regular_file "$home/.copilot/instructions/ai-tools.instructions.md"
  t_assert_same_content "$home/.copilot/instructions/ai-tools.instructions.md" "$home/.ai-tools/USER-AGENTS.md"
  t_assert_regular_file "$home/.cursor/rules/ai-tools.mdc"
  t_assert_same_content "$home/.cursor/rules/ai-tools.mdc" "$home/.ai-tools/USER-AGENTS.md"

  t_cleanup "$root"
}

case_install_copilot_instructions_frontmatter() {
  # Copilot user instructions attach automatically only with applyTo.
  local root dest
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses copilot
  t_assert_exit 0
  dest="$root/home/.copilot/instructions/ai-tools.instructions.md"
  t_assert_regular_file "$dest"
  t_assert_same_content "$dest" "$root/home/.ai-tools/USER-AGENTS.md"
  t_assert_content "$dest" 'applyTo: "**"'
  t_assert_no_line "no global instructions destination: copilot"

  t_cleanup "$root"
}

case_install_cursor_instructions() {
  # Cursor machine-local user rules: ~/.cursor/rules/*.mdc with alwaysApply.
  local root dest
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses cursor
  t_assert_exit 0
  dest="$root/home/.cursor/rules/ai-tools.mdc"
  t_assert_regular_file "$dest"
  t_assert_same_content "$dest" "$root/home/.ai-tools/USER-AGENTS.md"
  t_assert_content "$dest" "alwaysApply: true"
  t_assert_no_line "no global instructions destination: cursor"
  t_assert_regular_directory "$root/home/.cursor/skills/plan-ai-tools"

  t_cleanup "$root"
}

case_install_bogus_harness() {
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses bogus
  t_assert_exit 1
  t_assert_line "ERROR: unknown harness"

  t_cleanup "$root"
}

case_install_harnesses_missing_value() {
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses
  t_assert_exit 1

  t_cleanup "$root"
}

case_install_bogus_flag() {
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --bogus
  t_assert_exit 1
  t_assert_line "usage: install.sh"

  t_cleanup "$root"
}

case_install_not_a_clone() {
  local root
  t_fixture
  root="$T_ROOT"
  rm -rf "$root/home/.ai-tools"
  mkdir -p "$root/home/.ai-tools" || fatal "$T_CASE: cannot create non-clone dir"

  # The sandbox's own install.sh no longer exists (it lived under the clone
  # just wiped above), so run this suite's own install.sh instead; t_run
  # still points AI_TOOLS at the sandboxed (non-clone) path, which is what
  # ensure_clone must reject.
  t_run "$root" "$AI_TOOLS/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "is not an ai-tools clone"

  t_cleanup "$root"
}

case_bootstrap_already_cloned() {
  local root home
  t_fixture
  root="$T_ROOT"
  home="$root/home"

  t_run "$root" "$AI_TOOLS/scripts/shell/install-bash.sh"
  t_assert_exit 0
  t_assert_line "ai-tools is already cloned at"
  t_assert_line "scripts/shell/update.sh"

  t_cleanup "$root"
}

case_bootstrap_clones_then_installs() {
  local root home
  t_fixture
  root="$T_ROOT"
  home="$root/home"
  rm -rf "$home/.ai-tools"

  t_run "$root" "$AI_TOOLS/scripts/shell/install-bash.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_regular_file "$home/.ai-tools/scripts/shell/install.sh"
  t_assert_regular_directory "$home/.claude/skills/plan-ai-tools"

  t_cleanup "$root"
}

case_bootstrap_rejects_non_clone() {
  local root
  t_fixture
  root="$T_ROOT"
  rm -rf "$root/home/.ai-tools"
  mkdir -p "$root/home/.ai-tools" || fatal "$T_CASE: cannot create non-clone dir"

  t_run "$root" "$AI_TOOLS/scripts/shell/install-bash.sh"
  t_assert_exit 1
  t_assert_line "exists but is not an ai-tools clone"

  t_cleanup "$root"
}

case_install_parent_symlink_protects_agents_md() {
  # Rule 17: a harness directory that aliases $HOME must not let --overwrite
  # replace $HOME/AGENTS.md (resolved destination, including parent symlinks).
  local root home
  t_fixture
  root="$T_ROOT"
  home="$root/home"

  printf 'user overrides\n' > "$home/AGENTS.md"
  rm -rf "$home/.codex"
  ln -s "$home" "$home/.codex" || fatal "$T_CASE: cannot alias .codex to HOME"

  t_install "$root" --harnesses codex --overwrite
  t_assert_exit 2
  t_assert_line "refusing \$HOME/AGENTS.md alias:"
  t_assert_content "$home/AGENTS.md" "user overrides"
  t_assert_regular_directory "$home/.codex/skills/plan-ai-tools"

  t_cleanup "$root"
}

case_install_home_with_spaces() {
  local root home
  t_fixture
  root="$T_ROOT"
  mv "$root/home" "$root/home with spaces" || fatal "$T_CASE: cannot rename HOME"
  home="$root/home with spaces"

  t_run_at "$root" "$home" "$home/.ai-tools" \
    "$home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_regular_directory "$home/.claude/skills/plan-ai-tools"
  t_assert_regular_file "$home/.claude/CLAUDE.md"

  t_cleanup "$root"
}
