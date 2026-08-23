# shellcheck shell=bash
# update.sh — proves the update.sh half of rules 20-22 and 27: the reset
# guard refuses to discard local work until --discard-local is passed, stale
# copies are refreshed while locally modified copies are kept, newly shipped
# content is linked, and the clone's reset never reaches harness
# configuration or $HOME/AGENTS.md.

# --- Reset guard (rule 27) -----------------------------------------------------

case_update_reset_guard_dirty() {
  local root home wrapper before

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  wrapper="$home/.ai-tools/README.md"

  printf '\nlocal edit that has never been committed\n' >> "$wrapper"

  before=$(t_snapshot "$home/.claude")

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "local changes in"
  t_assert_line "the reset would discard the local work above"

  if grep -qF 'local edit that has never been committed' "$wrapper"; then
    ok "$T_CASE: local edit still present"
  else
    warn "$T_CASE: local edit lost"
  fi

  t_assert_unchanged "$home/.claude" "$before"

  t_cleanup "$root"
}

case_update_reset_guard_ahead() {
  local root home head_before head_after

  t_fixture
  root="$T_ROOT"
  home="$root/home"

  git -C "$home/.ai-tools" -c user.name="ai-tools test" -c user.email="test@example.invalid" \
    commit -q --allow-empty -m "local commit ahead of origin"
  head_before=$(git -C "$home/.ai-tools" rev-parse HEAD)

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "local commits ahead of origin/master:"

  head_after=$(git -C "$home/.ai-tools" rev-parse HEAD)
  if [ "$head_after" = "$head_before" ]; then
    ok "$T_CASE: HEAD unchanged"
  else
    warn "$T_CASE: HEAD moved: $head_before -> $head_after"
  fi

  t_cleanup "$root"
}

case_update_discard_local() {
  local root home wrapper origin_head head_after

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  wrapper="$home/.ai-tools/README.md"

  printf '\nlocal edit that has never been committed\n' >> "$wrapper"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code --discard-local
  t_assert_exit 0
  t_assert_line "ok: source at"

  origin_head=$(git -C "$home/.ai-tools" rev-parse origin/master)
  head_after=$(git -C "$home/.ai-tools" rev-parse HEAD)
  if [ "$head_after" = "$origin_head" ]; then
    ok "$T_CASE: HEAD equals origin/master"
  else
    warn "$T_CASE: HEAD $head_after != origin/master $origin_head"
  fi

  if grep -qF 'local edit that has never been committed' "$wrapper"; then
    warn "$T_CASE: local edit still present after discard"
  else
    ok "$T_CASE: local edit discarded"
  fi

  t_cleanup "$root"
}

case_update_reset_confined() {
  local root home agents_md foreign_path claude_md before_agents before_claude before_foreign

  t_fixture --foreign-agent
  root="$T_ROOT"
  home="$root/home"
  agents_md="$home/AGENTS.md"
  foreign_path="$T_FOREIGN_AGENT_PATH"
  claude_md="$home/.claude/CLAUDE.md"

  printf 'user content, never touched\n' > "$agents_md"
  printf 'harness config, never touched\n' > "$claude_md"

  before_agents=$(cat "$agents_md")
  before_claude=$(cat "$claude_md")
  before_foreign=$(cat "$foreign_path")

  printf '\nlocal edit\n' >> "$home/.ai-tools/README.md"
  git -C "$home/.ai-tools" -c user.name="ai-tools test" -c user.email="test@example.invalid" \
    add -A
  git -C "$home/.ai-tools" -c user.name="ai-tools test" -c user.email="test@example.invalid" \
    commit -q -m "local work"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code --discard-local
  # exit 2: verify_install warns that the foreign agent file and the
  # pre-filled CLAUDE.md differ from source — proof they were skipped, not
  # overwritten. The reset itself (rule 27) still succeeded (exit 0 would
  # require the pre-existing foreign content to be gone, which it must not be).
  t_assert_exit 2

  if [ "$(cat "$agents_md")" = "$before_agents" ]; then
    ok "$T_CASE: \$HOME/AGENTS.md untouched"
  else
    warn "$T_CASE: \$HOME/AGENTS.md changed"
  fi

  if [ "$(cat "$claude_md")" = "$before_claude" ]; then
    ok "$T_CASE: harness config untouched"
  else
    warn "$T_CASE: harness config changed"
  fi

  if [ "$(cat "$foreign_path")" = "$before_foreign" ]; then
    ok "$T_CASE: foreign file untouched"
  else
    warn "$T_CASE: foreign file changed"
  fi

  t_cleanup "$root"
}

# --- Newly shipped content (rule 20) -------------------------------------------

case_update_new_content_linked() {
  local root home marker

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  marker="linktest"

  t_run "$root" "$home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  t_assert_exit 0

  t_origin_commit "$marker"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 0
  t_assert_symlink "$home/.claude/skills/$marker-ai-tools" "$home/.ai-tools/skills/$marker-ai-tools"
  t_assert_line "already linked:"

  t_cleanup "$root"
}

# --- Copy refresh vs. preservation (rules 20-21) -------------------------------

case_update_stale_copy_refreshed() {
  local root home marker wrapper

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  marker="stalecopy"
  wrapper="$home/.claude/agents/implementer-ai-tools.md"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  # exit 2: the shimmed `ln` also blocks the instructions symlink (which has
  # no copy fallback), so verify_install warns "instructions missing" —
  # unrelated to the agent/skill copy fallback under test here.
  t_assert_exit 2
  t_assert_regular_file "$wrapper"

  t_origin_commit "$marker"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "copy refreshed:"

  if cmp -s "$wrapper" "$home/.ai-tools/agents/claude-code/implementer-ai-tools.md"; then
    ok "$T_CASE: copy matches refreshed source"
  else
    warn "$T_CASE: copy does not match refreshed source"
  fi

  t_cleanup "$root"
}

case_update_modified_copy_kept() {
  local root home marker wrapper before

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  marker="modcopy"
  wrapper="$home/.claude/agents/implementer-ai-tools.md"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  # exit 2: the shimmed `ln` also blocks the instructions symlink (no copy
  # fallback there), unrelated to the copy-preservation behavior under test.
  t_assert_exit 2

  printf '\nlocal edit that matches no revision\n' >> "$wrapper"
  before=$(cat "$wrapper")

  t_origin_commit "$marker"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "SKIP: copy modified locally (or predates"

  if [ "$(cat "$wrapper")" = "$before" ]; then
    ok "$T_CASE: modified copy preserved"
  else
    warn "$T_CASE: modified copy changed"
  fi

  t_cleanup "$root"
}

case_update_up_to_date_copy() {
  local root home marker wrapper

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  marker="uptodate"
  wrapper="$home/.claude/agents/planner-ai-tools.md"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/install.sh" --harnesses claude-code
  # exit 2: the shimmed `ln` also blocks the instructions symlink (no copy
  # fallback there), unrelated to the up-to-date-copy behavior under test.
  t_assert_exit 2

  # t_origin_commit only touches implementer-ai-tools.md; planner-ai-tools.md's
  # copy stays equal to its (unchanged) source across the reset.
  t_origin_commit "$marker"

  t_run_no_symlink "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 2
  t_assert_line "copy up to date: $wrapper"

  t_cleanup "$root"
}

# --- --no-reset / --dry-run ----------------------------------------------------

case_update_no_reset() {
  local root home before_head after_head

  t_fixture
  root="$T_ROOT"
  home="$root/home"

  printf '\nlocal edit\n' >> "$home/.ai-tools/README.md"
  before_head=$(git -C "$home/.ai-tools" rev-parse HEAD)

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code --no-reset

  case "$T_LAST_EXIT" in
    0|2) ok "$T_CASE: exit $T_LAST_EXIT (0 or 2 acceptable per the run's own findings)" ;;
    *) warn "$T_CASE: unexpected exit $T_LAST_EXIT" ;;
  esac
  t_assert_line "info: reset skipped (--no-reset)"

  after_head=$(git -C "$home/.ai-tools" rev-parse HEAD)
  if [ "$after_head" = "$before_head" ]; then
    ok "$T_CASE: HEAD unchanged"
  else
    warn "$T_CASE: HEAD moved: $before_head -> $after_head"
  fi

  if grep -qF 'local edit' "$home/.ai-tools/README.md"; then
    ok "$T_CASE: local edit intact"
  else
    warn "$T_CASE: local edit lost"
  fi

  t_cleanup "$root"
}

case_update_dry_run() {
  local root home before head_before head_after

  t_fixture
  root="$T_ROOT"
  home="$root/home"

  t_origin_commit "dryrun"
  head_before=$(git -C "$home/.ai-tools" rev-parse HEAD)

  before=$(t_snapshot "$home/.claude")

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code --dry-run
  t_assert_exit 0
  t_assert_line "would reset"
  t_assert_line "to origin/master"
  t_assert_line "dry-run: verification skipped"

  t_assert_unchanged "$home/.claude" "$before"

  head_after=$(git -C "$home/.ai-tools" rev-parse HEAD)
  if [ "$head_after" = "$head_before" ]; then
    ok "$T_CASE: HEAD unchanged"
  else
    warn "$T_CASE: HEAD moved: $head_before -> $head_after"
  fi

  t_cleanup "$root"
}

# --- Preconditions --------------------------------------------------------------

case_update_missing_clone() {
  local root home

  t_fixture
  root="$T_ROOT"
  home="$root/home"
  rm -rf "$home/.ai-tools"

  # home/.ai-tools no longer exists to execute; run the real repo's script
  # binary instead — t_run still confines HOME/AI_TOOLS to the sandbox, and
  # require_clone reads the sandboxed $AI_TOOLS env var, which is what
  # matters here.
  t_run "$root" "$AI_TOOLS/scripts/shell/update.sh" --harnesses claude-code
  t_assert_exit 1
  t_assert_line "is missing or not a clone — run scripts/shell/install.sh first"

  if [ -e "$home/.ai-tools" ]; then
    warn "$T_CASE: unexpectedly created: $home/.ai-tools"
  else
    ok "$T_CASE: nothing created: $home/.ai-tools"
  fi

  t_cleanup "$root"
}

case_update_fetch_failure() {
  local root home start end elapsed

  t_fixture
  root="$T_ROOT"
  home="$root/home"

  git -C "$home/.ai-tools" remote set-url origin "$root/does-not-exist.git"

  start=$(date +%s)
  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses claude-code
  end=$(date +%s)
  elapsed=$((end - start))

  t_assert_exit 1
  t_assert_line "fetch failed"

  if [ "$elapsed" -lt 15 ]; then
    ok "$T_CASE: returned promptly (${elapsed}s) — no network was attempted"
  else
    warn "$T_CASE: took ${elapsed}s — possible network attempt or hang"
  fi

  t_cleanup "$root"
}

case_update_preconditions() {
  local root home

  t_fixture
  root="$T_ROOT"
  home="$root/home"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses bogus
  t_assert_exit 1
  t_assert_line "unknown harness: bogus"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --harnesses
  t_assert_exit 1
  t_assert_line "--harnesses needs a value"

  t_run "$root" "$home/.ai-tools/scripts/shell/update.sh" --bogus-flag
  t_assert_exit 1
  t_assert_line "unknown option: --bogus-flag"

  t_cleanup "$root"
}
