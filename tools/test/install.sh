# shellcheck shell=bash
# install.sh case file — README rules 18-23, 26 against scripts/shell/install.sh.
# Each case builds its own fixture via t_fixture and passes an explicit
# --harnesses list so assertions can name exact destination paths.

t_install() {
  # usage: t_install <root> [args...] -- runs install.sh under test
  local root="$1"
  shift
  t_run "$root" "$root/home/.ai-tools/scripts/shell/install.sh" "$@"
}

case_install_fresh() {
  # Rule 17: fresh install links every wrapper, skill and the instructions.
  local root f base
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0

  for f in "$root/home/.ai-tools/agents/claude-code"/*-ai-tools*; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    t_assert_symlink "$root/home/.claude/agents/$base" "$root/home/.ai-tools"
  done

  for f in "$root/home/.ai-tools/skills"/*-ai-tools; do
    [ -d "$f" ] || continue
    base=$(basename "$f")
    t_assert_symlink "$root/home/.claude/skills/$base" "$root/home/.ai-tools"
  done

  t_assert_symlink "$root/home/.claude/CLAUDE.md" "$root/home/.ai-tools"
  t_assert_line "linked:"
  t_assert_no_line "WARN:"

  t_cleanup "$root"
}

case_install_idempotent() {
  # Rule 20: running install.sh twice changes nothing on the second run.
  local root before
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0

  before=$(t_snapshot "$root/home/.claude")
  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "already linked:"
  t_assert_no_line "SKIP:"
  t_assert_no_line "WARN:"
  t_assert_unchanged "$root/home/.claude" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_foreign_file_skipped() {
  # Rules 18, 20, 25: a foreign regular file on a destination is skipped, not
  # overwritten, and the run still finishes the rest of the wrappers.
  local root
  t_fixture --foreign-agent
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "SKIP: exists, not overwriting: $T_FOREIGN_AGENT_PATH"
  t_assert_regular_file "$T_FOREIGN_AGENT_PATH"
  t_assert_content "$T_FOREIGN_AGENT_PATH" "not an ai-tools file"
  t_assert_symlink "$root/home/.claude/agents/implementer-ai-tools.md" "$root/home/.ai-tools"

  t_cleanup "$root"
}

case_install_symlink_elsewhere_skipped() {
  # A symlink pointing outside ai-tools is skipped, not replaced.
  local root before_target
  t_fixture --external-symlink
  root="$T_ROOT"
  before_target=$(readlink "$T_EXTERNAL_SYMLINK_PATH")

  # verify_install's link check only tests -L, not target resolution (see
  # Implementation log): a stray symlink is SKIPped by install_agents but
  # never WARNed by the trailing verify pass, so the run exits 0, not 2.
  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "SKIP: symlink points elsewhere: $T_EXTERNAL_SYMLINK_PATH"
  if [ "$(readlink "$T_EXTERNAL_SYMLINK_PATH")" = "$before_target" ]; then
    ok "$T_CASE: symlink target unchanged: $T_EXTERNAL_SYMLINK_PATH"
  else
    warn "$T_CASE: symlink target changed: $T_EXTERNAL_SYMLINK_PATH"
  fi

  t_cleanup "$root"
}

case_install_agents_md_absent() {
  # Rule 22: $HOME/AGENTS.md is created empty when absent.
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "ok: created empty: $root/home/AGENTS.md"
  t_assert_regular_file "$root/home/AGENTS.md"
  if [ -s "$root/home/AGENTS.md" ]; then
    warn "$T_CASE: AGENTS.md is not empty: $root/home/AGENTS.md"
  else
    ok "$T_CASE: AGENTS.md is empty: $root/home/AGENTS.md"
  fi

  t_cleanup "$root"
}

case_install_agents_md_present() {
  # Rule 22: $HOME/AGENTS.md is user-owned and never touched when present.
  local root
  t_fixture
  root="$T_ROOT"
  printf 'user overrides\n' > "$root/home/AGENTS.md"

  t_install "$root" --harnesses claude-code
  t_assert_exit 0
  t_assert_line "ok: already present, untouched: $root/home/AGENTS.md"
  t_assert_content "$root/home/AGENTS.md" "user overrides"
  if [ -L "$root/home/AGENTS.md" ]; then
    warn "$T_CASE: AGENTS.md became a symlink: $root/home/AGENTS.md"
  else
    ok "$T_CASE: AGENTS.md is not a symlink: $root/home/AGENTS.md"
  fi

  t_cleanup "$root"
}

case_install_dry_run() {
  # Rule 25: --dry-run reports without changing anything.
  local root before
  t_fixture
  root="$T_ROOT"

  before=$(t_snapshot "$root/home")
  t_install "$root" --harnesses claude-code --dry-run
  t_assert_exit 0
  t_assert_line "would link:"
  t_assert_line "(dry-run: nothing was changed)"
  t_assert_line "info: dry-run: verification skipped"
  t_assert_unchanged "$root/home" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_no_symlink_fallback() {
  # Rule 17: symlink-to-copy fallback when the OS/fs refuses symlinks; the
  # single instructions destination is never copied (single source of truth).
  local root f base
  t_fixture
  root="$T_ROOT"

  t_run_no_symlink "$root" "$root/home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "ok: copied (will not track updates):"

  for f in "$root/home/.ai-tools/agents/claude-code"/*-ai-tools*; do
    [ -f "$f" ] || continue
    base=$(basename "$f")
    t_assert_regular_file "$root/home/.claude/agents/$base"
  done

  t_assert_absent "$root/home/.claude/CLAUDE.md"
  t_assert_line "WARN: symlink refused for $root/home/.claude/CLAUDE.md — add a one-line include pointer"

  t_cleanup "$root"
}

case_install_grok_models() {
  # Grok model pinning: names from the tree, models from the fixture's own
  # MODELS.md, resolved through the shipped model_for (never a hard-coded
  # vendor name here).
  local root saved_map planner_model implementer_model mechanical_model
  t_fixture
  root="$T_ROOT"

  saved_map="$MODELS_MAP"
  MODELS_MAP="$root/home/.ai-tools/MODELS.md"
  planner_model=$(model_for grok planner)
  implementer_model=$(model_for grok implementer)
  mechanical_model=$(model_for grok mechanical)
  MODELS_MAP="$saved_map"

  if [ -z "$planner_model" ] || [ -z "$implementer_model" ] || [ -z "$mechanical_model" ]; then
    warn "$T_CASE: could not resolve grok models from fixture MODELS.md"
    t_cleanup "$root"
    return 0
  fi

  t_install "$root" --harnesses grok
  t_assert_exit 0
  t_assert_line "ok: grok models block appended: $root/home/.grok/config.toml"
  t_assert_content "$root/home/.grok/config.toml" "planner-ai-tools = \"$planner_model\""
  t_assert_content "$root/home/.grok/config.toml" "implementer-ai-tools = \"$implementer_model\""
  t_assert_content "$root/home/.grok/config.toml" "mechanical-ai-tools = \"$mechanical_model\""

  t_install "$root" --harnesses grok
  t_assert_exit 0
  t_assert_line "ok: grok models block up to date: $root/home/.grok/config.toml"

  t_cleanup "$root"
}

case_install_grok_unmanaged_block() {
  # An unmanaged [subagents.models] block is left untouched, not merged into.
  local root before
  t_fixture --unmanaged-grok-block
  root="$T_ROOT"
  before=$(t_snapshot "$T_GROK_UNMANAGED_PATH")

  t_install "$root" --harnesses grok
  t_assert_exit 0
  t_assert_line "SKIP: unmanaged [subagents.models] already in $T_GROK_UNMANAGED_PATH"
  t_assert_unchanged "$T_GROK_UNMANAGED_PATH" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_grok_no_model_row() {
  # No usable `grok` row in MODELS.md: pinning is skipped, config untouched.
  local root before
  t_fixture
  root="$T_ROOT"
  # shellcheck disable=SC2016 # single quotes are deliberate, nothing here should expand
  sed -i.bak '/^| `grok`/d' "$root/home/.ai-tools/MODELS.md" \
    || fatal "$T_CASE: cannot strip grok row from fixture MODELS.md"
  rm -f "$root/home/.ai-tools/MODELS.md.bak"

  before=$(t_snapshot "$root/home/.grok/config.toml")
  t_install "$root" --harnesses grok
  t_assert_exit 0
  t_assert_line "SKIP: grok model pinning: no usable"
  t_assert_absent "$root/home/.grok/config.toml"
  t_assert_unchanged "$root/home/.grok/config.toml" "$before"
  rm -f "$before"

  t_cleanup "$root"
}

case_install_antigravity_instructions() {
  # Antigravity uses GEMINI.md plus config/{agents,skills}. Do not install
  # into the retired Gemini CLI roots ~/.gemini/agents or ~/.gemini/skills.
  local root
  t_fixture
  root="$T_ROOT"

  t_install "$root" --harnesses antigravity
  t_assert_exit 0
  t_assert_symlink "$root/home/.gemini/GEMINI.md" "$root/home/.ai-tools"
  t_assert_symlink "$root/home/.gemini/config/agents/planner-ai-tools.md" "$root/home/.ai-tools"
  t_assert_symlink "$root/home/.gemini/config/skills/plan-ai-tools" "$root/home/.ai-tools"
  t_assert_symlink "$root/home/.gemini/config/skills/agy-ai-tools" "$root/home/.ai-tools"
  t_assert_absent "$root/home/.gemini/agents/planner-ai-tools.md"
  t_assert_absent "$root/home/.gemini/skills/plan-ai-tools"
  t_assert_absent "$root/home/.gemini/skills/planner-ai-tools"

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
