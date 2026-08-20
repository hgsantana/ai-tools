#!/usr/bin/env bash
# tools/models.sh — fetch LiveBench's published leaderboard data and emit
# one deterministic CSV mapping models to category scores. This CSV is the
# evidence MODELS.md's "Choosing the models" reads; it is not shipped and
# not part of the installation contract of README rules 23-24 (same
# standing as tools/lint.sh, tools/test.sh).
#
# Usage: tools/models.sh [--help] [--release YYYY-MM-DD] [--out <path>]
#                         [--offline <dir>] [--quiet]
#
#   --release YYYY-MM-DD  use this LiveBench release instead of resolving
#                         the latest one from livebench.ai. Required with
#                         --offline (no release list to resolve offline).
#   --out <path>          write the CSV here instead of the default
#                         plans/dev/livebench-model-map.csv (repo root
#                         relative; plans/*/ is gitignored, this is a
#                         generated artifact, not committed)
#   --offline <dir>       read table.csv, cost.csv, categories.json, and
#                         optional bundle.js from <dir> instead of the
#                         network; used by tools/test/models.sh
#   --quiet               suppress progress lines on stderr
#
# Source chain (network, all deterministic):
#   1. GET https://livebench.ai/ -- extract the single static/js/main.<hash>.js
#      bundle path.
#   2. GET that bundle -- extract the release list (a JS array of >=3
#      "YYYY-MM-DD" strings); the last element is the latest release,
#      unless --release overrides it.
#   3. GET table_<r>.csv, cost_<r>.csv, categories_<r>.json for the
#      resolved release (r = release with "-" -> "_"), all required.
#   4. Best-effort: model metadata (organization, display name, open
#      weight, reasoner, variants) from the same bundle. Never fails the
#      run; missing/unparsable metadata leaves those columns empty and
#      warns on stderr.
#
# Dependencies: curl, awk, sed, grep, sort, printf (plus ordinary POSIX
# file utilities: mkdir, rm, cat, mv, tr, mktemp). No python, no jq, no
# node.
#
# Exit: 0 ok, 1 precondition (bad flag, missing value, bad --offline dir),
# 2 data/network failure (unresolvable bundle/release, missing/empty
# source file, a score-formula category absent from categories.json).
set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AI_TOOLS=$(cd "$SCRIPT_DIR/.." && pwd)

BASE_URL="https://livebench.ai"
QUIET=0

progress() { [ "$QUIET" = 1 ] && return 0; printf '%s\n' "$*" >&2; return 0; }
warn()     { printf 'WARN: %s\n' "$*" >&2; }
fatal1()   { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
fatal2()   { printf 'ERROR: %s\n' "$*" >&2; exit 2; }

usage() {
  cat <<'EOF'
usage: models.sh [--help] [--release YYYY-MM-DD] [--out <path>] [--offline <dir>] [--quiet]

Development tool (outside README rules 23-24): fetches LiveBench's
published leaderboard data and writes one deterministic CSV of per-model
category scores to plans/dev/livebench-model-map.csv (or --out).

  --release YYYY-MM-DD  use this release instead of resolving the latest
                         one from livebench.ai; required together with
                         --offline
  --out <path>           output CSV path (default: plans/dev/livebench-model-map.csv)
  --offline <dir>         read table.csv, cost.csv, categories.json, and
                         optional bundle.js from <dir> instead of the
                         network (requires --release)
  --quiet                 suppress progress lines on stderr

Exit codes: 0 ok, 1 precondition, 2 data/network failure.
EOF
}

RELEASE="" OUT="" OFFLINE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --release)
      shift
      [ $# -gt 0 ] || fatal1 "--release requires a value (see --help)"
      RELEASE="$1"
      ;;
    --out)
      shift
      [ $# -gt 0 ] || fatal1 "--out requires a path (see --help)"
      OUT="$1"
      ;;
    --offline)
      shift
      [ $# -gt 0 ] || fatal1 "--offline requires a directory (see --help)"
      OFFLINE="$1"
      ;;
    --quiet) QUIET=1 ;;
    *) fatal1 "unknown flag: $1 (see --help)" ;;
  esac
  shift
done

[ -n "$OUT" ] || OUT="$AI_TOOLS/plans/dev/livebench-model-map.csv"

if [ -n "$OFFLINE" ]; then
  [ -n "$RELEASE" ] || fatal1 "--offline requires --release (no release list to resolve offline; see --help)"
fi

WORK=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-models.XXXXXX") || fatal2 "cannot create work directory"
# shellcheck disable=SC2317,SC2329 # invoked indirectly via "trap ... EXIT", not unreachable
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

# --- Resolve input files -------------------------------------------------

TABLE_CSV="" COST_CSV="" CATEGORIES_JSON="" BUNDLE_JS=""

if [ -n "$OFFLINE" ]; then
  [ -d "$OFFLINE" ] || fatal2 "--offline directory not found: $OFFLINE"
  TABLE_CSV="$OFFLINE/table.csv"
  COST_CSV="$OFFLINE/cost.csv"
  CATEGORIES_JSON="$OFFLINE/categories.json"
  [ -f "$TABLE_CSV" ] || fatal2 "--offline: missing $TABLE_CSV"
  [ -f "$COST_CSV" ] || fatal2 "--offline: missing $COST_CSV"
  [ -f "$CATEGORIES_JSON" ] || fatal2 "--offline: missing $CATEGORIES_JSON"
  if [ -f "$OFFLINE/bundle.js" ]; then
    BUNDLE_JS="$OFFLINE/bundle.js"
  else
    warn "no bundle.js in $OFFLINE: model metadata columns will be empty"
  fi
else
  progress "fetching $BASE_URL/"
  INDEX=$(curl -fsS -m 30 "$BASE_URL/") || fatal2 "GET $BASE_URL/ failed"
  BUNDLE_PATHS=$(printf '%s' "$INDEX" | grep -oE 'static/js/main\.[0-9a-f]+\.js' | sort -u)
  BUNDLE_COUNT=0
  if [ -n "$BUNDLE_PATHS" ]; then
    BUNDLE_COUNT=$(printf '%s\n' "$BUNDLE_PATHS" | grep -c '^')
  fi
  if [ "$BUNDLE_COUNT" -ne 1 ]; then
    fatal2 "expected exactly one static/js/main.<hash>.js reference on $BASE_URL/, found $BUNDLE_COUNT: $(printf '%s' "$BUNDLE_PATHS" | tr '\n' ' ')"
  fi
  BUNDLE_PATH="$BUNDLE_PATHS"

  progress "fetching $BASE_URL/$BUNDLE_PATH"
  BUNDLE_JS="$WORK/bundle.js"
  curl -fsS -m 60 "$BASE_URL/$BUNDLE_PATH" -o "$BUNDLE_JS" || fatal2 "GET $BASE_URL/$BUNDLE_PATH failed"
  [ -s "$BUNDLE_JS" ] || fatal2 "empty body: $BASE_URL/$BUNDLE_PATH"

  if [ -z "$RELEASE" ]; then
    RELLIST=$(grep -oE '\["[0-9]{4}-[0-9]{2}-[0-9]{2}"(,"[0-9]{4}-[0-9]{2}-[0-9]{2}"){2,}\]' "$BUNDLE_JS" | head -n 1)
    [ -n "$RELLIST" ] || fatal2 "cannot find a release list (>=3 \"YYYY-MM-DD\" entries) in $BASE_URL/$BUNDLE_PATH; pass --release YYYY-MM-DD"
    RELEASE=$(printf '%s' "$RELLIST" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | tail -n 1)
  fi

  R=$(printf '%s' "$RELEASE" | tr '-' '_')
  TABLE_CSV="$WORK/table.csv"
  progress "fetching $BASE_URL/table_$R.csv"
  curl -fsS -m 60 "$BASE_URL/table_$R.csv" -o "$TABLE_CSV" || fatal2 "GET $BASE_URL/table_$R.csv failed"
  [ -s "$TABLE_CSV" ] || fatal2 "empty body: $BASE_URL/table_$R.csv"

  COST_CSV="$WORK/cost.csv"
  progress "fetching $BASE_URL/cost_$R.csv"
  curl -fsS -m 60 "$BASE_URL/cost_$R.csv" -o "$COST_CSV" || fatal2 "GET $BASE_URL/cost_$R.csv failed"
  [ -s "$COST_CSV" ] || fatal2 "empty body: $BASE_URL/cost_$R.csv"

  CATEGORIES_JSON="$WORK/categories.json"
  progress "fetching $BASE_URL/categories_$R.json"
  curl -fsS -m 60 "$BASE_URL/categories_$R.json" -o "$CATEGORIES_JSON" || fatal2 "GET $BASE_URL/categories_$R.json failed"
  [ -s "$CATEGORIES_JSON" ] || fatal2 "empty body: $BASE_URL/categories_$R.json"
fi

# --- categories.json -> categories.tsv (category<TAB>task1,task2,...) ---
# categories.json is a flat object: category name -> array of task-column
# strings. No nested objects/arrays, so a line-joined grep/sed pass is
# sufficient (no python/jq needed).

CATEGORIES_TSV="$WORK/categories.tsv"
tr -d '\n' < "$CATEGORIES_JSON" | tr -d '\t' \
  | grep -oE '"[^"]+" *: *\[[^]]*\]' > "$WORK/categories.matches" || true

: > "$CATEGORIES_TSV"
while IFS= read -r line; do
  [ -n "$line" ] || continue
  key=$(printf '%s' "$line" | sed -E 's/^"([^"]*)".*/\1/')
  rest=$(printf '%s' "$line" | sed -E 's/^"[^"]*" *: *\[(.*)\]$/\1/')
  tasks=$(printf '%s' "$rest" | grep -oE '"[^"]*"' | sed -E 's/^"(.*)"$/\1/' | tr '\n' ',' | sed 's/,$//')
  printf '%s\t%s\n' "$key" "$tasks" >> "$CATEGORIES_TSV"
done < "$WORK/categories.matches"

[ -s "$CATEGORIES_TSV" ] || fatal2 "categories.json: no categories parsed from $CATEGORIES_JSON"

# --- validate the categories the score formulas need ---------------------

REQUIRED_CATEGORIES="Reasoning
Data Analysis
Coding
IF
Agentic Coding"

MISSING=""
while IFS= read -r want; do
  [ -n "$want" ] || continue
  if ! awk -F '\t' -v want="$want" '$1==want{found=1} END{exit(found?0:1)}' "$CATEGORIES_TSV"; then
    MISSING="$MISSING, $want"
  fi
done <<EOF
$REQUIRED_CATEGORIES
EOF

if [ -n "$MISSING" ]; then
  FOUND=$(awk -F '\t' '{printf "%s%s", (NR>1?", ":""), $1}' "$CATEGORIES_TSV")
  fatal2 "categories.json is missing categories the score formulas require:${MISSING#,} (found: $FOUND)"
fi

# --- task order: every task column in table.csv, LC_ALL=C ascending ------

TASK_ORDER_FILE="$WORK/task_order.txt"
head -n 1 "$TABLE_CSV" | tr ',' '\n' | tail -n +2 | LC_ALL=C sort > "$TASK_ORDER_FILE"
[ -s "$TASK_ORDER_FILE" ] || fatal2 "table.csv: no task columns found in $TABLE_CSV"

# --- bundle.js -> metadata.tsv (best effort, never fatal) -----------------
# rawname<TAB>organization<TAB>displayName<TAB>openweight<TAB>reasoner
# one line per raw model name; variants (variants:[{rawName,displayName}])
# get their own line, inheriting the parent's organization/openweight/reasoner.

METADATA_TSV="$WORK/metadata.tsv"
: > "$METADATA_TSV"
if [ -n "$BUNDLE_JS" ]; then
  METADATA_AWK="$WORK/metadata.awk"
  cat > "$METADATA_AWK" <<'AWKEOF'
function findbool(s, key) {
  if (index(s, key ":!0") > 0) return "true"
  if (index(s, key ":!1") > 0) return "false"
  if (index(s, key ":true") > 0) return "true"
  if (index(s, key ":false") > 0) return "false"
  return ""
}
function findstr(s, key,   pos, rest, q) {
  pos = index(s, key ":\"")
  if (pos == 0) return ""
  rest = substr(s, pos + length(key) + 2)
  q = index(rest, "\"")
  if (q == 0) return ""
  return substr(rest, 1, q - 1)
}
# skipstr: <start> indexes a quote character (' or ") in <s>; returns the
# position just past its matching (possibly backslash-escaped) closing
# quote of the same kind, and sets g_str to the content between the quotes.
# Distinguishing ' from " matters: a single-quoted JS string elsewhere in
# the bundle may contain a literal ", and treating every " byte as a string
# delimiter regardless of which quote opened it desyncs the whole scan.
function skipstr(s, start,   qc, n, j, cj) {
  qc = substr(s, start, 1)
  n = length(s)
  j = start + 1
  while (j <= n) {
    cj = substr(s, j, 1)
    if (cj == "\\") { j += 2; continue }
    if (cj == qc) { g_str = substr(s, start + 1, j - start - 1); return j + 1 }
    j++
  }
  g_str = substr(s, start + 1, n - start)
  return n + 1
}
# scanobj: scans a balanced {...} object starting at position start (the
# opening brace) in s; returns the position just past the matching closing
# brace, and sets g_obj to the object text (braces included). Quoted
# content (either kind) is skipped via skipstr so a brace inside a string
# value is never mistaken for structure.
function scanobj(s, start,   n, m, depth, c) {
  n = length(s)
  m = start
  depth = 0
  while (m <= n) {
    c = substr(s, m, 1)
    if (c == "\"" || c == "'") { m = skipstr(s, m); continue }
    if (c == "{") depth++
    else if (c == "}") {
      depth--
      if (depth == 0) { m++; break }
    }
    m++
  }
  g_obj = substr(s, start, m - start)
  return m
}
{ buf = buf $0 "\n" }
END {
  s = buf
  n = length(s)
  i = 1
  while (i <= n) {
    c = substr(s, i, 1)
    if (c == "'") { i = skipstr(s, i); continue }
    if (c != "\"") { i++; continue }
    ni = skipstr(s, i)
    key = g_str
    k = ni
    while (k <= n && index(" \t\r\n", substr(s, k, 1)) > 0) k++
    if (substr(s, k, 1) != ":") { i = ni; continue }
    k++
    while (k <= n && index(" \t\r\n", substr(s, k, 1)) > 0) k++
    if (substr(s, k, 1) != "{") { i = ni; continue }
    m = scanobj(s, k)
    val = g_obj
    if (key ~ /^[A-Za-z0-9_.-]+$/ && index(val, "organization:") > 0) {
      org = findstr(val, "organization")
      disp = findstr(val, "displayName")
      ow = findbool(val, "openweight")
      rs = findbool(val, "reasoner")
      printf "%s\t%s\t%s\t%s\t%s\n", key, org, disp, ow, rs
      vpos = index(val, "variants:[")
      if (vpos > 0) {
        vs = substr(val, vpos + 10)
        vn = length(vs)
        vi = 1
        while (vi <= vn) {
          vc = substr(vs, vi, 1)
          if (vc == "]") break
          if (vc != "{") { vi++; continue }
          vi2 = scanobj(vs, vi)
          vobj = g_obj
          vraw = findstr(vobj, "rawName")
          vdisp = findstr(vobj, "displayName")
          if (vraw != "") printf "%s\t%s\t%s\t%s\t%s\n", vraw, org, vdisp, ow, rs
          vi = vi2
        }
      }
    }
    i = m
  }
}
AWKEOF
  if ! awk -f "$METADATA_AWK" "$BUNDLE_JS" > "$METADATA_TSV" 2>"$WORK/metadata.err"; then
    warn "could not parse model metadata from bundle; metadata columns will be empty"
    : > "$METADATA_TSV"
  fi
  if [ ! -s "$METADATA_TSV" ]; then
    warn "no model metadata found in bundle; metadata columns will be empty"
  fi
fi

# --- compute.awk: category averages, global average, scores, ranks, ------
# --- frontier flags, and the final CSV body -------------------------------

COMPUTE_AWK="$WORK/compute.awk"
cat > "$COMPUTE_AWK" <<'AWKEOF'
function csvq(s,   t) {
  if (s == "") return ""
  if (s ~ /[",\n]/) {
    t = s
    gsub(/"/, "\"\"", t)
    return "\"" t "\""
  }
  return s
}
BEGIN {
  ncats = 0
  while ((getline line < categories_file) > 0) {
    split(line, parts, "\t")
    cat = parts[1]
    cat_order[++ncats] = cat
    cat_tasks[cat] = parts[2]
    slug = tolower(cat)
    gsub(/ /, "_", slug)
    cat_slug[cat] = slug
  }
  close(categories_file)

  while ((getline line < metadata_file) > 0) {
    split(line, parts, "\t")
    raw = parts[1]
    meta_org[raw] = parts[2]
    meta_disp[raw] = parts[3]
    meta_open[raw] = parts[4]
    meta_reason[raw] = parts[5]
  }
  close(metadata_file)

  ntasks = 0
  while ((getline line < task_order_file) > 0) {
    if (line == "") continue
    task_order[++ntasks] = line
  }
  close(task_order_file)

  fileidx = 0
  nmodels = 0
}
FNR == 1 { fileidx++ }

fileidx == 1 && FNR == 1 {
  ncol = split($0, t_hdr, ",")
  for (j = 2; j <= ncol; j++) t_col[j] = t_hdr[j]
  next
}
fileidx == 1 && FNR > 1 {
  ncol = split($0, f, ",")
  model = f[1]
  if (model == "") next
  if (!(model in seen_model)) { seen_model[model] = 1; models[++nmodels] = model }
  for (j = 2; j <= ncol; j++) {
    v = f[j]
    if (v ~ /^-?[0-9]+(\.[0-9]+)?$/) {
      key = model SUBSEP t_col[j]
      table_val[key] = v + 0
      table_has[key] = 1
    }
  }
  next
}

fileidx == 2 && FNR == 1 {
  ncol = split($0, hdr2, ",")
  for (j = 2; j <= ncol; j++) c_col[j] = hdr2[j]
  next
}
fileidx == 2 && FNR > 1 {
  ncol = split($0, f, ",")
  model = f[1]
  if (model == "") next
  for (j = 2; j <= ncol; j++) {
    cname = c_col[j]
    v = f[j]
    if (v !~ /^-?[0-9]+(\.[0-9]+)?$/) continue
    key = model SUBSEP cname
    if (cname ~ /^nq_/) {
      k2 = model SUBSEP substr(cname, 4)
      cost_q[k2] = v + 0; cost_q_has[k2] = 1
    } else if (cname ~ /^out_/) {
      k2 = model SUBSEP substr(cname, 5)
      cost_out[k2] = v + 0; cost_out_has[k2] = 1
    } else if (cname == "avg_input_tokens") { avg_in[model] = v + 0; avg_in_has[model] = 1 }
    else if (cname == "avg_output_tokens") { avg_out[model] = v + 0; avg_out_has[model] = 1 }
    else if (cname == "input_price_per_million") { price_in[model] = v + 0; price_in_has[model] = 1 }
    else if (cname == "output_price_per_million") { price_out[model] = v + 0; price_out_has[model] = 1 }
    else if (cname == "cost_per_question") { cpq[model] = v + 0; cpq_has[model] = 1 }
    else if (cname == "cost_per_successful_task") { cpst[model] = v + 0; cpst_has[model] = 1 }
    else { cost_task[key] = v + 0; cost_task_has[key] = 1 }
  }
  next
}

END {
  for (mi = 1; mi <= nmodels; mi++) {
    model = models[mi]
    for (ci = 1; ci <= ncats; ci++) {
      cat = cat_order[ci]
      ntk = split(cat_tasks[cat], tarr, ",")
      sum = 0; cnt = 0
      for (tk = 1; tk <= ntk; tk++) {
        if (tarr[tk] == "") continue
        key = model SUBSEP tarr[tk]
        if (key in table_has) { sum += table_val[key]; cnt++ }
      }
      if (cnt > 0) {
        key = model SUBSEP cat
        cat_avg[key] = sum / cnt
        cat_avg_has[key] = 1
      }
    }
    gsum = 0; gcnt = 0
    for (ci = 1; ci <= ncats; ci++) {
      key = model SUBSEP cat_order[ci]
      if (key in cat_avg_has) { gsum += cat_avg[key]; gcnt++ }
    }
    if (gcnt > 0) { global_avg[model] = gsum / gcnt; global_avg_has[model] = 1 }

    ok = 1; v = 0
    if ((model SUBSEP "Reasoning") in cat_avg_has) v += 0.35 * cat_avg[model SUBSEP "Reasoning"]; else ok = 0
    if ((model SUBSEP "Data Analysis") in cat_avg_has) v += 0.30 * cat_avg[model SUBSEP "Data Analysis"]; else ok = 0
    if ((model SUBSEP "Coding") in cat_avg_has) v += 0.25 * cat_avg[model SUBSEP "Coding"]; else ok = 0
    if ((model SUBSEP "IF") in cat_avg_has) v += 0.10 * cat_avg[model SUBSEP "IF"]; else ok = 0
    if (ok) { score_planner[model] = v; score_planner_has[model] = 1 }

    ok = 1; v = 0
    if ((model SUBSEP "Agentic Coding") in cat_avg_has) v += 0.45 * cat_avg[model SUBSEP "Agentic Coding"]; else ok = 0
    if ((model SUBSEP "Coding") in cat_avg_has) v += 0.35 * cat_avg[model SUBSEP "Coding"]; else ok = 0
    if ((model SUBSEP "IF") in cat_avg_has) v += 0.20 * cat_avg[model SUBSEP "IF"]; else ok = 0
    if (ok) { score_implementer[model] = v; score_implementer_has[model] = 1 }

    ok = 1; v = 0
    if ((model SUBSEP "IF") in cat_avg_has) v += 0.55 * cat_avg[model SUBSEP "IF"]; else ok = 0
    if ((model SUBSEP "Coding") in cat_avg_has) v += 0.25 * cat_avg[model SUBSEP "Coding"]; else ok = 0
    if ((model SUBSEP "Data Analysis") in cat_avg_has) v += 0.20 * cat_avg[model SUBSEP "Data Analysis"]; else ok = 0
    if (ok) { score_mechanical[model] = v; score_mechanical_has[model] = 1 }
  }

  for (mi = 1; mi <= nmodels; mi++) {
    model = models[mi]
    if (model in score_planner_has) {
      r = 1
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 in score_planner_has && score_planner[m2] > score_planner[model]) r++
      }
      rank_planner[model] = r
    }
    if (model in score_implementer_has) {
      r = 1
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 in score_implementer_has && score_implementer[m2] > score_implementer[model]) r++
      }
      rank_implementer[model] = r
    }
    if (model in score_mechanical_has) {
      r = 1
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 in score_mechanical_has && score_mechanical[m2] > score_mechanical[model]) r++
      }
      rank_mechanical[model] = r
    }

    if ((model in score_planner_has) && (model in cpst_has)) {
      dom = 0
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 == model) continue
        if (!(m2 in score_planner_has) || !(m2 in cpst_has)) continue
        if (score_planner[m2] >= score_planner[model] && cpst[m2] < cpst[model]) { dom = 1; break }
      }
      frontier_planner[model] = dom ? 0 : 1
      frontier_planner_has[model] = 1
    }
    if ((model in score_implementer_has) && (model in cpst_has)) {
      dom = 0
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 == model) continue
        if (!(m2 in score_implementer_has) || !(m2 in cpst_has)) continue
        if (score_implementer[m2] >= score_implementer[model] && cpst[m2] < cpst[model]) { dom = 1; break }
      }
      frontier_implementer[model] = dom ? 0 : 1
      frontier_implementer_has[model] = 1
    }
    if ((model in score_mechanical_has) && (model in cpq_has)) {
      dom = 0
      for (mj = 1; mj <= nmodels; mj++) {
        m2 = models[mj]
        if (m2 == model) continue
        if (!(m2 in score_mechanical_has) || !(m2 in cpq_has)) continue
        if (score_mechanical[m2] >= score_mechanical[model] && cpq[m2] < cpq[model]) { dom = 1; break }
      }
      frontier_mechanical[model] = dom ? 0 : 1
      frontier_mechanical_has[model] = 1
    }
  }

  hdr = "model,display_name,organization,open_weight,reasoner,release,global_average"
  for (ci = 1; ci <= ncats; ci++) hdr = hdr "," cat_slug[cat_order[ci]] "_average"
  hdr = hdr ",score_planner,score_implementer,score_mechanical"
  hdr = hdr ",rank_planner,rank_implementer,rank_mechanical"
  hdr = hdr ",frontier_planner,frontier_implementer,frontier_mechanical"
  hdr = hdr ",cost_per_question,cost_per_successful_task"
  hdr = hdr ",input_price_per_million,output_price_per_million"
  hdr = hdr ",avg_input_tokens,avg_output_tokens"
  for (ti = 1; ti <= ntasks; ti++) hdr = hdr ",task_" task_order[ti]
  for (ti = 1; ti <= ntasks; ti++) hdr = hdr ",questions_" task_order[ti]
  for (ti = 1; ti <= ntasks; ti++) hdr = hdr ",cost_" task_order[ti]
  for (ti = 1; ti <= ntasks; ti++) hdr = hdr ",output_tokens_" task_order[ti]
  print hdr > headerfile
  close(headerfile)

  for (mi = 1; mi <= nmodels; mi++) {
    model = models[mi]
    disp = (model in meta_disp) ? meta_disp[model] : ""
    org = (model in meta_org) ? meta_org[model] : ""
    ow = (model in meta_open) ? meta_open[model] : ""
    rs = (model in meta_reason) ? meta_reason[model] : ""
    row = csvq(model) "," csvq(disp) "," csvq(org) "," ow "," rs "," csvq(release)
    row = row "," ((model in global_avg_has) ? sprintf("%.2f", global_avg[model]) : "")
    for (ci = 1; ci <= ncats; ci++) {
      key = model SUBSEP cat_order[ci]
      row = row "," ((key in cat_avg_has) ? sprintf("%.2f", cat_avg[key]) : "")
    }
    row = row "," ((model in score_planner_has) ? sprintf("%.2f", score_planner[model]) : "")
    row = row "," ((model in score_implementer_has) ? sprintf("%.2f", score_implementer[model]) : "")
    row = row "," ((model in score_mechanical_has) ? sprintf("%.2f", score_mechanical[model]) : "")
    row = row "," ((model in rank_planner) ? sprintf("%d", rank_planner[model]) : "")
    row = row "," ((model in rank_implementer) ? sprintf("%d", rank_implementer[model]) : "")
    row = row "," ((model in rank_mechanical) ? sprintf("%d", rank_mechanical[model]) : "")
    row = row "," ((model in frontier_planner_has) ? frontier_planner[model] : "")
    row = row "," ((model in frontier_implementer_has) ? frontier_implementer[model] : "")
    row = row "," ((model in frontier_mechanical_has) ? frontier_mechanical[model] : "")
    row = row "," ((model in cpq_has) ? sprintf("%.4f", cpq[model]) : "")
    row = row "," ((model in cpst_has) ? sprintf("%.4f", cpst[model]) : "")
    row = row "," ((model in price_in_has) ? sprintf("%.4f", price_in[model]) : "")
    row = row "," ((model in price_out_has) ? sprintf("%.4f", price_out[model]) : "")
    row = row "," ((model in avg_in_has) ? sprintf("%.0f", avg_in[model]) : "")
    row = row "," ((model in avg_out_has) ? sprintf("%.0f", avg_out[model]) : "")
    for (ti = 1; ti <= ntasks; ti++) {
      key = model SUBSEP task_order[ti]
      row = row "," ((key in table_has) ? sprintf("%.3f", table_val[key]) : "")
    }
    for (ti = 1; ti <= ntasks; ti++) {
      key = model SUBSEP task_order[ti]
      row = row "," ((key in cost_q_has) ? sprintf("%.0f", cost_q[key]) : "")
    }
    for (ti = 1; ti <= ntasks; ti++) {
      key = model SUBSEP task_order[ti]
      row = row "," ((key in cost_task_has) ? sprintf("%.4f", cost_task[key]) : "")
    }
    for (ti = 1; ti <= ntasks; ti++) {
      key = model SUBSEP task_order[ti]
      row = row "," ((key in cost_out_has) ? sprintf("%.0f", cost_out[key]) : "")
    }
    print row > bodyfile
  }
  close(bodyfile)
}
AWKEOF

HEADER_CSV="$WORK/header.csv"
BODY_CSV="$WORK/body.csv"
: > "$HEADER_CSV"
: > "$BODY_CSV"

awk -f "$COMPUTE_AWK" \
  -v categories_file="$CATEGORIES_TSV" \
  -v metadata_file="$METADATA_TSV" \
  -v task_order_file="$TASK_ORDER_FILE" \
  -v release="$RELEASE" \
  -v headerfile="$HEADER_CSV" \
  -v bodyfile="$BODY_CSV" \
  "$TABLE_CSV" "$COST_CSV" \
  || fatal2 "could not compute the model map from $TABLE_CSV and $COST_CSV"

[ -s "$HEADER_CSV" ] || fatal2 "compute produced no header (see above)"

mkdir -p "$(dirname "$OUT")" || fatal2 "cannot create output directory: $(dirname "$OUT")"
FINAL="$WORK/final.csv"
{
  cat "$HEADER_CSV"
  LC_ALL=C sort "$BODY_CSV"
} > "$FINAL"
mv "$FINAL" "$OUT" || fatal2 "cannot write $OUT"

printf '%s\n' "$OUT"
exit 0
