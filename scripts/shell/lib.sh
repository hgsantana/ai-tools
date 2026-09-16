# shellcheck shell=bash
# ai-tools shared helpers — sourced by every script in scripts/shell/.
# Compatible with bash 3.2+ (macOS default) and BSD/GNU userlands.
# Windows: WSL or Git Bash. No PowerShell mirror.

set -u

AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"
REPO_URL="https://github.com/hgsantana/ai-tools.git"
ALL_HARNESSES="claude-code grok codex copilot cursor antigravity"

DRY_RUN=0
OVERWRITE=0
FORCE=0
SCOPE=""
FRESH_CLONE=0
PREV=""
SOURCE_TREE=""
UPDATE_DRY_PLAN=0
DRY_RUN_FETCHED=0
DRY_GONE=""
OK=0 SKIP=0 WARN=0

ok()   { OK=$((OK+1));     printf 'ok: %s\n'   "$*"; }
skip() { SKIP=$((SKIP+1)); printf 'SKIP: %s\n' "$*"; }
warn() { WARN=$((WARN+1)); printf 'WARN: %s\n' "$*"; }
info() { printf 'info: %s\n' "$*"; }
fatal(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }

finish() {
  suffix=""
  if [ "$DRY_RUN" = 1 ]; then
    if [ "$DRY_RUN_FETCHED" = 1 ]; then
      suffix=" (dry-run: harness state unchanged; remote-tracking refs may have been updated)"
    else
      suffix=" (dry-run: nothing was changed)"
    fi
  fi
  printf 'done: %d ok, %d skipped, %d warnings%s\n' "$OK" "$SKIP" "$WARN" "$suffix"
  [ "$WARN" -gt 0 ] && exit 2
  exit 0
}

# Tree install copies from. Update --dry-run points this at an archive of
# origin/master so the approval report includes incoming artifacts.
source_root() {
  if [ -n "${SOURCE_TREE:-}" ]; then
    printf '%s' "$SOURCE_TREE"
  else
    printf '%s' "$AI_TOOLS"
  fi
}

ext_roots() {
  printf '%s\n' \
    "$HOME/.vscode/extensions" \
    "$HOME/.vscode-server/extensions" \
    "$HOME/.vscode-insiders/extensions" \
    "$HOME/.vscode-server-insiders/extensions" \
    "$HOME/.vscodium/extensions"
}

# Resolve an existing path, or the longest existing ancestor plus the missing
# tail, so parent-directory symlinks are visible before a mutation.
canonical_path() {
  local path="$1" cur tail resolved
  [ -n "$path" ] || return 1
  cur="$path"
  tail=""
  while :; do
    if [ -e "$cur" ] || [ -L "$cur" ]; then
      resolved=$(readlink -f "$cur" 2>/dev/null || printf '%s' "$cur")
      printf '%s%s\n' "$resolved" "$tail"
      return 0
    fi
    [ "$cur" = "/" ] && break
    tail="/${cur##*/}$tail"
    case "$cur" in
      */*)
        cur="${cur%/*}"
        [ -n "$cur" ] || cur="/"
        ;;
      *) break ;;
    esac
  done
  printf '%s\n' "$path"
}

is_home_agents_alias() {
  local dest="$1" resolved protected
  [ -n "$dest" ] || return 1
  case "$dest" in
    "$HOME/AGENTS.md"|"$HOME/AGENTS.md/") return 0 ;;
  esac
  resolved=$(canonical_path "$dest")
  protected=$(canonical_path "$HOME/AGENTS.md")
  [ "$resolved" = "$protected" ]
}

refuse_protected_dest() {
  local dest="$1"
  if is_home_agents_alias "$dest"; then
    warn "refusing \$HOME/AGENTS.md alias: $dest"
    return 0
  fi
  return 1
}

assert_supported_clone_path() {
  local expected="$HOME/.ai-tools"
  [ -n "$AI_TOOLS" ] || fatal "AI_TOOLS is empty"
  case "$AI_TOOLS" in
    /|"$HOME"|"$HOME/") fatal "AI_TOOLS is an unsafe path: $AI_TOOLS" ;;
  esac
  [ "$AI_TOOLS" = "$expected" ] && return 0
  if [ -e "$AI_TOOLS" ] || [ -L "$AI_TOOLS" ]; then
    [ "$(canonical_path "$AI_TOOLS")" = "$(canonical_path "$expected")" ] && return 0
  fi
  fatal "AI_TOOLS must be $expected (the only supported clone location); got: $AI_TOOLS"
}

# --- Harness table (mirrors "Supported harnesses" in README.md) -------------

skills_root() {
  case "$1" in
    claude-code) echo "$HOME/.claude/skills" ;;
    grok)        echo "$HOME/.grok/skills" ;;
    codex)       echo "$HOME/.codex/skills" ;;
    copilot)     echo "$HOME/.copilot/skills" ;;
    cursor)      echo "$HOME/.cursor/skills" ;;
    antigravity) echo "$HOME/.gemini/config/skills" ;;
  esac
}

instructions_dest() {
  case "$1" in
    claude-code) echo "$HOME/.claude/CLAUDE.md" ;;
    grok)        echo "$HOME/.grok/AGENTS.md" ;;
    codex)       echo "$HOME/.codex/AGENTS.md" ;;
    copilot)     echo "$HOME/.copilot/instructions/ai-tools.instructions.md" ;;
    antigravity) echo "$HOME/.gemini/GEMINI.md" ;;
    cursor)      echo "$HOME/.cursor/rules/ai-tools.mdc" ;;
  esac
}

# --- Discovery ---------------------------------------------------------------

has_extension() {
  # usage: has_extension <extension-id-prefix>
  local root d
  while IFS= read -r root; do
    [ -d "$root" ] || continue
    for d in "$root/$1"*; do [ -d "$d" ] && return 0; done
  done < <(ext_roots)
  return 1
}

harness_detected() {
  case "$1" in
    claude-code) [ -d "$HOME/.claude" ] || has_extension anthropic.claude-code- ;;
    grok)        [ -d "$HOME/.grok" ] || command -v grok >/dev/null 2>&1 ;;
    codex)       [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1 || has_extension openai.chatgpt- ;;
    copilot)     [ -d "$HOME/.copilot" ] || command -v copilot >/dev/null 2>&1 || has_extension github.copilot-chat- ;;
    cursor)      [ -d "$HOME/.cursor" ] ;;
    antigravity) [ -d "$HOME/.gemini/config" ] || command -v antigravity >/dev/null 2>&1 ;;
    *) return 1 ;;
  esac
}

detect_harnesses() {
  local h out=""
  for h in $ALL_HARNESSES; do
    harness_detected "$h" && out="$out $h"
  done
  echo "$out"
}

report_discovery() {
  local h root name entry jb nocasematch_was_set=0
  for h in $ALL_HARNESSES; do
    harness_detected "$h" && info "found: $h"
  done
  [ -d "$HOME/.agents" ] && info "found: $HOME/.agents (shared discovery root — left untouched)"
  # Informational-only: possible AI extensions with no confirmed config convention.
  # Glob instead of `ls | grep` so names with non-alphanumeric characters
  # (spaces, globs, newlines) are handled correctly; nocasematch replaces
  # the two grep -i passes and is restored to its prior state on exit.
  shopt -q nocasematch && nocasematch_was_set=1
  shopt -s nocasematch
  while IFS= read -r root; do
    [ -d "$root" ] || continue
    for entry in "$root"/*; do
      [ -e "$entry" ] || continue
      name=${entry##*/}
      case "$name" in
        *gemini*|*claude*|*codeium*|*windsurf*|*antigravity*|*continue*|*cody*|*cursor*|*tabnine*) ;;
        *) continue ;;
      esac
      case "$name" in
        google.geminicodeassist*|anthropic.claude-code*|openai.chatgpt*|github.copilot*) continue ;;
      esac
      info "possible AI extension (not offered): $name in $root"
    done
  done < <(
    ext_roots
    for jb in "$HOME"/.local/share/JetBrains/*/plugins; do
      [ -d "$jb" ] && printf '%s\n' "$jb"
    done
  )
  [ "$nocasematch_was_set" = 1 ] || shopt -u nocasematch
  return 0
}

set_scope() {
  # usage: set_scope "<comma/space list|all>"
  # Empty selects detected harnesses; literal "all" selects every supported one.
  local requested="${1:-}" h k valid
  if [ -z "$requested" ]; then
    SCOPE=$(detect_harnesses)
    [ -n "${SCOPE// /}" ] || fatal "no supported harness detected; pass --harnesses <list> (valid: all $ALL_HARNESSES)"
  elif [ "$requested" = "all" ]; then
    SCOPE=" $ALL_HARNESSES"
  else
    SCOPE=""
    for h in $(echo "$requested" | tr ',' ' '); do
      valid=0
      for k in $ALL_HARNESSES; do [ "$h" = "$k" ] && valid=1; done
      [ "$valid" = 1 ] || fatal "unknown harness: $h (valid: all $ALL_HARNESSES)"
      case " $SCOPE " in
        *" $h "*) ;; # deduplicate while preserving the requested order
        *) SCOPE="$SCOPE $h" ;;
      esac
    done
  fi
  info "scope:$SCOPE"
}

each_scoped_root() {
  local h
  for h in $SCOPE; do
    skills_root "$h"
  done | sort -u
}

scoped_roots() {
  each_scoped_root
}

mark_dry_gone() {
  DRY_GONE="${DRY_GONE}
$1"
}

is_dry_gone() {
  [ -n "$DRY_GONE" ] || return 1
  printf '%s\n' "$DRY_GONE" | grep -Fxq -- "$1"
}

# --- Filesystem safety primitives (README "Safety rules") --------------------
# Never overwrite or delete anything that is not an ai-tools link or an
# unmodified ai-tools copy unless the caller explicitly selected --overwrite
# (replace) or --force (remove a known destination whose contents differ).
# On conflict, skip and report; keep every operation idempotent.

same_content() {
  # files or directories
  if [ -f "$1" ] && [ -f "$2" ]; then cmp -s "$1" "$2"
  elif [ -d "$1" ] && [ -d "$2" ]; then diff -rq "$1" "$2" >/dev/null 2>&1
  else return 1
  fi
}

is_ai_tools_link() {
  # usage: is_ai_tools_link <symlink>
  # Old installers created absolute links. Resolution also covers relative
  # links and a moved but still existing clone without trusting name fragments.
  local dest="$1" target resolved root_resolved
  [ -L "$dest" ] || return 1
  target=$(readlink "$dest")
  case "$target" in
    "$AI_TOOLS"|"$AI_TOOLS"/*) return 0 ;;
  esac
  resolved=$(readlink -f "$dest" 2>/dev/null || true)
  root_resolved=$(readlink -f "$AI_TOOLS" 2>/dev/null || printf '%s' "$AI_TOOLS")
  case "$resolved" in
    "$AI_TOOLS"|"$AI_TOOLS"/*|"$root_resolved"|"$root_resolved"/*) return 0 ;;
  esac
  return 1
}

copy_artifact() {
  # usage: copy_artifact <source> <destination> <install|migrate|overwrite|refresh>
  # The destination is one explicit harness artifact, never a harness root.
  local src="$1" dest="$2" action="$3" dry_message done_message
  refuse_protected_dest "$dest" && return 1
  case "$action" in
    install)   dry_message="would copy"; done_message="copied" ;;
    migrate)   dry_message="would migrate legacy link to copy"; done_message="migrated legacy link to copy" ;;
    overwrite) dry_message="would overwrite copy"; done_message="copy overwritten" ;;
    refresh)   dry_message="would refresh copy"; done_message="copy refreshed" ;;
    *)         warn "unknown copy action: $action"; return 1 ;;
  esac
  if [ "$DRY_RUN" = 1 ]; then
    ok "$dry_message: $dest <- $src"
    return 0
  fi
  mkdir -p "$(dirname "$dest")" 2>/dev/null \
    || { warn "cannot create parent of: $dest"; return 1; }
  if [ -L "$dest" ] || [ -f "$dest" ]; then
    rm -f "$dest" || { warn "cannot replace: $dest"; return 1; }
  elif [ -d "$dest" ]; then
    rm -rf "$dest" || { warn "cannot replace: $dest"; return 1; }
  elif [ -e "$dest" ]; then
    rm -f "$dest" || { warn "cannot replace: $dest"; return 1; }
  fi
  if [ -d "$src" ]; then
    cp -R "$src" "$dest" || { warn "copy failed: $dest <- $src"; return 1; }
  else
    cp "$src" "$dest" || { warn "copy failed: $dest <- $src"; return 1; }
  fi
  ok "$done_message: $dest <- $src"
  return 0
}

safe_copy() {
  # usage: safe_copy <source-in-ai-tools> <destination-path>
  # All installs are physical copies. Legacy ai-tools links migrate safely;
  # foreign links and differing artifacts require explicit --overwrite.
  local src="$1" dest="$2"
  refuse_protected_dest "$dest" && return 1
  if [ "$DRY_RUN" = 1 ] && is_dry_gone "$dest"; then
    copy_artifact "$src" "$dest" install
    return $?
  fi
  if [ -L "$dest" ]; then
    if is_ai_tools_link "$dest"; then
      copy_artifact "$src" "$dest" migrate
      return $?
    fi
    if [ "$OVERWRITE" = 1 ]; then
      copy_artifact "$src" "$dest" overwrite
      return $?
    fi
    skip "symlink points elsewhere, not overwriting: $dest -> $(readlink "$dest")"
    return 1
  fi
  if [ -e "$dest" ]; then
    if same_content "$dest" "$src"; then
      ok "copy up to date: $dest"
      return 0
    fi
    if [ "$OVERWRITE" = 1 ]; then
      copy_artifact "$src" "$dest" overwrite
      return $?
    fi
    skip "exists, not overwriting: $dest"
    return 1
  fi
  copy_artifact "$src" "$dest" install
}

safe_unlink() {
  # usage: safe_unlink <destination-path>
  # Removes only symlinks resolving into ai-tools.
  local dest="$1" t
  refuse_protected_dest "$dest" && return 1
  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    ok "absent: $dest"
    return 0
  fi
  if [ ! -L "$dest" ]; then
    skip "not a symlink: $dest"
    return 1
  fi
  t=$(readlink "$dest")
  is_ai_tools_link "$dest" \
    || { skip "symlink not to ai-tools: $dest -> $t"; return 1; }
  if [ "$DRY_RUN" = 1 ]; then
    mark_dry_gone "$dest"
    ok "would remove link: $dest (-> $t)"
    return 0
  fi
  if rm "$dest"; then
    ok "removed link: $dest (was -> $t)"
  else
    warn "cannot remove link: $dest"
    return 1
  fi
}

safe_uninstall_copy() {
  # usage: safe_uninstall_copy <destination-path> <source-in-ai-tools>
  # Removes a copy while its contents still match the ai-tools source.
  # --force also removes that known destination when contents differ.
  local dest="$1" src="$2"
  refuse_protected_dest "$dest" && return 1
  { [ -e "$dest" ] && [ ! -L "$dest" ]; } || return 1
  if same_content "$dest" "$src"; then
    if [ "$DRY_RUN" = 1 ]; then
      mark_dry_gone "$dest"
      ok "would remove copy: $dest"
      return 0
    fi
    if rm -r "$dest"; then
      ok "removed copy: $dest"
    else
      warn "cannot remove copy: $dest"
      return 1
    fi
  elif [ "$FORCE" = 1 ]; then
    if [ "$DRY_RUN" = 1 ]; then
      mark_dry_gone "$dest"
      ok "would force-remove copy: $dest"
      return 0
    fi
    if rm -r "$dest"; then
      ok "force-removed copy: $dest"
    else
      warn "cannot force-remove copy: $dest"
      return 1
    fi
  else
    skip "copy was modified locally, user work preserved: $dest"
    return 1
  fi
}

# --- Source tree -------------------------------------------------------------

ensure_clone() {
  # Clones to $AI_TOOLS when missing; validates the tree either way.
  assert_supported_clone_path
  if [ ! -d "$AI_TOOLS" ]; then
    [ "$DRY_RUN" = 1 ] && fatal "$AI_TOOLS missing — clone it first: git clone $REPO_URL \"$AI_TOOLS\""
    git clone "$REPO_URL" "$AI_TOOLS" || fatal "clone failed: $REPO_URL -> $AI_TOOLS"
    # shellcheck disable=SC2034 # read by install.sh after a bootstrap clone
    FRESH_CLONE=1
  fi
  { [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/skills" ]; } \
    || fatal "$AI_TOOLS is not an ai-tools clone (move any existing clone here — the only supported location)"
}

require_clone() {
  assert_supported_clone_path
  { [ -d "$AI_TOOLS/.git" ] && [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/skills" ]; } \
    || fatal "$AI_TOOLS is missing or not a clone — run scripts/shell/install-bash.sh (or install-zsh.sh) to clone"
}

prepare_reset() {
  # usage: prepare_reset <discard_local 0|1>
  # Fetches origin/master and refuses a discarding reset unless --discard-local.
  # Sets PREV. Does not check out or reset. Call before removing harness artifacts
  # so a refused reset cannot leave the install stripped.
  local discard="${1:-0}" dirty ahead master_ahead current
  git -C "$AI_TOOLS" fetch origin || fatal "fetch failed — fix the remote or auth and retry"
  git -C "$AI_TOOLS" show-ref --verify --quiet refs/remotes/origin/master \
    || fatal "origin/master not found after fetch — fix the remote and retry"
  PREV=$(git -C "$AI_TOOLS" rev-parse HEAD)
  dirty=$(git -C "$AI_TOOLS" status --porcelain)
  ahead=$(git -C "$AI_TOOLS" log --oneline origin/master..HEAD 2>/dev/null)
  master_ahead=""
  if git -C "$AI_TOOLS" show-ref --verify --quiet refs/heads/master; then
    current=$(git -C "$AI_TOOLS" rev-parse --abbrev-ref HEAD)
    if [ "$current" != "master" ]; then
      master_ahead=$(git -C "$AI_TOOLS" log --oneline origin/master..refs/heads/master 2>/dev/null)
    fi
  fi
  if [ -n "$dirty$ahead$master_ahead" ]; then
    [ -n "$dirty" ] && { echo "local changes in $AI_TOOLS:"; git -C "$AI_TOOLS" status --short; }
    [ -n "$ahead" ] && { echo "local commits ahead of origin/master:"; echo "$ahead"; }
    [ -n "$master_ahead" ] && { echo "local master commits ahead of origin/master:"; echo "$master_ahead"; }
    [ "$discard" = 1 ] \
      || fatal "the reset would discard the local work above — stash/branch it, or re-run with --discard-local"
  fi
}

begin_update_dry_plan() {
  # Archive origin/master into a disposable tree so dry-run install planning
  # reports incoming artifacts. Removal planning still uses the current clone.
  local tmp archive
  [ "$DRY_RUN" = 1 ] || return 0
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-update-plan.XXXXXX") \
    || fatal "cannot create dry-run planning tree"
  archive="$tmp/origin-master.tar"
  if git -C "$AI_TOOLS" archive --format=tar -o "$archive" origin/master \
    && tar -xf "$archive" -C "$tmp"; then
    SOURCE_TREE="$tmp"
    UPDATE_DRY_PLAN=1
    rm -f "$archive"
    info "dry-run: planning installation from origin/master ($(git -C "$AI_TOOLS" rev-parse --short origin/master))"
  else
    rm -rf "$tmp"
    fatal "cannot archive origin/master for dry-run planning"
  fi
}

end_update_dry_plan() {
  [ "$UPDATE_DRY_PLAN" = 1 ] || return 0
  [ -n "$SOURCE_TREE" ] && rm -rf "$SOURCE_TREE"
  SOURCE_TREE=""
  UPDATE_DRY_PLAN=0
}

update_source() {
  # usage: update_source <discard_local 0|1>
  # Resets $AI_TOOLS to origin/master. Calls prepare_reset when PREV is empty.
  local discard="${1:-0}"
  [ -n "$PREV" ] || prepare_reset "$discard"
  if [ "$DRY_RUN" = 1 ]; then
    DRY_RUN_FETCHED=1
    ok "would reset $AI_TOOLS to origin/master ($(git -C "$AI_TOOLS" rev-parse --short origin/master))"
    begin_update_dry_plan
    return 0
  fi
  git -C "$AI_TOOLS" checkout -f master >/dev/null 2>&1 || fatal "cannot check out master in $AI_TOOLS"
  git -C "$AI_TOOLS" reset --hard origin/master >/dev/null || fatal "reset to origin/master failed"
  ok "source at $(git -C "$AI_TOOLS" rev-parse --short HEAD) (was $(git -C "$AI_TOOLS" rev-parse --short "$PREV"))"
}

# --- Install steps -----------------------------------------------------------

install_instructions() {
  local h dest src
  src="$(source_root)/USER-AGENTS.md"
  for h in $SCOPE; do
    dest=$(instructions_dest "$h")
    [ -n "$dest" ] || { info "no global instructions destination: $h"; continue; }
    if [ "$h" = codex ] && [ -f "$HOME/.codex/AGENTS.override.md" ]; then
      # shellcheck disable=SC2088 # literal "~" in user-facing prose, not a path to expand
      info "~/.codex/AGENTS.override.md exists and takes precedence while present (never touched)"
    fi
    safe_copy "$src" "$dest" || true
  done
  return 0
}

install_skills() {
  local h root p src
  src="$(source_root)/skills"
  for h in $SCOPE; do
    root=$(skills_root "$h")
    for p in "$src"/*-ai-tools; do
      [ -d "$p" ] || continue
      safe_copy "$p" "$root/$(basename "$p")" || true
    done
  done
  [ "${OVERWRITE:-0}" = 1 ] && prune_orphan_skills
}

# --- Removal steps -----------------------------------------------------------

report_links() {
  # Read-only: what removal would touch. info lines only (no counters in subshells).
  local root p t h dest
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    [ -d "$root" ] || continue
    find "$root" -maxdepth 1 -type l 2>/dev/null | while IFS= read -r p; do
      t=$(readlink "$p")
      is_ai_tools_link "$p" && info "linked: $p -> $t"
    done
    find "$root" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) -name '*-ai-tools*' 2>/dev/null \
      | while IFS= read -r p; do info "possible copy: $p"; done
  done < <(each_scoped_root)
  for h in $SCOPE; do
    dest=$(instructions_dest "$h")
    [ -n "$dest" ] && [ -L "$dest" ] && info "instructions: $dest -> $(readlink "$dest")"
  done
  return 0
}

prune_orphan_skills() {
  local h root p base
  for h in $SCOPE; do
    root=$(skills_root "$h")
    [ -d "$root" ] || continue
    for p in "$root"/*-ai-tools; do
      [ -e "$p" ] || continue
      [ -L "$p" ] && continue
      base=$(basename "$p")
      [ -d "$(source_root)/skills/$base" ] && continue
      refuse_protected_dest "$p" && continue
      if [ "${OVERWRITE:-0}" = 1 ]; then
        if [ "$DRY_RUN" = 1 ]; then
          mark_dry_gone "$p"
          ok "would remove orphan skill: $p"
        elif rm -rf "$p"; then
          ok "removed orphan skill: $p"
        else
          warn "cannot remove orphan skill: $p"
        fi
      elif [ "${FORCE:-0}" = 1 ]; then
        if [ "$DRY_RUN" = 1 ]; then
          mark_dry_gone "$p"
          ok "would force-remove orphan skill: $p"
        elif rm -rf "$p"; then
          ok "force-removed orphan skill: $p"
        else
          warn "cannot force-remove orphan skill: $p"
        fi
      else
        skip "orphan ai-tools skill (use --overwrite or --force to remove): $p"
      fi
    done
  done
}

remove_skills() {
  local h root p base
  for h in $SCOPE; do
    root=$(skills_root "$h")
    [ -d "$root" ] || continue
    for p in "$AI_TOOLS/skills"/*-ai-tools; do
      [ -d "$p" ] || continue
      base=$(basename "$p")
      if [ -L "$root/$base" ]; then
        safe_unlink "$root/$base" || true
      elif [ -e "$root/$base" ]; then
        safe_uninstall_copy "$root/$base" "$p" || true
      else
        ok "absent: $root/$base"
      fi
    done
  done
  prune_orphan_skills
}

sweep_stale_links() {
  # Alpha carries no backward compatibility: remove anything in the scoped roots
  # still resolving into ai-tools, whatever its name or era.
  local root p
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    [ -d "$root" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      is_ai_tools_link "$p" && safe_unlink "$p" || true
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  done < <(each_scoped_root)
  # Retired Gemini CLI skills root (not a harness). Do not touch Antigravity's
  # $HOME/.gemini/config/skills or GEMINI.md.
  root="$HOME/.gemini/skills"
  if [ -d "$root" ]; then
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      is_ai_tools_link "$p" && safe_unlink "$p" || true
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  fi
  return 0
}

remove_instructions() {
  # Remove legacy ai-tools links or exact physical copies. Never $HOME/AGENTS.md.
  local h dest
  for h in $SCOPE; do
    dest=$(instructions_dest "$h")
    [ -n "$dest" ] || continue
    if [ -L "$dest" ]; then
      safe_unlink "$dest" || true
    elif [ -e "$dest" ]; then
      safe_uninstall_copy "$dest" "$AI_TOOLS/USER-AGENTS.md" || true
    else
      ok "absent: $dest"
    fi
  done
}

purge_clone() {
  # usage: purge_clone <yes 0|1> — deletes $AI_TOOLS itself. Never $HOME/AGENTS.md.
  local yes="${1:-0}" answer
  assert_supported_clone_path
  [ -d "$AI_TOOLS" ] || { ok "absent: $AI_TOOLS"; return 0; }
  { [ -d "$AI_TOOLS/.git" ] && [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/skills" ]; } \
    || fatal "$AI_TOOLS is not an ai-tools clone — refusing purge"
  if [ "$DRY_RUN" = 1 ]; then ok "would delete: $AI_TOOLS"; return 0; fi
  if [ "$yes" != 1 ]; then
    printf 'Delete %s entirely? Type yes to confirm: ' "$AI_TOOLS"
    read -r answer || answer=""
    [ "$answer" = yes ] || { skip "purge not confirmed: $AI_TOOLS kept"; return 1; }
  fi
  if rm -rf "$AI_TOOLS"; then
    ok "deleted: $AI_TOOLS"
  else
    warn "cannot delete: $AI_TOOLS"
    return 1
  fi
}

# --- Update steps ------------------------------------------------------------

same_as_revision() {
  # usage: same_as_revision <physical-destination> <repo-relative-path> <revision>
  # Supports both files and directories without relying on GNU-only options.
  local dest="$1" rel="$2" rev="$3" tmp archive rc=1
  [ -n "$rev" ] || return 1
  if [ -f "$dest" ]; then
    git -C "$AI_TOOLS" cat-file -e "$rev:$rel" 2>/dev/null || return 1
    git -C "$AI_TOOLS" show "$rev:$rel" 2>/dev/null | cmp -s "$dest" -
    return $?
  fi
  [ -d "$dest" ] || return 1
  tmp=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-prev.XXXXXX") || return 1
  archive="$tmp/previous.tar"
  if git -C "$AI_TOOLS" archive --format=tar -o "$archive" "$rev" -- "$rel" 2>/dev/null \
    && tar -xf "$archive" -C "$tmp" 2>/dev/null \
    && [ -d "$tmp/$rel" ] \
    && same_content "$dest" "$tmp/$rel"; then
    rc=0
  fi
  rm -rf "$tmp"
  return "$rc"
}

refresh_one_copy() {
  # usage: refresh_one_copy <new-source> <destination> <repo-relative-path>
  local src="$1" dest="$2" rel="$3"
  { [ -e "$dest" ] && [ ! -L "$dest" ]; } || return 0
  if same_content "$dest" "$src"; then
    ok "copy up to date: $dest"
  elif [ -n "$PREV" ] && same_as_revision "$dest" "$rel" "$PREV"; then
    copy_artifact "$src" "$dest" refresh
  elif [ "$OVERWRITE" = 1 ]; then
    copy_artifact "$src" "$dest" overwrite
  else
    skip "copy modified locally (or predates $PREV): $dest — see README Troubleshooting"
  fi
}

refresh_copies() {
  # usage: refresh_copies [include-instructions 0|1]
  # Refresh every physical copy matching the previous revision ($PREV).
  # A copy matching neither revision is user work unless --overwrite was given.
  local include_instructions="${1:-1}" h root dest p name src
  src=$(source_root)
  if [ "$include_instructions" = 1 ]; then
    for h in $SCOPE; do
      dest=$(instructions_dest "$h")
      [ -n "$dest" ] || continue
      refresh_one_copy "$src/USER-AGENTS.md" "$dest" "USER-AGENTS.md"
    done
  fi
  for h in $SCOPE; do
    root=$(skills_root "$h")
    for p in "$src/skills"/*-ai-tools; do
      [ -d "$p" ] || continue
      name=$(basename "$p")
      refresh_one_copy "$p" "$root/$name" "skills/$name"
    done
  done
}

# --- Verification ------------------------------------------------------------

verify_install() {
  # VERIFY_INSTRUCTIONS=0 skips the instructions checks (install --no-instructions).
  local check_instr="${VERIFY_INSTRUCTIONS:-1}" h dest size root p name src
  if [ "$DRY_RUN" = 1 ]; then info "dry-run: verification skipped"; return 0; fi
  src=$(source_root)

  size=$(wc -c < "$src/USER-AGENTS.md")
  if [ "$size" -le 8000 ]; then ok "instructions size: $size chars"
  else warn "USER-AGENTS.md exceeds 8000 chars (repository limit): $size"; fi

  for p in "$src/skills"/*-ai-tools; do
    [ -d "$p" ] || continue
    name=$(basename "$p")
    if [ -f "$p/SKILL.md" ]; then ok "skill source: $p/SKILL.md"
    else warn "missing skill source: $p/SKILL.md"; fi
  done

  if [ "$check_instr" = 1 ]; then
    for h in $SCOPE; do
      dest=$(instructions_dest "$h")
      [ -n "$dest" ] || continue
      if [ -L "$dest" ]; then
        warn "instructions must be a physical copy, not a symlink: $dest -> $(readlink "$dest")"
      elif [ -f "$dest" ] && cmp -s "$dest" "$src/USER-AGENTS.md"; then
        ok "instructions copy: $dest"
      elif [ -e "$dest" ]; then
        warn "instructions differ from source: $dest"
      else
        warn "instructions missing: $dest"
      fi
    done
  fi

  for h in $SCOPE; do
    root=$(skills_root "$h")
    for p in "$src/skills"/*-ai-tools; do
      [ -d "$p" ] || continue
      name=$(basename "$p")
      if [ -L "$root/$name" ]; then
        warn "skill must be a physical copy, not a symlink: $root/$name -> $(readlink "$root/$name")"
      elif same_content "$root/$name" "$p"; then
        ok "skill copy: $root/$name"
      elif [ -e "$root/$name" ]; then
        warn "skill differs from source: $root/$name"
      else
        warn "skill absent: $root/$name"
      fi
    done
    if [ -d "$root" ]; then
      for p in "$root"/*-ai-tools; do
        [ -e "$p" ] || [ -L "$p" ] || continue
        name=$(basename "$p")
        [ -d "$src/skills/$name" ] || warn "orphan skill present: $p"
      done
    fi
  done
  return 0
}

verify_removal() {
  local root p t remaining=0 src dest h
  if [ "$DRY_RUN" = 1 ]; then info "dry-run: removal verification skipped"; return 0; fi
  src=$(source_root)
  while IFS= read -r root; do
    [ -n "$root" ] || continue
    [ -d "$root" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      t=$(readlink "$p")
      if is_ai_tools_link "$p"; then
        warn "still linked: $p -> $t"
        remaining=1
      fi
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  done < <(each_scoped_root)
  if [ -d "$src/skills" ]; then
    for h in $SCOPE; do
      root=$(skills_root "$h")
      for p in "$src/skills"/*-ai-tools; do
        [ -d "$p" ] || continue
        dest="$root/$(basename "$p")"
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
          if same_content "$dest" "$p"; then
            warn "still installed: $dest"
            remaining=1
          elif [ "$FORCE" = 1 ]; then
            warn "still installed after --force: $dest"
            remaining=1
          fi
        fi
      done
    done
  fi
  [ "$remaining" = 0 ] && ok "no ai-tools links remain in the scoped roots"
  return 0
}
