# shellcheck shell=bash
# models.sh case file — proves tools/models.sh against a small synthetic
# LiveBench release under tools/test/fixtures/livebench/. Unlike the
# install/remove/update cases, tools/models.sh never touches $HOME, so
# these cases run it directly (no t_fixture sandbox) and only ever write to
# a disposable --out path under ${TMPDIR:-/tmp}.
#
# Fixtures (tools/test/fixtures/livebench/):
#   base/            5 models (model-a..model-e), 7 categories named exactly
#                    as the score formulas need (Reasoning, Coding, Agentic
#                    Coding, Mathematics, Data Analysis, Language, IF).
#                    model-b has a blank task cell (c2); model-e has a
#                    table.csv row but no row at all in cost.csv. No
#                    bundle.js.
#   missing-agentic/ same table.csv/cost.csv, categories.json without
#                    "Agentic Coding".
#   with-bundle/     same table.csv/cost.csv/categories.json, plus a
#                    bundle.js carrying model metadata (one model with two
#                    variants) and a decoy single-quoted string with an
#                    embedded double quote, to prove the metadata scanner
#                    does not desync on it.
#
# model-a's category averages, global average, and all three scores are
# hand-computed below and asserted as exact strings.

MODELS_FIXTURES="$AI_TOOLS/tools/test/fixtures/livebench"

MODELS_HEADER="model,display_name,organization,open_weight,reasoner,release,global_average,reasoning_average,coding_average,agentic_coding_average,mathematics_average,data_analysis_average,language_average,if_average,score_planner,score_implementer,score_mechanical,rank_planner,rank_implementer,rank_mechanical,frontier_planner,frontier_implementer,frontier_mechanical,cost_per_question,cost_per_successful_task,input_price_per_million,output_price_per_million,avg_input_tokens,avg_output_tokens,task_a1,task_c1,task_c2,task_d1,task_i1,task_i2,task_l1,task_m1,task_r1,task_r2,questions_a1,questions_c1,questions_c2,questions_d1,questions_i1,questions_i2,questions_l1,questions_m1,questions_r1,questions_r2,cost_a1,cost_c1,cost_c2,cost_d1,cost_i1,cost_i2,cost_l1,cost_m1,cost_r1,cost_r2,output_tokens_a1,output_tokens_c1,output_tokens_c2,output_tokens_d1,output_tokens_i1,output_tokens_i2,output_tokens_l1,output_tokens_m1,output_tokens_r1,output_tokens_r2"

# model-a: r1=80,r2=90 -> reasoning 85.00; c1=70,c2=90 -> coding 80.00;
# a1=60 -> agentic 60.00; m1=50 -> mathematics 50.00; d1=40 -> data
# analysis 40.00; l1=30 -> language 30.00; i1=20,i2=40 -> if 30.00.
# global_average = (85+80+60+50+40+30+30)/7 = 53.571... -> 53.57
# score_planner     = .35*85 + .30*40 + .25*80 + .10*30 = 64.75
# score_implementer = .45*60 + .35*80 + .20*30           = 61.00
# score_mechanical  = .55*30 + .25*80 + .20*40           = 44.50
MODELS_ROW_A="model-a,,,,,2024-01-01,53.57,85.00,80.00,60.00,50.00,40.00,30.00,30.00,64.75,61.00,44.50,2,2,2,1,1,1,0.0100,0.0150,1.0000,3.0000,1000,200,60.000,70.000,90.000,40.000,20.000,40.000,30.000,50.000,80.000,90.000,14,12,13,16,18,19,17,15,10,11,0.0140,0.0120,0.0130,0.0160,0.0180,0.0190,0.0170,0.0150,0.0100,0.0110,140,120,130,160,180,190,170,150,100,110"

t_models_run() {
  # usage: t_models_run [args...] -- runs tools/models.sh directly (no
  # $HOME sandbox needed: the script only reads --offline/network sources
  # and writes --out). Sets T_LAST_EXIT / T_LAST_OUTPUT (stdout+stderr).
  local out
  out=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-out.XXXXXX") || fatal "t_models_run: mktemp failed"
  "$AI_TOOLS/tools/models.sh" "$@" >"$out" 2>&1
  # shellcheck disable=SC2034 # read by tools/test/lib.sh's t_assert_exit/t_assert_line, a separate sourcing script
  T_LAST_EXIT=$?
  # shellcheck disable=SC2034 # read by tools/test/lib.sh's t_assert_exit/t_assert_line, a separate sourcing script
  T_LAST_OUTPUT=$(cat "$out")
  rm -f "$out"
}

case_models_offline_happy_path() {
  local csv
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv" --quiet
  t_assert_exit 0

  if [ -f "$csv" ]; then
    ok "$T_CASE: CSV written: $csv"
    if [ "$(head -n 1 "$csv")" = "$MODELS_HEADER" ]; then
      ok "$T_CASE: header matches the spec column order exactly"
    else
      warn "$T_CASE: header does not match the spec column order"
    fi
  else
    warn "$T_CASE: CSV not written: $csv"
  fi

  rm -f "$csv"
}

case_models_hand_computed_scores() {
  local csv row
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv" --quiet
  t_assert_exit 0

  row=$(grep '^model-a,' "$csv" 2>/dev/null || true)
  if [ "$row" = "$MODELS_ROW_A" ]; then
    ok "$T_CASE: model-a row matches hand-computed averages/scores exactly"
  else
    warn "$T_CASE: model-a row mismatch"
    warn "$T_CASE: want: $MODELS_ROW_A"
    warn "$T_CASE: got:  $row"
  fi

  rm -f "$csv"
}

case_models_deterministic_rerun() {
  local csv1 csv2
  csv1=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  csv2=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv1" "$csv2"

  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv1" --quiet
  t_assert_exit 0
  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv2" --quiet
  t_assert_exit 0

  if [ -f "$csv1" ] && [ -f "$csv2" ] && cmp -s "$csv1" "$csv2"; then
    ok "$T_CASE: two runs produce byte-identical CSVs"
  else
    warn "$T_CASE: two runs produced different CSVs"
  fi

  rm -f "$csv1" "$csv2"
}

case_models_missing_formula_category() {
  local csv
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/missing-agentic" --release 2024-01-01 --out "$csv" --quiet
  t_assert_exit 2
  t_assert_line "Agentic Coding"

  if [ -f "$csv" ]; then
    warn "$T_CASE: CSV unexpectedly written despite the missing category: $csv"
  else
    ok "$T_CASE: no CSV written"
  fi

  rm -f "$csv"
}

case_models_cost_absent_model() {
  local csv row
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv" --quiet
  t_assert_exit 0

  row=$(grep '^model-e,' "$csv" 2>/dev/null || true)
  if [ -z "$row" ]; then
    warn "$T_CASE: model-e row not found"
  else
    # Columns 21-25: frontier_planner, frontier_implementer,
    # frontier_mechanical, cost_per_question, cost_per_successful_task --
    # all must be empty for a model absent from cost.csv.
    if printf '%s\n' "$row" | awk -F, '{exit !($21=="" && $22=="" && $23=="" && $24=="" && $25=="")}'; then
      ok "$T_CASE: model-e cost/frontier cells are empty"
    else
      warn "$T_CASE: model-e cost/frontier cells are not all empty: $row"
    fi
  fi

  rm -f "$csv"
}

case_models_offline_without_bundle() {
  local csv row
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/base" --release 2024-01-01 --out "$csv"
  t_assert_exit 0
  t_assert_line "WARN:"

  row=$(grep '^model-a,' "$csv" 2>/dev/null || true)
  if printf '%s\n' "$row" | awk -F, '{exit !($2=="" && $3=="" && $4=="" && $5=="")}'; then
    ok "$T_CASE: metadata columns (display_name/organization/open_weight/reasoner) are empty"
  else
    warn "$T_CASE: metadata columns not empty despite no bundle.js: $row"
  fi

  rm -f "$csv"
}

case_models_bundle_metadata_parsed() {
  local csv row
  csv=$(mktemp "${TMPDIR:-/tmp}/ai-tools-test-models.XXXXXX.csv") || fatal "$T_CASE: mktemp failed"
  rm -f "$csv"

  t_models_run --offline "$MODELS_FIXTURES/with-bundle" --release 2024-01-01 --out "$csv" --quiet
  t_assert_exit 0

  row=$(grep '^model-b,' "$csv" 2>/dev/null || true)
  if printf '%s\n' "$row" | awk -F, '{exit !($2=="Model B" && $3=="Acme" && $4=="false" && $5=="true")}'; then
    ok "$T_CASE: model-b metadata parsed from bundle.js (survives the decoy quote)"
  else
    warn "$T_CASE: model-b metadata not parsed as expected: $row"
  fi
}

case_models_bad_flag() {
  t_models_run --nope
  t_assert_exit 1

  t_models_run --offline "$MODELS_FIXTURES/base"
  t_assert_exit 1
  t_assert_line "requires --release"
}
