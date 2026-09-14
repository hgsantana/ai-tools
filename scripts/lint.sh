#!/usr/bin/env bash
# ai-tools rule linter — a development check, not an installation process
# (outside the contract of README rules 25-27). Enforces this repository's
# mechanically verifiable rules against the tree it runs in.
#
# Usage: scripts/lint.sh [--help] [--base <ref>]
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
25-27); introduces no new dependency beyond git, grep, awk, sed, wc, and tr.

Checks:
  naming            every skills/*/ directory ends in -ai-tools (rule 14)
  skill frontmatter every skills/*/SKILL.md exists with frontmatter keys a
                    subset of name, description, argument-hint (rule 9)
  skill name match  skills/<x>/SKILL.md declares name: <x>
  skill description every skill description is at most 500 characters,
                    folded block included, and states what the skill does,
                    then Impact: (rule 9)
  skill layout      no skill-root markdown, every skill directory has
                    SKILL.md with semantic XML tags (<skill>, <session_workflow>,
                    <dispatch_templates>), no SKILL.md contains Continue? or Stake,
                    USER-AGENTS.md has <routing_gate>,
                    and no references to deleted files (rule 7)
  instructions cap  USER-AGENTS.md is at most 8000 characters (rule 3)
  line endings      git ls-files --eol matches the declared eol= attribute:
                    lf for scripts/ (rule 28)
  executable bits   scripts/shell/*.sh and scripts/*.sh are mode 100755
                    (rule 28)
  no binaries       every tracked file under skills/ and scripts/
                    is text
  version bump      CI-only, needs --base <ref> (skipped without it): when
                    skills/, scripts/, or USER-AGENTS.md changed
                    since <ref>, the README version line must have changed
                    too (rule 4)
  dev/tmp untracked git ls-files dev/tmp returns nothing (rule 29)
  xml grammar       every semantic-XML body (USER-AGENTS.md, SKILL.md) is
                    balanced once backticked spans are removed, uses only
                    vocabulary tags outside <input>, gives every <rule> a
                    unique id, and every <template> a role (rule 16,
                    Semantic XML grammar)
  xml references    every backticked tag reference resolves: attribute
                    references to a definition in the same or the qualified
                    file, bare references to the vocabulary (rule 16)
  placeholder parity every {PLACEHOLDER} a <template> uses is declared in its
                    <input>, and every declared one is used (rule 16)

--base <ref>  commit-ish to diff shipped content against for the version
              bump check. Without it, that check is skipped. The lint
              workflow (.github/workflows/ci.yml) supplies it.

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

ends_in_ai_tools() {
  case "$1" in *-ai-tools) return 0 ;; *) return 1 ;; esac
}

in_list() {
  # usage: in_list <needle> <space-separated haystack>
  case " $2 " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

# --- Check: naming (rule 14) --------------------------------------------------

check_naming() {
  local d b
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

# --- Check: skill layout and description (rules 7, 9) ------------------------

check_skill_layout() {
  local f d name
  local gated="vibe-ai-tools plan-ai-tools dev-ai-tools campaign-ai-tools az-ai-tools gc-ai-tools gh-ai-tools"
  local maintainer="update-ai-tools remove-ai-tools models-ai-tools"

  f="$AI_TOOLS/skills/SKILL-CONTRACT.md"
  if [ ! -e "$f" ]; then ok "skill contract absent: $f"; else warn "skill contract must not exist: $f"; fi
  f="$AI_TOOLS/skills/MAINTAINER.md"
  if [ ! -e "$f" ]; then ok "maintainer workflow absent: $f"; else warn "maintainer workflow must not exist: $f"; fi

  for f in "$AI_TOOLS"/skills/*.md; do
    [ -f "$f" ] || continue
    warn "skill-root markdown file must not exist: $f"
  done

  f="$AI_TOOLS/USER-AGENTS.md"
  if grep -q '<routing_gate>' "$f"; then
    ok "USER-AGENTS.md has routing_gate tag: $f"
  else
    warn "USER-AGENTS.md missing '<routing_gate>' tag: $f"
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
      if grep -q '^<skill name="' "$f" && grep -q '</skill>$' "$f"; then
        ok "SKILL.md has valid root skill XML tags: $f"
      else
        warn "SKILL.md missing valid root <skill name=\"...\"> ... </skill> tags: $f"
      fi
      if grep -q '<session_workflow>' "$f" && grep -q '</session_workflow>' "$f"; then
        ok "SKILL.md has semantic session_workflow tags: $f"
      else
        warn "SKILL.md missing <session_workflow> ... </session_workflow> tags: $f"
      fi
      if grep -q '<dispatch_templates>' "$f" && grep -q '</dispatch_templates>' "$f"; then
        ok "SKILL.md has semantic dispatch_templates tags: $f"
      else
        warn "SKILL.md missing <dispatch_templates> ... </dispatch_templates> tags: $f"
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
  # rule 9: description states what it does, then Impact:
  local d f val before impact
  for d in "$AI_TOOLS"/skills/*-ai-tools/; do
    [ -d "$d" ] || continue
    f="${d}SKILL.md"
    [ -f "$f" ] || continue
    val=$(yaml_frontmatter_folded_value "$f" description)
    case "$val" in
      *"Impact:"*)
        before=$(printf '%s\n' "$val" | awk '{ sub(/Impact:.*/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); print }')
        impact=$(printf '%s\n' "$val" | awk '{ sub(/.*Impact:/, ""); gsub(/^[ \t]+|[ \t]+$/, ""); print }')
        if [ -n "$before" ] && [ -n "$impact" ]; then
          ok "skill description has what + Impact: $f"
        else
          warn "skill description missing Impact: (rule 9): $f"
        fi
        ;;
      *)
        warn "skill description missing Impact: (rule 9): $f"
        ;;
    esac
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
      warn "index side is not LF: $path ($idx)"
    elif [ "$work" != "w/$expected" ]; then
      warn "working-tree line endings mismatch: $path ($work, wants eol=$expected)"
    else
      ok "line endings correct: $path ($expected)"
    fi
  done < <(git -C "$AI_TOOLS" ls-files --eol -- scripts)
}

check_executable_bits() {
  local f mode
  for f in "$AI_TOOLS"/scripts/shell/*.sh "$AI_TOOLS"/scripts/*.sh; do
    [ -f "$f" ] || continue
    mode=$(git -C "$AI_TOOLS" ls-files -s -- "$f" | awk '{print $1}')
    if [ "$mode" = 100755 ]; then ok "executable bit set: $f"
    else warn "executable bit missing (mode: ${mode:-untracked}): $f"; fi
  done
}

check_no_binaries() {
  local f p
  for p in $(git -C "$AI_TOOLS" ls-files skills scripts); do
    f="$AI_TOOLS/$p"
    [ -f "$f" ] || continue
    if [ ! -s "$f" ] || grep -Iq . "$f" 2>/dev/null; then
      ok "text: $f"
    else
      warn "binary or non-text file in a shipped path: $f"
    fi
  done
}

# --- Check: semantic XML grammar (rule 16) -----------------------------------
# The vocabulary of structural tags (README, "Semantic XML grammar"). A tag
# outside it, outside <input>, is a finding: register a new tag in the README
# table and here in the same commit.
XML_VOCAB="user_instructions system_overview routing_gate trigger_cases case skill_offer offer_message handling response dispatch_protocol agents worker language_rules chat disk user_interaction fallback security_guardrails skill overview session_workflow step dispatch_templates template job input instructions constraints constraint status_protocol states state return_protocol signal selection_method plan_file_format structure boundaries rule skill_question skill_options default"

xml_files() {
  local f
  echo "$AI_TOOLS/USER-AGENTS.md"
  for f in "$AI_TOOLS"/skills/*/SKILL.md; do [ -f "$f" ] && echo "$f"; done
}

xml_body() {
  # usage: xml_body <file> -- the semantic-XML body: frontmatter and leading
  # prose dropped, every backticked span replaced by `` so references and
  # code never read as tags.
  awk '
    NR == 1 && $0 == "---" { infm = 1; next }
    infm && $0 == "---" { infm = 0; next }
    infm { next }
    !started && /^<[a-z_]+/ { started = 1 }
    started { gsub(/`[^`]*`/, "``"); print }
  ' "$1"
}

xml_file_for() {
  # usage: xml_file_for <qualifier> -> the file a qualified reference names,
  # or nothing when the word before the backtick is not a qualifier.
  case "$1" in
    USER-AGENTS) echo "$AI_TOOLS/USER-AGENTS.md" ;;
    *-ai-tools)
      if [ -f "$AI_TOOLS/skills/$1/SKILL.md" ]; then echo "$AI_TOOLS/skills/$1/SKILL.md"; fi
      ;;
  esac
}

xml_references() {
  # usage: xml_references <file> -- one "qualifier|reference" line per
  # backticked tag reference, qualifier being the word before the backtick.
  awk '{
    line = $0
    while (match(line, /`<[a-z_]+[^`]*>`/)) {
      start = RSTART; len = RLENGTH
      ref = substr(line, start + 2, len - 4)
      pre = substr(line, 1, start - 1)
      q = ""
      if (match(pre, /[A-Za-z-]+ $/)) q = substr(pre, RSTART, RLENGTH - 1)
      n = split(ref, parts, /> +</)
      for (i = 1; i <= n; i++) print q "|" parts[i]
      line = substr(line, start + len)
    }
  }' "$1"
}

check_xml_grammar() {
  local f findings line val q ref name attr target
  for f in $(xml_files); do
    findings=$(xml_body "$f" | awk -v vocab="$XML_VOCAB" '
      BEGIN { n = split(vocab, v, " "); for (i = 1; i <= n; i++) ok[v[i]] = 1 }
      {
        line = $0
        while (match(line, /<[^<>]*>/)) {
          if (substr(line, 1, RSTART - 1) ~ /</) print "stray < at line " NR
          tok = substr(line, RSTART + 1, RLENGTH - 2)
          line = substr(line, RSTART + RLENGTH)
          if (tok ~ /^\//) {
            name = substr(tok, 2)
            if (depth == 0 || stack[depth] != name) print "mismatched closing tag </" name "> at line " NR
            else { depth--; if (name == "input") ininput = 0 }
            continue
          }
          name = tok; sub(/[ \/].*/, "", name)
          if (tok !~ /\/$/) { depth++; stack[depth] = name }
          if (name == "input") { ininput = 1; continue }
          if (ininput) continue
          if (!(name in ok)) print "tag outside the vocabulary <" name "> at line " NR
          if (name == "rule") {
            if (tok !~ / id="[a-z0-9-]+"/) print "<rule> without id at line " NR
            else {
              id = tok; sub(/.* id="/, "", id); sub(/".*/, "", id)
              if (id in ids) print "duplicate rule id \"" id "\" at line " NR
              ids[id] = 1
            }
          }
          if (name == "template") {
            if (tok !~ / role="[a-z0-9-]+"/) print "<template> without role at line " NR
          }
        }
        if (line ~ /</) print "stray < at line " NR
      }
      END { if (depth > 0) print "unclosed <" stack[depth] "> at end of body" }
    ')
    if [ -z "$findings" ]; then
      ok "semantic XML balanced, in vocabulary, rules and templates addressable: $f"
    else
      while IFS= read -r line; do warn "xml grammar: $line: $f"; done <<EOF
$findings
EOF
    fi

    findings=$(xml_body "$f" | awk '
      /<template role="/ { intpl = 1; role = $0; sub(/.*role="/, "", role); sub(/".*/, "", role); split("", used); split("", decl); next }
      intpl && /<input>/ { inin = 1; next }
      intpl && /<\/input>/ { inin = 0; next }
      intpl && /<\/template>/ {
        for (u in used) if (!(u in decl)) print "template " role " uses undeclared placeholder " u
        for (d in decl) if (!(d in used)) print "template " role " declares unused placeholder " d
        intpl = 0; next
      }
      intpl {
        line = $0
        while (match(line, /\{[A-Z_]+\}/)) {
          ph = substr(line, RSTART, RLENGTH)
          if (inin) decl[ph] = 1; else used[ph] = 1
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ')
    if [ -z "$findings" ]; then
      ok "template placeholders match their input: $f"
    else
      while IFS= read -r line; do warn "placeholder parity: $line: $f"; done <<EOF
$findings
EOF
    fi

    while IFS='|' read -r q ref; do
      [ -n "$ref" ] || continue
      name=${ref%% *}
      attr=""; val=""
      case "$ref" in
        *" "*) attr=${ref#* }; val=${attr#*=\"}; val=${val%\"}; attr=${attr%%=*} ;;
      esac
      target=""
      [ -n "$q" ] && target=$(xml_file_for "$q")
      [ -n "$target" ] || q=""
      [ -n "$target" ] || target="$f"
      if [ -n "$attr" ]; then
        if xml_body "$target" | grep -q "<${name}[^>]* ${attr}=\"${val}\""; then
          ok "reference resolves: <$name $attr=\"$val\"> in $f"
        else
          warn "unresolved reference <$name $attr=\"$val\"> in $f (looked in $target)"
        fi
      elif [ -n "$q" ]; then
        if xml_body "$target" | grep -q "<${name}[ >/]"; then
          ok "qualified reference resolves: $q <$name> in $f"
        else
          warn "unresolved qualified reference $q <$name> in $f (looked in $target)"
        fi
      elif in_list "$name" "$XML_VOCAB"; then
        ok "reference names a vocabulary tag: <$name> in $f"
      else
        warn "reference to a tag outside the vocabulary <$name> in $f"
      fi
    done < <(xml_references "$f")
  done
}

# --- Check: dev/tmp untracked (rule 29) ---------------------------------------

check_dev_tmp_untracked() {
  local tracked
  tracked=$(git -C "$AI_TOOLS" ls-files dev/tmp)
  if [ -z "$tracked" ]; then
    ok "dev/tmp untracked: no tracked files under dev/tmp"
  else
    warn "tracked file(s) under dev/tmp (rule 29): $(echo "$tracked" | tr '\n' ' ')"
  fi
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
  changed=$(git -C "$AI_TOOLS" diff --name-only "$base...HEAD" -- skills scripts USER-AGENTS.md 2>/dev/null)
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

check_naming
check_skill_frontmatter
check_skill_name_match
check_skill_layout
check_skill_description_cap
check_skill_description_content
check_instructions_cap
check_line_endings
check_executable_bits
check_no_binaries
check_dev_tmp_untracked
check_xml_grammar
check_version_bump

finish
