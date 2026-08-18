#!/usr/bin/env bash
# ai-tools rule linter — a development check, not an installation process
# (outside the contract of README rules 23-25). Enforces this repository's
# mechanically verifiable rules against the tree it runs in.
#
# Usage: tools/lint.sh [--help]
#
# Run from anywhere; it resolves its own repository root. Exit: 0 clean,
# 1 aborted on a precondition (bad flag, missing lib.sh), 2 finished with
# warnings (a rule violation was found).
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AI_TOOLS=$(cd "$SCRIPT_DIR/.." && pwd)
export AI_TOOLS
. "$AI_TOOLS/scripts/shell/lib.sh"

usage() {
  cat <<'EOF'
usage: lint.sh [--help]

Development check: enforces this repository's mechanically verifiable rules
against the tree lint.sh runs in. Not an installation process (README rules
23-25); introduces no new dependency beyond git, grep, awk, sed, wc, od, tr.

Checks:
  wrapper coverage  every agent has exactly one wrapper per harness, with
                    that harness's extension; no orphan wrapper (rule 5)
  naming            every agent base file, wrapper, skills/*/ directory, and
                    frontmatter name: ends in -ai-tools (rule 13)
  skill frontmatter every skills/*/SKILL.md exists with frontmatter keys a
                    subset of name, description, argument-hint (rule 9)
  skill name match  skills/<x>/SKILL.md declares name: <x>

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    *) fatal "unknown flag: $1 (see --help)" ;;
  esac
  shift
done

# --- Discovery ---------------------------------------------------------------
# Never hard-code harness keys or agent names — a new harness or agent must
# be picked up automatically.

harnesses() {
  local d
  for d in "$AI_TOOLS"/agents/*/; do
    [ -d "$d" ] || continue
    basename "$d"
  done
}

agent_names() {
  local f b
  for f in "$AI_TOOLS"/agents/*.md; do
    [ -f "$f" ] || continue
    b=$(basename "$f" .md)
    [ "$b" = "SUBAGENT-CONTRACT" ] && continue
    echo "$b"
  done
}

in_list() {
  # usage: in_list <needle> <space-separated haystack>
  case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

wrapper_ext() {
  # usage: wrapper_ext <harness>  -> extension suffix (without leading dot,
  # "agent.md" counts as one suffix for copilot)
  case "$1" in
    codex)   echo toml ;;
    copilot) echo agent.md ;;
    *)       echo md ;;
  esac
}

wrapper_path() {
  # usage: wrapper_path <harness> <agent-name>
  echo "$AI_TOOLS/agents/$1/$2.$(wrapper_ext "$1")"
}

# --- Frontmatter helpers ------------------------------------------------------

yaml_frontmatter_keys() {
  # usage: yaml_frontmatter_keys <file> -- top-level keys in the leading
  # "---" ... "---" block (indented continuation lines are not keys).
  awk '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { exit }
    infm && /^[A-Za-z0-9_-]+:/ { sub(/:.*/, ""); print }
  ' "$1"
}

yaml_frontmatter_value() {
  # usage: yaml_frontmatter_value <file> <key>
  awk -v key="$2" '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { exit }
    infm && $0 ~ "^" key ":" {
      sub("^" key ":[ \t]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$1"
}

toml_field_value() {
  # usage: toml_field_value <file> <key> -- "key = \"value\"" at column 1
  awk -v key="$2" '
    $0 ~ "^" key "[ \t]*=" {
      sub("^" key "[ \t]*=[ \t]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$1"
}

ends_in_ai_tools() {
  case "$1" in *-ai-tools) return 0 ;; *) return 1 ;; esac
}

# --- Check: wrapper coverage (rule 5) -----------------------------------------

check_wrapper_coverage() {
  local h ext agents a f base name found
  agents=$(agent_names | tr '\n' ' ')
  for h in $(harnesses); do
    ext=$(wrapper_ext "$h")
    for a in $agents; do
      f=$(wrapper_path "$h" "$a")
      if [ -f "$f" ]; then
        ok "wrapper present: $f"
      else
        warn "missing wrapper: $f"
      fi
    done
    for f in "$AI_TOOLS/agents/$h"/*; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      case "$ext" in
        agent.md) case "$base" in *.agent.md) name=${base%.agent.md} ;; *) name="" ;; esac ;;
        toml)     case "$base" in *.toml) name=${base%.toml} ;; *) name="" ;; esac ;;
        md)       case "$base" in *.md) name=${base%.md} ;; *) name="" ;; esac ;;
      esac
      found=0
      if [ -n "$name" ] && in_list "$name" "$agents"; then found=1; fi
      [ "$found" = 1 ] || warn "orphan wrapper (matches no agent): $f"
    done
  done
}

# --- Check: naming (rule 13) --------------------------------------------------

check_naming() {
  local f b h ext d name val

  for f in "$AI_TOOLS"/agents/*.md; do
    [ -f "$f" ] || continue
    b=$(basename "$f" .md)
    [ "$b" = "SUBAGENT-CONTRACT" ] && continue
    if ends_in_ai_tools "$b"; then
      ok "agent base name: $b"
    else
      warn "agent base file does not end in -ai-tools: $f"
    fi
    val=$(yaml_frontmatter_value "$f" name)
    if [ -n "$val" ]; then
      if ends_in_ai_tools "$val"; then ok "agent base frontmatter name: $val"
      else warn "agent base frontmatter name does not end in -ai-tools: $f (name: $val)"; fi
    fi
  done

  for h in $(harnesses); do
    ext=$(wrapper_ext "$h")
    for f in "$AI_TOOLS/agents/$h"/*; do
      [ -f "$f" ] || continue
      b=$(basename "$f")
      case "$ext" in
        agent.md) case "$b" in *.agent.md) name=${b%.agent.md} ;; *) name="" ;; esac ;;
        toml)     case "$b" in *.toml) name=${b%.toml} ;; *) name="" ;; esac ;;
        md)       case "$b" in *.md) name=${b%.md} ;; *) name="" ;; esac ;;
      esac
      [ -n "$name" ] || continue
      if ends_in_ai_tools "$name"; then
        ok "wrapper name: $f"
      else
        warn "wrapper file does not end in -ai-tools: $f"
      fi
      if [ "$ext" = toml ]; then
        val=$(toml_field_value "$f" name)
      else
        val=$(yaml_frontmatter_value "$f" name)
      fi
      if [ -n "$val" ]; then
        if ends_in_ai_tools "$val"; then ok "wrapper frontmatter name: $val ($f)"
        else warn "wrapper frontmatter name does not end in -ai-tools: $f (name: $val)"; fi
      fi
    done
  done

  for d in "$AI_TOOLS"/skills/*/; do
    [ -d "$d" ] || continue
    b=$(basename "$d")
    if ends_in_ai_tools "$b"; then
      ok "skill directory name: $b"
    else
      warn "skill directory does not end in -ai-tools: $d"
    fi
  done
}

# --- Check: skill frontmatter (rule 9) ----------------------------------------

check_skill_frontmatter() {
  local d f k allowed="name description argument-hint"
  for d in "$AI_TOOLS"/skills/*/; do
    [ -d "$d" ] || continue
    f="${d}SKILL.md"
    if [ ! -f "$f" ]; then
      warn "missing SKILL.md: $f"
      continue
    fi
    ok "SKILL.md present: $f"
    for k in $(yaml_frontmatter_keys "$f"); do
      if in_list "$k" "$allowed"; then
        ok "skill frontmatter key: $k ($f)"
      else
        warn "skill frontmatter key not allowed by every harness: $f (key: $k)"
      fi
    done
  done
}

# --- Check: skill name matches its directory ----------------------------------

check_skill_name_match() {
  local d f base val
  for d in "$AI_TOOLS"/skills/*/; do
    [ -d "$d" ] || continue
    base=$(basename "$d")
    f="${d}SKILL.md"
    [ -f "$f" ] || continue  # reported by check_skill_frontmatter
    val=$(yaml_frontmatter_value "$f" name)
    if [ "$val" = "$base" ]; then
      ok "skill name matches directory: $base"
    else
      warn "skill name does not match its directory: $f (name: '$val', directory: '$base')"
    fi
  done
}

# --- Run -----------------------------------------------------------------------

check_wrapper_coverage
check_naming
check_skill_frontmatter
check_skill_name_match

finish
