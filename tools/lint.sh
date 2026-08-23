#!/usr/bin/env bash
# ai-tools rule linter — a development check, not an installation process
# (outside the contract of README rules 25-27). Enforces this repository's
# mechanically verifiable rules against the tree it runs in.
#
# Usage: tools/lint.sh [--help] [--base <ref>]
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
usage: lint.sh [--help] [--base <ref>]

Development check: enforces this repository's mechanically verifiable rules
against the tree lint.sh runs in. Not an installation process (README rules
24-26); introduces no new dependency beyond git, grep, awk, sed, wc, tr.

Checks:
  wrapper coverage  every agent has exactly one wrapper per harness, with
                    that harness's extension; no orphan wrapper (rule 5)
  naming            every agent base file, wrapper, skills/*/ directory, and
                    frontmatter name: ends in -ai-tools (rule 14)
  skill frontmatter every skills/*/SKILL.md exists with frontmatter keys a
                    subset of name, description, argument-hint (rule 9)
  skill name match  skills/<x>/SKILL.md declares name: <x>
  skill description every skill description is at most 500 characters,
                    folded block included, and states what the skill does
                    then Impact: plus the Stake (rule 9)
  skill layout      no skill-root markdown, every skill directory has
                    SKILL.md, no SKILL.md contains Continue? or Stake,
                    USER-AGENTS.md has How to route a request and Min. role, and no
                    mentions of deleted files (rule 7)
  wrapper body      every wrapper body is exactly the canonical text
                    reconstructed from the agent name (rule 6)
  model parity      every wrapper's pinned model matches MODELS.md via
                    model_for; Grok wrappers declare no model: (rules 11-12)
  effort pinning    the wrapper pins the MODELS.md cell's effort where its
                    form can hold one, in the vendor's spelling
  description parity same agent's description is identical across wrappers
  MODELS.md coverage every agents/<key>/ has a MODELS.md row and vice versa
  instructions cap  USER-AGENTS.md is at most 8000 characters (rule 3)
  wrapper cap       every agents/<harness>/* file is at most 1000 characters,
                    frontmatter included (rule 6)
  line endings      git ls-files --eol matches the declared eol= attribute:
                    lf for scripts/shell and tools (rule 28)
  executable bits   scripts/shell/*.sh, tools/lint.sh, tools/test.sh,
                    and tools/*.sh are mode 100755 (rule 28)
  no binaries       every tracked file under agents/, skills/, scripts/, and
                    tools/ is text
  version bump      CI-only, needs --base <ref> (skipped without it): when
                    agents/, skills/, scripts/, or USER-AGENTS.md changed
                    since <ref>, the README version line must have changed
                    too (rule 4)

--base <ref>  commit-ish to diff shipped content against for the version
              bump check. Without it, that check is skipped. The lint
              workflow (.github/workflows/lint.yml) supplies it.

Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
EOF
}

BASE_REF=""
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --base)
      shift
      [ $# -gt 0 ] || fatal "--base requires a ref argument (see --help)"
      BASE_REF="$1"
      ;;
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

# --- Check: naming (rule 14) --------------------------------------------------

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

# --- Check: skill layout and description cap (rules 7, 9) --------------------

check_skill_layout() {
  local f d name
  local gated="vibe-ai-tools plan-ai-tools dev-ai-tools az-ai-tools gc-ai-tools gh-ai-tools"
  local maintainer="update-ai-tools remove-ai-tools reinstall-ai-tools"

  f="$AI_TOOLS/skills/SKILL-CONTRACT.md"
  if [ ! -e "$f" ]; then ok "skill contract absent: $f"; else warn "skill contract must not exist: $f"; fi
  f="$AI_TOOLS/skills/MAINTAINER.md"
  if [ ! -e "$f" ]; then ok "maintainer workflow absent: $f"; else warn "maintainer workflow must not exist: $f"; fi

  for f in "$AI_TOOLS"/skills/*.md; do
    [ -f "$f" ] || continue
    warn "skill-root markdown file must not exist: $f"
  done

  f="$AI_TOOLS/USER-AGENTS.md"
  if grep -q '^## How to route a request' "$f"; then
    ok "USER-AGENTS.md has How to route a request heading: $f"
  else
    warn "USER-AGENTS.md missing '## How to route a request' heading: $f"
  fi
  if grep -q 'Min\. role' "$f"; then
    ok "USER-AGENTS.md has Min. role column: $f"
  else
    warn "USER-AGENTS.md missing 'Min. role' column: $f"
  fi

  for name in $gated $maintainer; do
    f="$AI_TOOLS/skills/$name/SKILL.md"
    if [ -f "$f" ]; then
      ok "shipped skill present: $f"
    else
      warn "missing shipped skill: $f"
    fi
  done

  for d in "$AI_TOOLS"/skills/*/; do
    [ -d "$d" ] || continue
    f="${d}SKILL.md"
    if [ -f "$f" ]; then
      ok "skill directory has SKILL.md: $f"
      if grep -q '^## Continue?' "$f"; then
        warn "SKILL.md must not contain Continue? heading: $f"
      else
        ok "SKILL.md has no Continue? heading: $f"
      fi
      if grep -q '^## Stake' "$f"; then
        warn "SKILL.md must not contain Stake heading: $f"
      else
        ok "SKILL.md has no Stake heading: $f"
      fi
      if grep -qE 'SKILL-CONTRACT|MAINTAINER\.md' "$f"; then
        warn "SKILL.md mentions deleted contract or maintainer file: $f"
      else
        ok "SKILL.md mentions neither SKILL-CONTRACT nor MAINTAINER.md: $f"
      fi
    else
      warn "missing SKILL.md in skill directory: $d"
    fi
  done
}

yaml_frontmatter_folded_value() {
  # usage: yaml_frontmatter_folded_value <file> <key> -- the value of a
  # "key: >" folded block, continuation lines joined by one space as the
  # harness folds them. Falls back to a plain single-line value.
  awk -v key="$2" '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { exit }
    infm && folded && /^[A-Za-z0-9_-]+:/ { exit }
    infm && folded {
      sub(/^[ \t]+/, "")
      out = (out == "") ? $0 : out " " $0
      next
    }
    infm && $0 ~ "^" key ":[ \t]*>[ \t]*$" { folded = 1; next }
    infm && $0 ~ "^" key ":" {
      sub("^" key ":[ \t]*", "")
      gsub(/^"|"$/, "")
      out = $0
      exit
    }
    END { print out }
  ' "$1"
}

char_count_str() {
  # usage: char_count_str <string> -- like char_count but for a string
  if [ -n "$UTF8_LOCALE" ]; then
    printf '%s' "$1" | LC_ALL="$UTF8_LOCALE" wc -m | tr -d ' '
  else
    printf '%s' "$1" | wc -m | tr -d ' '
  fi
}

check_skill_description_cap() {
  local d name f val count cap=500 max=0 maxf=""
  for d in "$AI_TOOLS"/skills/*-ai-tools/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    f="${d}SKILL.md"
    [ -f "$f" ] || continue
    val=$(yaml_frontmatter_folded_value "$f" description)
    count=$(char_count_str "$val")
    if [ "$count" -le "$cap" ]; then ok "skill description within cap: $f ($count/$cap)"
    else warn "skill description exceeds $cap chars: $f ($count)"; fi
    if [ "$count" -gt "$max" ]; then max=$count; maxf=$f; fi
  done
  [ -n "$maxf" ] && ok "largest skill description: $maxf ($max/$cap, headroom $((cap - max)))"
}

check_skill_description_content() {
  # rule 9: description states (1) what the skill does, then (2) Impact: plus the Stake
  local d f val before after
  for d in "$AI_TOOLS"/skills/*-ai-tools/; do
    [ -d "$d" ] || continue
    f="${d}SKILL.md"
    [ -f "$f" ] || continue
    val=$(yaml_frontmatter_folded_value "$f" description)
    case "$val" in
      *"Impact:"*)
        before=$(printf '%s\n' "$val" | awk '{ sub(/Impact:.*/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); print }')
        after=$(printf '%s\n' "$val" | awk '{ sub(/.*Impact:/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); print }')
        if [ -z "$before" ]; then
          warn "skill description has no what-it-does before Impact: $f"
        elif [ -z "$after" ]; then
          warn "skill description Impact has no stake text: $f"
        else
          ok "skill description has what + Impact: $f"
        fi
        ;;
      *)
        warn "skill description missing Impact: (rule 9): $f"
        ;;
    esac
  done
}

# --- Check: wrapper body and model parity (rules 6, 11-12) --------------------
# Never hard-code a vendor model name here — every expected model is resolved
# through model_for, reading MODELS.md in place.

canonical_body() {
  # usage: canonical_body <agent-name>
  # Reconstructs the exact wrapper body text (README, "Model map and wrapper
  # authoring"). A regex would accept the drift this check exists to reject.
  # The pin lives in the header; the body never names MODELS.md or a harness row.
  local a="$1"
  # shellcheck disable=SC2016 # $HOME/%USERPROFILE% must stay literal — expanding them is the bug this check catches
  printf 'On Windows, %%USERPROFILE%% replaces $HOME.\n\n'
  # shellcheck disable=SC2016 # $HOME must stay literal — expanding it is the bug this check catches
  printf 'You are a spawned subagent: your shared contract is `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md`.\n'
  printf 'Read it and follow it — it governs your channel to the user and your report.\n\n'
  # shellcheck disable=SC2016 # $HOME must stay literal — expanding it is the bug this check catches
  printf 'Your base file is `$HOME/.ai-tools/agents/%s.md`.\n' "$a"
  printf 'Read it and follow it in full — it is the absolute rule set for this agent; the contract above prevails only on your channel to the user.\n'
}

wrapper_body_md() {
  # usage: wrapper_body_md <file> -- body after the frontmatter's closing
  # "---", with the one blank separator line dropped.
  awk '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { infm = 0; started = 1; skip = 1; next }
    started && skip && $0 == "" { skip = 0; next }
    started { skip = 0; print }
  ' "$1"
}

wrapper_body_toml() {
  # usage: wrapper_body_toml <file> -- the developer_instructions value,
  # a """-delimited multi-line basic string.
  awk '
    /^developer_instructions = """$/ { infm = 1; next }
    infm && $0 == "\"\"\"" { infm = 0; exit }
    infm { print }
  ' "$1"
}

check_wrapper_body() {
  local a h f ext actual expected
  for a in $(agent_names); do
    expected=$(canonical_body "$a")
    for h in $(harnesses); do
      f=$(wrapper_path "$h" "$a")
      [ -f "$f" ] || continue
      ext=$(wrapper_ext "$h")
      if [ "$ext" = toml ]; then
        actual=$(wrapper_body_toml "$f")
      else
        actual=$(wrapper_body_md "$f")
      fi
      if [ "$actual" = "$expected" ]; then
        ok "wrapper body matches canonical text: $f"
      else
        warn "wrapper body does not match canonical text: $f"
      fi
    done
  done
}

model_effort_for() {
  # usage: model_effort_for <harness-key> <planner|implementer|mechanical>
  # Prints the MODELS.md cell's " · effort" word, or nothing when absent.
  local key="$1" col
  case "$2" in
    planner)     col=4 ;;
    implementer) col=5 ;;
    mechanical)  col=6 ;;
    *)           return 1 ;;
  esac
  [ -f "$MODELS_MAP" ] || return 1
  awk -F'|' -v key="$key" -v col="$col" '
    $2 ~ /`[a-z0-9-]+`/ {
      k = $2; gsub(/[`[:space:]]/, "", k)
      if (k == key) {
        v = $col
        if (match(v, /·[[:space:]]*[A-Za-z0-9]+/)) {
          e = substr(v, RSTART, RLENGTH)
          sub(/^·[[:space:]]*/, "", e)
          print e
        }
        exit
      }
    }
  ' "$MODELS_MAP"
}

check_model_parity() {
  # category_for lives in scripts/shell/lib.sh — the category the base claims.
  local h a f val expected cat
  for h in $(harnesses); do
    for a in $(agent_names); do
      f=$(wrapper_path "$h" "$a")
      [ -f "$f" ] || continue
      cat=$(category_for "$a")
      expected=$(model_for "$h" "$cat") || { warn "no usable MODELS.md row for $h/$cat: $f"; continue; }
      case "$h" in
        grok)
          if in_list model "$(yaml_frontmatter_keys "$f" | tr '\n' ' ')"; then
            warn "grok wrapper declares model: (Grok ignores it; pinned via ~/.grok/config.toml at install time): $f"
          else
            ok "grok wrapper declares no model key: $f"
          fi
          ;;
        codex)
          val=$(toml_field_value "$f" model)
          if [ "$val" = "$expected" ]; then ok "model parity: $f ($val)"
          else warn "model mismatch: $f (expected: $expected, got: '$val')"; fi
          ;;
        copilot)
          val=$(yaml_frontmatter_value "$f" model)
          case "$val" in
            \[*) warn "copilot model: must be a string, not an array: $f (got: '$val')" ;;
            *)
              if [ "$val" = "$expected" ]; then ok "model parity: $f ($val)"
              else warn "model mismatch: $f (expected: $expected, got: '$val')"; fi
              ;;
          esac
          ;;
        *)
          val=$(yaml_frontmatter_value "$f" model)
          if [ "$val" = "$expected" ]; then ok "model parity: $f ($val)"
          else warn "model mismatch: $f (expected: $expected, got: '$val')"; fi
          ;;
      esac
    done
  done
}

check_effort_pinning() {
  local a cat f eff val
  for a in $(agent_names); do
    cat=$(category_for "$a")
    f=$(wrapper_path claude-code "$a")
    if [ -f "$f" ]; then
      eff=$(model_effort_for claude-code "$cat")
      if [ -n "$eff" ]; then
        val=$(yaml_frontmatter_value "$f" effort)
        if [ "$val" = "$eff" ]; then ok "effort pinned: $f ($eff)"
        else warn "effort not pinned or mismatched: $f (expected: $eff, got: '$val')"; fi
      fi
    fi
    f=$(wrapper_path codex "$a")
    if [ -f "$f" ]; then
      eff=$(model_effort_for codex "$cat")
      if [ -n "$eff" ]; then
        val=$(toml_field_value "$f" model_reasoning_effort)
        if [ "$val" = "$eff" ]; then ok "effort pinned: $f ($eff)"
        else warn "effort not pinned or mismatched: $f (expected: $eff, got: '$val')"; fi
      fi
    fi
  done
}

check_description_parity() {
  local a h f val ext first
  for a in $(agent_names); do
    first=""
    for h in $(harnesses); do
      f=$(wrapper_path "$h" "$a")
      [ -f "$f" ] || continue
      ext=$(wrapper_ext "$h")
      if [ "$ext" = toml ]; then
        val=$(toml_field_value "$f" description)
      else
        val=$(yaml_frontmatter_value "$f" description)
      fi
      if [ -z "$first" ]; then
        first="$val"
        ok "description baseline set: $f"
      elif [ "$val" = "$first" ]; then
        ok "description matches baseline: $f"
      else
        warn "description diverges across wrappers for $a: $f"
      fi
    done
  done
}

check_models_row_coverage() {
  local h k rows
  rows=$(awk -F'|' '$2 ~ /`[a-z0-9-]+`/ { k = $2; gsub(/[`[:space:]]/, "", k); print k }' "$MODELS_MAP" 2>/dev/null)
  for h in $(harnesses); do
    if in_list "$h" "$(echo "$rows" | tr '\n' ' ')"; then
      ok "MODELS.md row present: $h"
    else
      warn "agents/$h/ has no MODELS.md row"
    fi
  done
  for k in $rows; do
    if [ -d "$AI_TOOLS/agents/$k" ]; then
      ok "MODELS.md row has a wrapper directory: $k"
    else
      warn "MODELS.md row without agents/ directory: $k"
    fi
  done
}

# --- Format helpers -----------------------------------------------------------

utf8_locale() {
  # Prints the first installed UTF-8 locale from a short preference list, so
  # char_count below counts characters, not bytes, on both BSD and GNU
  # userlands. Empty output means none was found; callers fall back to the
  # ambient environment.
  local l
  for l in C.UTF-8 C.utf8 en_US.UTF-8 en_US.utf8; do
    if locale -a 2>/dev/null | grep -qix "$l"; then echo "$l"; return 0; fi
  done
  return 1
}
UTF8_LOCALE=$(utf8_locale 2>/dev/null || true)

char_count() {
  # usage: char_count <file> -- character count under a UTF-8 locale when one
  # is installed, so em dashes and accented text count as one character each.
  if [ -n "$UTF8_LOCALE" ]; then
    LC_ALL="$UTF8_LOCALE" wc -m <"$1" | tr -d ' '
  else
    wc -m <"$1" | tr -d ' '
  fi
}

check_instructions_cap() {
  local f count cap=8000
  f="$AI_TOOLS/USER-AGENTS.md"
  if [ ! -f "$f" ]; then warn "missing: $f"; return; fi
  count=$(char_count "$f")
  if [ "$count" -le "$cap" ]; then
    ok "USER-AGENTS.md within cap: $count/$cap chars (headroom $((cap - count)))"
  else
    warn "USER-AGENTS.md exceeds $cap chars: $count (over by $((count - cap)))"
  fi
}

check_wrapper_cap() {
  local h f count cap=1000 max=0 maxf=""
  for h in $(harnesses); do
    for f in "$AI_TOOLS/agents/$h"/*; do
      [ -f "$f" ] || continue
      count=$(char_count "$f")
      if [ "$count" -le "$cap" ]; then ok "wrapper within cap: $f ($count/$cap)"
      else warn "wrapper exceeds $cap chars: $f ($count)"; fi
      if [ "$count" -gt "$max" ]; then max=$count; maxf=$f; fi
    done
  done
  [ -n "$maxf" ] && ok "largest wrapper: $maxf ($max/$cap, headroom $((cap - max)))"
}

check_line_endings() {
  # Reads git's own .gitattributes resolution via `ls-files --eol` rather
  # than reimplementing it (rule 28): index side must be lf, working-tree
  # side and the declared attribute must match the expected style per path.
  local line path fields idx work attr expected
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    path=${line##*$'\t'}
    fields=${line%%$'\t'*}
    idx=$(printf '%s\n' "$fields" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^i\//) print $i}')
    work=$(printf '%s\n' "$fields" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^w\//) print $i}')
    attr=$(printf '%s\n' "$fields" | grep -o 'eol=[a-z]*' || true)
    expected=lf
    if [ "$attr" != "eol=$expected" ]; then
      warn "line-ending attribute unexpected: $path (attr: ${attr:-none}, expected: eol=$expected)"
    elif [ "$idx" != "i/lf" ]; then
      warn "index side not lf: $path ($idx)"
    elif [ "$work" != "w/$expected" ]; then
      warn "working-tree line endings mismatch: $path ($work, wants eol=$expected)"
    else
      ok "line endings correct: $path ($expected)"
    fi
  done < <(git -C "$AI_TOOLS" ls-files --eol -- scripts/shell tools)
}

check_executable_bits() {
  local f mode
  for f in "$AI_TOOLS"/scripts/shell/*.sh "$AI_TOOLS"/tools/*.sh "$AI_TOOLS"/tools/test.sh; do
    [ -f "$f" ] || continue
    mode=$(git -C "$AI_TOOLS" ls-files -s -- "$f" | awk '{print $1}')
    if [ "$mode" = 100755 ]; then ok "executable bit set: $f"
    else warn "executable bit missing (mode: ${mode:-untracked}): $f"; fi
  done
}

check_no_binaries() {
  local f p
  for p in $(git -C "$AI_TOOLS" ls-files agents skills scripts tools); do
    f="$AI_TOOLS/$p"
    [ -f "$f" ] || continue
    if [ ! -s "$f" ] || grep -Iq . "$f" 2>/dev/null; then
      ok "text: $f"
    else
      warn "binary or non-text file in a shipped path: $f"
    fi
  done
}

# --- Check: version bump on shipped content change (rule 4) ------------------
# CI-only: needs --base <ref>, a commit-ish this run diffs against. Without
# it there is no meaningful base for a dirty local tree, so the check is
# skipped rather than guessed at.

readme_version() {
  # usage: readme_version <file> -- the version from the README's leading
  # "> **Version X** ..." line, the single source this check reads from.
  awk '
    NR <= 5 && /^> \*\*Version [^*]+\*\*/ {
      v = $0
      sub(/^> \*\*Version /, "", v)
      sub(/\*\*.*/, "", v)
      print v
      exit
    }
  ' "$1"
}

check_version_bump() {
  local base="$BASE_REF" changed old new
  if [ -z "$base" ]; then
    skip "version bump check needs --base <ref> (the lint workflow supplies it)"
    return
  fi
  changed=$(git -C "$AI_TOOLS" diff --name-only "$base...HEAD" -- agents skills scripts USER-AGENTS.md 2>/dev/null)
  if [ -z "$changed" ]; then
    ok "no shipped content changed since $base: version bump not required"
    return
  fi
  old=$(readme_version <(git -C "$AI_TOOLS" show "$base:README.md" 2>/dev/null))
  new=$(readme_version <(git -C "$AI_TOOLS" show "HEAD:README.md" 2>/dev/null))
  if [ -n "$old" ] && [ -n "$new" ] && [ "$old" != "$new" ]; then
    ok "version bumped for shipped content change: $old -> $new"
  else
    warn "shipped content changed without a README version bump (still ${new:-unreadable}, was ${old:-unreadable}): $(echo "$changed" | tr '\n' ' ')"
  fi
}

# --- Run -----------------------------------------------------------------------

check_wrapper_coverage
check_naming
check_skill_frontmatter
check_skill_name_match
check_skill_layout
check_skill_description_cap
check_skill_description_content
check_wrapper_body
check_model_parity
check_effort_pinning
check_description_parity
check_models_row_coverage
check_instructions_cap
check_wrapper_cap
check_line_endings
check_executable_bits
check_no_binaries
check_version_bump

finish
