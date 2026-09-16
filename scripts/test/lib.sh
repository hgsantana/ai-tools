# shellcheck shell=bash
# ai-tools sandboxed test helpers — sourced by scripts/test.sh, after
# scripts/shell/lib.sh, and in scope for every case file under scripts/test/.
#
# Every helper here is t_-prefixed so nothing shadows a name already owned
# by scripts/shell/lib.sh (same_content, safe_copy, ok, warn, fatal, ...).
#
# Sandbox safety is this file's first requirement: t_run and its siblings
# refuse to execute anything unless the sandbox root is non-empty, is not
# "/", and both HOME and AI_TOOLS resolve under it. A HOME that escaped the
# sandbox would run scripts against the caller's real installation — this
# guard is what makes the suite safe to run on a maintainer's machine.

set -u

KEEP="${KEEP:-0}"
T_CASE=""
T_LAST_EXIT=0
T_LAST_OUTPUT=""
T_ROOT=""
T_FOREIGN_SKILL_PATH=""
T_FOREIGN_INSTRUCTIONS_PATH=""
T_MODIFIED_COPY_PATH=""
T_STALE_LINK_PATH=""
T_EXTERNAL_SYMLINK_PATH=""

# --- Fixture -----------------------------------------------------------------

T_HARNESS_DIRS="
.claude/skills
.grok/skills
.codex/skills
.copilot/skills
.copilot/instructions
.cursor/skills
.cursor/rules
.gemini/config/skills
"

t_build_origin() {
  # usage: t_build_origin <origin-git-dir>
  # Tars the working tree (excluding .git and dev/) into a scratch commit
  # and pushes it to a fresh bare repo at <origin-git-dir>. The tree under
  # test is the *working* tree, including any uncommitted change.
  local origin="$1" scratch
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-test-src.XXXXXX") || return 1

  git init -q --bare "$origin" || return 1
  git --git-dir="$origin" symbolic-ref HEAD refs/heads/master || return 1

  # shellcheck disable=SC2153 # AI_TOOLS is exported by scripts/test.sh, not a typo for the local ai_tools
  ( cd "$AI_TOOLS" && tar -cpf - --exclude=./.git --exclude=./dev . ) \
    | ( cd "$scratch" && tar -xpf - ) || { rm -rf "$scratch"; return 1; }

  git -C "$scratch" init -q || { rm -rf "$scratch"; return 1; }
  git -C "$scratch" symbolic-ref HEAD refs/heads/master
  git -C "$scratch" config user.name "ai-tools test"
  git -C "$scratch" config user.email "test@example.invalid"
  git -C "$scratch" add -A
  git -C "$scratch" commit -q -m "fixture origin" || { rm -rf "$scratch"; return 1; }
  git -C "$scratch" remote add origin "$origin" || { rm -rf "$scratch"; return 1; }
  git -C "$scratch" push -q origin master || { rm -rf "$scratch"; return 1; }
  rm -rf "$scratch"
}

t_fixture() {
  # usage: t_fixture [--foreign-skill] [--foreign-instructions]
  #                   [--modified-copy] [--stale-link] [--external-symlink]
  # Builds a disposable sandbox under ${TMPDIR:-/tmp} and sets T_ROOT to its
  # root. Called plainly (never `root=$(t_fixture ...)`) so the T_* option
  # variables it sets land in the caller's shell, not a lost subshell.
  # Each option records the path(s) it staged in a T_* variable the calling
  # case can read.
  local home origin dir root

  root=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-test.XXXXXX") || fatal "t_fixture: mktemp -d failed"
  T_ROOT="$root"
  home="$root/home"
  origin="$root/origin.git"
  mkdir -p "$home" || fatal "t_fixture: cannot create $home"

  for dir in $T_HARNESS_DIRS; do
    mkdir -p "$home/$dir" || fatal "t_fixture: cannot create $home/$dir"
  done

  t_build_origin "$origin" || fatal "t_fixture: cannot build fixture origin: $origin"

  git clone -q "$origin" "$home/.ai-tools" >/dev/null 2>&1 \
    || fatal "t_fixture: cannot clone fixture origin into $home/.ai-tools"

  cat > "$home/.gitconfig" <<EOF
[user]
	name = ai-tools test
	email = test@example.invalid
[url "file://$origin"]
	insteadOf = https://github.com/hgsantana/ai-tools.git
EOF

  T_FOREIGN_SKILL_PATH=""
  T_FOREIGN_INSTRUCTIONS_PATH=""
  T_MODIFIED_COPY_PATH=""
  T_STALE_LINK_PATH=""
  T_EXTERNAL_SYMLINK_PATH=""

  while [ $# -gt 0 ]; do
    case "$1" in
      --foreign-skill)
        mkdir -p "$home/.claude/skills/plan-ai-tools" || fatal "t_fixture: cannot create $home/.claude/skills/plan-ai-tools"
        T_FOREIGN_SKILL_PATH="$home/.claude/skills/plan-ai-tools"
        printf 'not an ai-tools file\n' > "$T_FOREIGN_SKILL_PATH/SKILL.md"
        ;;
      --foreign-instructions)
        T_FOREIGN_INSTRUCTIONS_PATH="$home/.claude/CLAUDE.md"
        printf 'not an ai-tools file\n' > "$T_FOREIGN_INSTRUCTIONS_PATH"
        ;;
      --modified-copy)
        T_MODIFIED_COPY_PATH="$home/.claude/skills/dev-ai-tools"
        cp -R "$home/.ai-tools/skills/dev-ai-tools" "$T_MODIFIED_COPY_PATH" \
          || fatal "t_fixture: cannot stage modified copy"
        printf '\nlocal edit that matches no revision\n' >> "$T_MODIFIED_COPY_PATH/SKILL.md"
        ;;
      --stale-link)
        T_STALE_LINK_PATH="$home/.claude/skills/old-layout-ai-tools"
        ln -s "$home/.ai-tools/skills/plan-ai-tools" "$T_STALE_LINK_PATH" \
          || fatal "t_fixture: cannot create stale-link fixture"
        ;;
      --external-symlink)
        mkdir -p "$root/external-skill" || fatal "t_fixture: cannot create $root/external-skill"
        printf 'outside ai-tools\n' > "$root/external-skill/SKILL.md"
        T_EXTERNAL_SYMLINK_PATH="$home/.claude/skills/az-ai-tools"
        ln -s "$root/external-skill" "$T_EXTERNAL_SYMLINK_PATH" \
          || fatal "t_fixture: cannot create external-symlink fixture"
        ;;
      *) fatal "t_fixture: unknown option: $1" ;;
    esac
    shift
  done
}

t_cleanup() {
  # usage: t_cleanup <sandbox-root> -- removes the sandbox unless --keep.
  # Removal target must be under ${TMPDIR:-/tmp} and the exact path t_fixture
  # returned.
  local root="$1"
  if [ "$KEEP" = 1 ]; then
    info "${T_CASE:-t_cleanup}: sandbox kept: $root"
    return 0
  fi
  case "$root" in
    "${TMPDIR:-/tmp}"/ai-tools-test.*) rm -rf "$root" ;;
    *) warn "${T_CASE:-t_cleanup}: refusing to remove unexpected sandbox path: $root" ;;
  esac
}

# --- Sandboxed runner ---------------------------------------------------------

t_sandbox_guard() {
  # usage: t_sandbox_guard <root> <home> <ai_tools>
  # Aborts (fatal, exit 1) before anything executes unless every path is
  # confined to the sandbox root. This is the suite's single most important
  # check.
  local root="$1" home="$2" ai_tools="$3"
  [ -n "$root" ] || fatal "t_sandbox_guard: sandbox root is empty"
  [ "$root" != "/" ] || fatal "t_sandbox_guard: sandbox root is '/'"
  case "$home" in
    "$root"/*) ;;
    *) fatal "t_sandbox_guard: HOME escaped the sandbox: $home (root: $root)" ;;
  esac
  case "$ai_tools" in
    "$root"/*) ;;
    *) fatal "t_sandbox_guard: AI_TOOLS escaped the sandbox: $ai_tools (root: $root)" ;;
  esac
}

t_run_at() {
  # usage: t_run_at <root> <home> <ai_tools> <script> [args...]
  # Same as t_run with an explicit HOME and AI_TOOLS (spaces, foreign
  # AI_TOOLS probes). Both paths must still stay under <root>.
  local root="$1" home="$2" ai_tools="$3" script="$4" out
  shift 4
  t_sandbox_guard "$root" "$home" "$ai_tools"
  out=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-out.XXXXXX") || fatal "t_run_at: mktemp failed"
  env -i \
    PATH="$PATH" \
    HOME="$home" \
    USERPROFILE="$home" \
    AI_TOOLS="$ai_tools" \
    GIT_TERMINAL_PROMPT=0 \
    GIT_CONFIG_NOSYSTEM=1 \
    TERM="${TERM:-dumb}" \
    LANG="${LANG:-C}" \
    "$script" "$@" >"$out" 2>&1
  T_LAST_EXIT=$?
  T_LAST_OUTPUT=$(cat "$out")
  rm -f "$out"
}

t_run() {
  # usage: t_run <root> <script> [args...]
  # Runs one script confined to the sandbox; captured output and exit code
  # land in T_LAST_OUTPUT / T_LAST_EXIT.
  local root="$1" script="$2"
  shift 2
  t_run_at "$root" "$root/home" "$root/home/.ai-tools" "$script" "$@"
}

t_run_stdin() {
  # usage: t_run_stdin <root> <stdin-string> <script> [args...]
  # Same as t_run, feeding <stdin-string> plus a trailing newline on stdin
  # (for purge_clone's confirmation prompt, read via `read -r`).
  local root="$1" input="$2" script="$3" home ai_tools out
  shift 3
  home="$root/home"
  ai_tools="$root/home/.ai-tools"
  t_sandbox_guard "$root" "$home" "$ai_tools"
  out=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-out.XXXXXX") || fatal "t_run_stdin: mktemp failed"
  printf '%s\n' "$input" | env -i \
    PATH="$PATH" \
    HOME="$home" \
    USERPROFILE="$home" \
    AI_TOOLS="$ai_tools" \
    GIT_TERMINAL_PROMPT=0 \
    GIT_CONFIG_NOSYSTEM=1 \
    TERM="${TERM:-dumb}" \
    LANG="${LANG:-C}" \
    "$script" "$@" >"$out" 2>&1
  T_LAST_EXIT=$?
  T_LAST_OUTPUT=$(cat "$out")
  rm -f "$out"
}

# --- Assertions ----------------------------------------------------------------
# Each reports through ok/warn with the case name and the offending value;
# none aborts the suite.

t_assert_exit() {
  local expected="$1"
  if [ "$T_LAST_EXIT" = "$expected" ]; then
    ok "$T_CASE: exit $expected"
  else
    warn "$T_CASE: expected exit $expected, got $T_LAST_EXIT"
  fi
}

t_assert_line() {
  local pattern="$1"
  if printf '%s\n' "$T_LAST_OUTPUT" | grep -qF -- "$pattern"; then
    ok "$T_CASE: output contains: $pattern"
  else
    warn "$T_CASE: output missing: $pattern"
  fi
}

t_assert_no_line() {
  local pattern="$1"
  if printf '%s\n' "$T_LAST_OUTPUT" | grep -qF -- "$pattern"; then
    warn "$T_CASE: output unexpectedly contains: $pattern"
  else
    ok "$T_CASE: output does not contain: $pattern"
  fi
}

t_assert_symlink() {
  local path="$1" prefix="$2" target
  if [ -L "$path" ]; then
    target=$(readlink "$path")
    case "$target" in
      "$prefix"*) ok "$T_CASE: symlink: $path -> $target" ;;
      *) warn "$T_CASE: symlink target unexpected: $path -> $target (want prefix: $prefix)" ;;
    esac
  else
    warn "$T_CASE: not a symlink: $path"
  fi
}

t_assert_regular_file() {
  local path="$1"
  if [ -f "$path" ] && [ ! -L "$path" ]; then
    ok "$T_CASE: regular file: $path"
  else
    warn "$T_CASE: not a regular file: $path"
  fi
}

t_assert_regular_directory() {
  local path="$1"
  if [ -d "$path" ] && [ ! -L "$path" ]; then
    ok "$T_CASE: regular directory: $path"
  else
    warn "$T_CASE: not a regular directory: $path"
  fi
}

t_assert_same_content() {
  local actual="$1" expected="$2"
  if same_content "$actual" "$expected"; then
    ok "$T_CASE: content matches source: $actual"
  else
    warn "$T_CASE: content differs from source: $actual (source: $expected)"
  fi
}

t_assert_absent() {
  local path="$1"
  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    ok "$T_CASE: absent: $path"
  else
    warn "$T_CASE: unexpectedly present: $path"
  fi
}

t_assert_content() {
  local path="$1" expected="$2"
  if [ -f "$path" ] && grep -qF -- "$expected" "$path"; then
    ok "$T_CASE: content matches: $path"
  else
    warn "$T_CASE: content mismatch: $path (want: $expected)"
  fi
}

t_snapshot() {
  # usage: t_snapshot <dir> -- echoes the path to a manifest file: a sorted
  # find listing plus each file's content, concatenated. cmp -s between two
  # snapshots provides a cheap "did anything change" check without depending
  # on md5sum/sha1sum/cksum (not in this suite's dependency list).
  local dir="$1" snap
  snap=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-snap.XXXXXX") || fatal "t_snapshot: mktemp failed"
  {
    find "$dir" \( -type f -o -type l \) -print 2>/dev/null | LC_ALL=C sort
    echo "---"
    find "$dir" \( -type f -o -type l \) -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r f; do
      if [ -L "$f" ]; then
        readlink "$f"
      else
        cat "$f"
      fi
    done
  } > "$snap"
  echo "$snap"
}

t_assert_unchanged() {
  # usage: t_assert_unchanged <dir> <snapshot-file> -- <snapshot-file> is a
  # path previously returned by t_snapshot, taken before the run under test.
  local dir="$1" before="$2" after
  after=$(t_snapshot "$dir")
  if cmp -s "$before" "$after"; then
    ok "$T_CASE: unchanged: $dir"
  else
    warn "$T_CASE: changed: $dir"
  fi
  rm -f "$after"
}

# --- Origin mutation (stage 4: update contract) -------------------------------

t_origin_commit() {
  # usage: t_origin_commit <label>
  # Clones the fixture's bare origin (T_ROOT/origin.git) into a scratch dir,
  # makes deterministic changes — appends marker lines to USER-AGENTS.md and
  # the existing skills/plan-ai-tools/SKILL.md file, then adds a new
  # skills/<label>-ai-tools/ directory containing SKILL.md (the single-file
  # layout the repository ships) — commits and pushes to master, giving the fixture's clone
  # something new to update to. Returns nothing; the caller already knows the
  # paths it named via <label>.
  local label="$1" origin scratch
  origin="$T_ROOT/origin.git"
  scratch=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-test-origin-commit.XXXXXX") \
    || fatal "t_origin_commit: mktemp -d failed"

  git clone -q "$origin" "$scratch" >/dev/null 2>&1 \
    || fatal "t_origin_commit: cannot clone $origin"
  git -C "$scratch" config user.name "ai-tools test" \
    || fatal "t_origin_commit: git config user.name failed"
  git -C "$scratch" config user.email "test@example.invalid" \
    || fatal "t_origin_commit: git config user.email failed"

  printf '\n<!-- t_origin_commit marker: %s -->\n' "$label" \
    >> "$scratch/USER-AGENTS.md" \
    || fatal "t_origin_commit: cannot append marker to instructions"

  printf '\n<!-- t_origin_commit marker: %s -->\n' "$label" \
    >> "$scratch/skills/plan-ai-tools/SKILL.md" \
    || fatal "t_origin_commit: cannot append marker to existing skill"

  mkdir -p "$scratch/skills/$label-ai-tools" \
    || fatal "t_origin_commit: cannot create skill dir"
  cat > "$scratch/skills/$label-ai-tools/SKILL.md" <<EOF
---
name: $label-ai-tools
description: Test-only skill added by t_origin_commit for marker $label. Impact: none.
---

# $label

Test-only skill. Never shipped.
EOF

  git -C "$scratch" add -A || fatal "t_origin_commit: git add failed"
  git -C "$scratch" commit -q -m "t_origin_commit: $label" \
    || fatal "t_origin_commit: git commit failed"
  git -C "$scratch" push -q origin master || fatal "t_origin_commit: git push failed"
  rm -rf "$scratch"
}
