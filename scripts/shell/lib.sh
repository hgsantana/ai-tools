# shellcheck shell=bash
# ai-tools shared helpers — sourced by every script in scripts/shell/.
# Compatible with bash 3.2+ (macOS default) and BSD/GNU userlands.
# Windows: WSL or Git Bash. No PowerShell mirror.

set -u

AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"
REPO_URL="https://github.com/hgsantana/ai-tools.git"
ALL_HARNESSES="claude-code grok codex copilot cursor antigravity"
EXT_ROOTS="$HOME/.vscode/extensions $HOME/.vscode-server/extensions $HOME/.vscode-insiders/extensions $HOME/.vscode-server-insiders/extensions $HOME/.vscodium/extensions"

DRY_RUN=0
OVERWRITE=0
SCOPE=""
FRESH_CLONE=0
PREV=""
OK=0 SKIP=0 WARN=0

ok()   { OK=$((OK+1));     printf 'ok: %s\n'   "$*"; }
skip() { SKIP=$((SKIP+1)); printf 'SKIP: %s\n' "$*"; }
warn() { WARN=$((WARN+1)); printf 'WARN: %s\n' "$*"; }
info() { printf 'info: %s\n' "$*"; }
fatal(){ printf 'ERROR: %s\n' "$*" >&2; exit 1; }

finish() {
  suffix=""
  [ "$DRY_RUN" = 1 ] && suffix=" (dry-run: nothing was changed)"
  printf 'done: %d ok, %d skipped, %d warnings%s\n' "$OK" "$SKIP" "$WARN" "$suffix"
  [ "$WARN" -gt 0 ] && exit 2
  exit 0
}

# --- Harness table (mirrors "Supported harnesses" in README.md) -------------

agents_root() {
  case "$1" in
    claude-code) echo "$HOME/.claude/agents" ;;
    grok)        echo "$HOME/.grok/agents" ;;
    codex)       echo "$HOME/.codex/agents" ;;
    copilot)     echo "$HOME/.copilot/agents" ;;
    cursor)      echo "$HOME/.cursor/agents" ;;
    antigravity) echo "$HOME/.gemini/config/agents" ;;
  esac
}

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
    cursor)      echo "" ;;  # Cursor has no global instructions destination
  esac
}

# --- Discovery ---------------------------------------------------------------

has_extension() {
  # usage: has_extension <extension-id-prefix>
  local root d
  for root in $EXT_ROOTS; do
    [ -d "$root" ] || continue
    for d in "$root/$1"*; do [ -d "$d" ] && return 0; done
  done
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
  local jb_roots=""
  for jb in "$HOME"/.local/share/JetBrains/*/plugins; do
    [ -d "$jb" ] && jb_roots="$jb_roots $jb"
  done
  # Glob instead of `ls | grep` so names with non-alphanumeric characters
  # (spaces, globs, newlines) are handled correctly; nocasematch replaces
  # the two grep -i passes and is restored to its prior state on exit.
  shopt -q nocasematch && nocasematch_was_set=1
  shopt -s nocasematch
  for root in $EXT_ROOTS $jb_roots; do
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
  done
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

in_scope() { case " $SCOPE " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

scoped_roots() {
  local h
  for h in $SCOPE; do
    agents_root "$h"
    skills_root "$h"
  done | sort -u
}

# --- Filesystem safety primitives (README "Safety rules") --------------------
# Never overwrite or delete anything that is not an ai-tools link or an
# unmodified ai-tools copy unless the caller explicitly selected --overwrite.
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
  if [ "$DRY_RUN" = 1 ]; then ok "would remove link: $dest (-> $t)"; return 0; fi
  rm "$dest" && ok "removed link: $dest (was -> $t)"
}

safe_uninstall_copy() {
  # usage: safe_uninstall_copy <destination-path> <source-in-ai-tools>
  # Removes a copy only while its contents still match the ai-tools source.
  local dest="$1" src="$2"
  { [ -e "$dest" ] && [ ! -L "$dest" ]; } || return 1
  if same_content "$dest" "$src"; then
    if [ "$DRY_RUN" = 1 ]; then ok "would remove copy: $dest"; return 0; fi
    rm -r "$dest" && ok "removed copy: $dest"
  else
    skip "copy was modified locally, user work preserved: $dest"
    return 1
  fi
}

# --- Source tree -------------------------------------------------------------

ensure_clone() {
  # Clones to $AI_TOOLS when missing; validates the tree either way.
  if [ ! -d "$AI_TOOLS" ]; then
    [ "$DRY_RUN" = 1 ] && fatal "$AI_TOOLS missing — clone it first: git clone $REPO_URL \"$AI_TOOLS\""
    git clone "$REPO_URL" "$AI_TOOLS" || fatal "clone failed: $REPO_URL -> $AI_TOOLS"
    # shellcheck disable=SC2034 # read by scripts/shell/reinstall.sh, a separate sourcing script
    FRESH_CLONE=1
  fi
  { [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/agents" ]; } \
    || fatal "$AI_TOOLS is not an ai-tools clone (move any existing clone here — the only supported location)"
}

require_clone() {
  { [ -d "$AI_TOOLS/.git" ] && [ -f "$AI_TOOLS/USER-AGENTS.md" ]; } \
    || fatal "$AI_TOOLS is missing or not a clone — run scripts/shell/install.sh first"
}

update_source() {
  # usage: update_source <discard_local 0|1>
  # Resets $AI_TOOLS to origin/master. Sets PREV to the pre-reset revision.
  local discard="${1:-0}" dirty ahead
  git -C "$AI_TOOLS" fetch origin || fatal "fetch failed — fix the remote or auth and retry"
  git -C "$AI_TOOLS" show-ref --verify --quiet refs/remotes/origin/master \
    || fatal "origin/master not found after fetch — fix the remote and retry"
  PREV=$(git -C "$AI_TOOLS" rev-parse HEAD)
  dirty=$(git -C "$AI_TOOLS" status --porcelain)
  ahead=$(git -C "$AI_TOOLS" log --oneline origin/master..HEAD 2>/dev/null)
  if [ -n "$dirty$ahead" ]; then
    [ -n "$dirty" ] && { echo "local changes in $AI_TOOLS:"; git -C "$AI_TOOLS" status --short; }
    [ -n "$ahead" ] && { echo "local commits ahead of origin/master:"; echo "$ahead"; }
    [ "$discard" = 1 ] \
      || fatal "the reset would discard the local work above — stash/branch it, or re-run with --discard-local"
  fi
  if [ "$DRY_RUN" = 1 ]; then
    ok "would reset $AI_TOOLS to origin/master ($(git -C "$AI_TOOLS" rev-parse --short origin/master))"
    return 0
  fi
  git -C "$AI_TOOLS" checkout -f master >/dev/null 2>&1 || fatal "cannot check out master in $AI_TOOLS"
  git -C "$AI_TOOLS" reset --hard origin/master >/dev/null || fatal "reset to origin/master failed"
  ok "source at $(git -C "$AI_TOOLS" rev-parse --short HEAD) (was $(git -C "$AI_TOOLS" rev-parse --short "$PREV"))"
}

# --- Install steps -----------------------------------------------------------

install_instructions() {
  local h dest
  for h in $SCOPE; do
    dest=$(instructions_dest "$h")
    [ -n "$dest" ] || { info "no global instructions destination: $h"; continue; }
    if [ "$h" = codex ] && [ -f "$HOME/.codex/AGENTS.override.md" ]; then
      # shellcheck disable=SC2088 # literal "~" in user-facing prose, not a path to expand
      info "~/.codex/AGENTS.override.md exists and takes precedence while present (never touched)"
    fi
    safe_copy "$AI_TOOLS/USER-AGENTS.md" "$dest" || true
  done
  return 0
}

install_agents() {
  # Per file, never per directory — the roots hold agents from other sources.
  local h src root f
  for h in $SCOPE; do
    src="$AI_TOOLS/agents/$h"
    root=$(agents_root "$h")
    [ -d "$src" ] || { skip "no wrapper folder: $src"; continue; }
    for f in "$src"/*-ai-tools*; do
      [ -f "$f" ] || continue
      safe_copy "$f" "$root/$(basename "$f")" || true
    done
  done
}

install_skills() {
  local h root p
  for h in $SCOPE; do
    root=$(skills_root "$h")
    for p in "$AI_TOOLS/skills"/*-ai-tools; do
      [ -d "$p" ] || continue
      safe_copy "$p" "$root/$(basename "$p")" || true
    done
  done
}

# --- Grok model pinning ------------------------------------------------------
# Grok ignores model: in agent frontmatter; models live in ~/.grok/config.toml.
# Only the marker-delimited block below is ever written or removed.

MODEL_TABLE="$AI_TOOLS/USER-AGENTS.md"
GROK_TOML="$HOME/.grok/config.toml"
GROK_BEGIN="# >>> ai-tools managed subagent models — do not edit inside this block"
GROK_END="# <<< ai-tools managed subagent models"

category_for() {
  # usage: category_for <agent-name>
  # Role the base claims via "You are the **<planner|implementer|mechanical>**".
  # Used at install/lint to pin wrappers from USER-AGENTS.md — never at dispatch.
  # Falls back to planner when the base cites none.
  local f="$AI_TOOLS/agents/$1.md" cat
  [ -f "$f" ] || return 1
  cat=$(awk '
    match($0, /You are the \*\*(planner|implementer|mechanical)\*\*/) {
      s = substr($0, RSTART, RLENGTH)
      sub(/You are the \*\*/, "", s)
      sub(/\*\*.*/, "", s)
      print s
      exit
    }
  ' "$f")
  [ -n "$cat" ] || cat=planner
  printf '%s\n' "$cat"
}

model_for() {
  # usage: model_for <harness key> <planner|implementer|mechanical>
  # Reads USER-AGENTS.md, the single source of model names (README rules 11-12).
  local key="$1" col
  case "$2" in
    planner)     col=4 ;;
    implementer) col=5 ;;
    mechanical)  col=6 ;;
    *)           return 1 ;;
  esac
  [ -f "$MODEL_TABLE" ] || return 1
  awk -F'|' -v key="$key" -v col="$col" '
    /^[[:space:]]*\|/ {
      k = $2; gsub(/[`[:space:]]/, "", k)
      if (k == key) {
        v = $col
        if (match(v, /`[^`]+`/)) v = substr(v, RSTART + 1, RLENGTH - 2)
        else { gsub(/`/, "", v); gsub(/^[[:space:]]+|[[:space:]]+$/, "", v) }
        if (v != "") { print v; found = 1 }
        exit
      }
    }
    END { exit !found }
  ' "$MODEL_TABLE"
}

grok_models_toml() {
  # Names from the tree; models from USER-AGENTS.md, row `grok`, via the
  # category each base claims (category_for).
  local f name cat model
  echo "[subagents.models]"
  for f in "$AI_TOOLS/agents"/*-ai-tools.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f" .md)
    cat=$(category_for "$name") || return 1
    model=$(model_for grok "$cat") || return 1
    printf '%s = "%s"\n' "$name" "$model"
  done
}

install_grok_models() {
  in_scope grok || return 0
  local desired current tmp models
  models=$(grok_models_toml) || {
    skip "grok model pinning: no usable \`grok\` row in $MODEL_TABLE — block left untouched"
    return 0
  }
  desired=$(printf '%s\n%s\n%s\n' "$GROK_BEGIN" "$models" "$GROK_END")
  if [ -f "$GROK_TOML" ] && grep -qF "$GROK_BEGIN" "$GROK_TOML"; then
    current=$(sed -n "/^$GROK_BEGIN\$/,/^$GROK_END\$/p" "$GROK_TOML")
    if [ "$current" = "$desired" ]; then
      ok "grok models block up to date: $GROK_TOML"
      return 0
    fi
    if [ "$DRY_RUN" = 1 ]; then ok "would refresh grok models block: $GROK_TOML"; return 0; fi
    tmp=$(mktemp) || { warn "mktemp failed; grok models block not refreshed"; return 1; }
    sed "/^$GROK_BEGIN\$/,/^$GROK_END\$/d" "$GROK_TOML" > "$tmp" \
      && printf '%s\n' "$desired" >> "$tmp" \
      && cat "$tmp" > "$GROK_TOML" \
      && ok "grok models block refreshed: $GROK_TOML"
    rm -f "$tmp"
    return 0
  fi
  if [ -f "$GROK_TOML" ] && grep -q '^\[subagents\.models\]' "$GROK_TOML"; then
    skip "unmanaged [subagents.models] already in $GROK_TOML — verify the ai-tools entries manually (README, Installation)"
    return 0
  fi
  if [ "$DRY_RUN" = 1 ]; then ok "would append grok models block: $GROK_TOML"; return 0; fi
  mkdir -p "$(dirname "$GROK_TOML")" 2>/dev/null
  # shellcheck disable=SC2094 # [ -s ] stats the file, it does not read its content — no overlap with the append below
  if { [ -s "$GROK_TOML" ] && echo; printf '%s\n' "$desired"; } >> "$GROK_TOML"; then
    ok "grok models block appended: $GROK_TOML"
  else
    warn "could not write $GROK_TOML — pin models manually (README, Installation)"
  fi
}

remove_grok_models() {
  in_scope grok || return 0
  [ -f "$GROK_TOML" ] || { ok "absent: $GROK_TOML"; return 0; }
  if grep -qF "$GROK_BEGIN" "$GROK_TOML"; then
    if [ "$DRY_RUN" = 1 ]; then ok "would remove grok models block: $GROK_TOML"; return 0; fi
    local tmp
    tmp=$(mktemp) || { warn "mktemp failed; grok models block not removed"; return 1; }
    sed "/^$GROK_BEGIN\$/,/^$GROK_END\$/d" "$GROK_TOML" > "$tmp" \
      && cat "$tmp" > "$GROK_TOML" \
      && ok "grok models block removed: $GROK_TOML"
    rm -f "$tmp"
  elif grep -q '^\[subagents\.models\]' "$GROK_TOML"; then
    skip "unmanaged [subagents.models] in $GROK_TOML — not written by ai-tools, left untouched"
  else
    ok "no grok models block in: $GROK_TOML"
  fi
}

# --- Removal steps -----------------------------------------------------------

report_links() {
  # Read-only: what removal would touch. info lines only (no counters in subshells).
  local root p t h dest
  for root in $(scoped_roots); do
    [ -d "$root" ] || continue
    find "$root" -maxdepth 1 -type l 2>/dev/null | while IFS= read -r p; do
      t=$(readlink "$p")
      is_ai_tools_link "$p" && info "linked: $p -> $t"
    done
    find "$root" -mindepth 1 -maxdepth 1 \( -type f -o -type d \) -name '*-ai-tools*' 2>/dev/null \
      | while IFS= read -r p; do info "possible copy: $p"; done
  done
  for h in $SCOPE; do
    dest=$(instructions_dest "$h")
    [ -n "$dest" ] && [ -L "$dest" ] && info "instructions: $dest -> $(readlink "$dest")"
  done
  return 0
}

uninstall_agents() {
  local h src root f base
  for h in $SCOPE; do
    src="$AI_TOOLS/agents/$h"
    root=$(agents_root "$h")
    [ -d "$src" ] || continue
    for f in "$src"/*-ai-tools*; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      if [ -L "$root/$base" ]; then
        safe_unlink "$root/$base" || true
      elif [ -e "$root/$base" ]; then
        safe_uninstall_copy "$root/$base" "$f" || true
      else
        ok "absent: $root/$base"
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
}

sweep_stale_links() {
  # Alpha carries no backward compatibility: remove anything in the scoped roots
  # still resolving into ai-tools, whatever its name or era.
  local root p
  for root in $(scoped_roots); do
    [ -d "$root" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      is_ai_tools_link "$p" && safe_unlink "$p" || true
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  done
  # Whole-directory links from an older alpha install (no-op on real directories)
  for root in "$HOME/.claude/agents" "$HOME/.grok/agents"; do
    [ -L "$root" ] && safe_unlink "$root"
  done
  # Retired Gemini CLI roots (not a harness). Do not touch Antigravity's
  # $HOME/.gemini/config/{agents,skills} or GEMINI.md.
  for root in "$HOME/.gemini/agents" "$HOME/.gemini/skills"; do
    [ -d "$root" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      is_ai_tools_link "$p" && safe_unlink "$p" || true
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  done
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
  [ -d "$AI_TOOLS" ] || { ok "absent: $AI_TOOLS"; return 0; }
  if [ "$DRY_RUN" = 1 ]; then ok "would delete: $AI_TOOLS"; return 0; fi
  if [ "$yes" != 1 ]; then
    printf 'Delete %s entirely? Type yes to confirm: ' "$AI_TOOLS"
    read -r answer || answer=""
    [ "$answer" = yes ] || { skip "purge not confirmed: $AI_TOOLS kept"; return 1; }
  fi
  rm -rf "$AI_TOOLS" && ok "deleted: $AI_TOOLS"
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
  local include_instructions="${1:-1}" h src root f base dest p name
  if [ "$include_instructions" = 1 ]; then
    for h in $SCOPE; do
      dest=$(instructions_dest "$h")
      [ -n "$dest" ] || continue
      refresh_one_copy "$AI_TOOLS/USER-AGENTS.md" "$dest" "USER-AGENTS.md"
    done
  fi
  for h in $SCOPE; do
    src="$AI_TOOLS/agents/$h"
    root=$(agents_root "$h")
    [ -d "$src" ] || continue
    for f in "$src"/*-ai-tools*; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      dest="$root/$base"
      refresh_one_copy "$f" "$dest" "agents/$h/$base"
    done
    root=$(skills_root "$h")
    for p in "$AI_TOOLS/skills"/*-ai-tools; do
      [ -d "$p" ] || continue
      name=$(basename "$p")
      refresh_one_copy "$p" "$root/$name" "skills/$name"
    done
  done
}

# --- Verification ------------------------------------------------------------

verify_install() {
  # VERIFY_INSTRUCTIONS=0 skips the instructions checks (install --no-instructions).
  local check_instr="${VERIFY_INSTRUCTIONS:-1}" h dest size base root p name f
  if [ "$DRY_RUN" = 1 ]; then info "dry-run: verification skipped"; return 0; fi

  size=$(wc -c < "$AI_TOOLS/USER-AGENTS.md")
  if [ "$size" -le 8000 ]; then ok "instructions size: $size chars"
  else warn "USER-AGENTS.md exceeds 8000 chars (repository limit): $size"; fi

  if [ -f "$MODEL_TABLE" ]; then ok "model table: $MODEL_TABLE"
  else warn "missing model table: $MODEL_TABLE — agents and skills cannot resolve agent-role models"; fi

  if [ -f "$AI_TOOLS/agents/SUBAGENT-CONTRACT.md" ]; then ok "subagent contract: $AI_TOOLS/agents/SUBAGENT-CONTRACT.md"
  else warn "missing subagent contract: $AI_TOOLS/agents/SUBAGENT-CONTRACT.md — wrappers point at it before their base"; fi

  for base in "$AI_TOOLS/agents"/*-ai-tools.md; do
    if [ -f "$base" ]; then ok "agent base: $base"; else warn "missing agent base: $base"; fi
  done

  for p in "$AI_TOOLS/skills"/*-ai-tools; do
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
      elif [ -f "$dest" ] && cmp -s "$dest" "$AI_TOOLS/USER-AGENTS.md"; then
        ok "instructions copy: $dest"
      elif [ -e "$dest" ]; then
        warn "instructions differ from source: $dest"
      else
        warn "instructions missing: $dest"
      fi
    done
  fi

  for h in $SCOPE; do
    root=$(agents_root "$h")
    for f in "$AI_TOOLS/agents/$h"/*-ai-tools*; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      if [ -L "$root/$base" ]; then warn "agent must be a physical copy, not a symlink: $root/$base -> $(readlink "$root/$base")"
      elif cmp -s "$root/$base" "$f" 2>/dev/null; then ok "agent copy: $root/$base"
      elif [ -e "$root/$base" ]; then warn "agent differs from source: $root/$base"
      else warn "agent absent: $root/$base"
      fi
    done
    root=$(skills_root "$h")
    for p in "$AI_TOOLS/skills"/*-ai-tools; do
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
  done
  return 0
}

verify_removal() {
  local root p t remaining=0
  if [ "$DRY_RUN" = 1 ]; then info "dry-run: removal verification skipped"; return 0; fi
  for root in $(scoped_roots); do
    [ -d "$root" ] || continue
    while IFS= read -r p; do
      [ -n "$p" ] || continue
      t=$(readlink "$p")
      if is_ai_tools_link "$p"; then
        warn "still linked: $p -> $t"
        remaining=1
      fi
    done < <(find "$root" -maxdepth 1 -type l 2>/dev/null)
  done
  [ "$remaining" = 0 ] && ok "no ai-tools links remain in the scoped roots"
  return 0
}
