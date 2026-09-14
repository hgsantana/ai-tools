# Stage 4: Delete agent sources

## Objective

Delete the files that exist only for agents:

- agent bases and the subagent contract
- every harness wrapper folder
- the wrapper templates
- `MODELS.csv`
- the model-fetch scripts

Clone validation stops requiring `MODELS.csv` and `agents/`. The README sections that define these files (Contents rows, the `MODELS.csv` overview paragraph, "Model selection and wrapper authoring", and the session-model table) are removed in the same commit.

## Files

- Create: none
- Modify:
  - `scripts/shell/lib.sh`: `ensure_clone` and `require_clone` only
  - `README.md`: Overview `MODELS.csv` paragraph; Contents table; the "Model selection and wrapper authoring" section with all its subsections; the "Change the session model" table and its intro line
- Remove:
  - `agents/`: `SUBAGENT-CONTRACT.md`, `planner-ai-tools.md`, `implementer-ai-tools.md`, `mechanical-ai-tools.md`, and `antigravity/`, `claude-code/`, `codex/`, `copilot/`, `cursor/`, `grok/`
  - `templates/`: only `templates/wrappers/` (`README.md`, `antigravity.md`, `claude-code.md`, `codex.toml`, `copilot.agent.md`, `cursor.md`, `grok.md`)
  - `MODELS.csv`
  - `scripts/aa-metrics.sh`
  - `scripts/harness-models.sh`

## Steps

1. `git rm -r agents templates MODELS.csv scripts/aa-metrics.sh scripts/harness-models.sh`.
2. `scripts/shell/lib.sh` `ensure_clone`: the validation becomes `{ [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/skills" ]; }`. Keep the fatal message verbatim; `case_install_not_a_clone` asserts it.
3. `scripts/shell/lib.sh` `require_clone`: `{ [ -d "$AI_TOOLS/.git" ] && [ -f "$AI_TOOLS/USER-AGENTS.md" ] && [ -d "$AI_TOOLS/skills" ]; }`. Keep the fatal message verbatim; `case_verify_no_clone`, `case_update_missing_clone`, and `case_reinstall_fresh_clone_offline` assert it.
4. `README.md` Overview: delete the paragraph that starts "[`MODELS.csv`](MODELS.csv) is a CSV of model and effort pins…".
5. `README.md` Contents table:
   - Delete the rows for `MODELS.csv`, `agents/planner-ai-tools.md`, `agents/implementer-ai-tools.md`, `agents/mechanical-ai-tools.md`, `agents/SUBAGENT-CONTRACT.md`, and `agents/<harness>/`.
   - The `scripts/` row becomes: "`scripts/shell/` install processes ([Scripts](#scripts); rules 25–28); `lint.sh`, `test.sh` ([Development checks](#development-checks)). Windows: WSL or Git Bash".
6. `README.md`: delete the whole "### Model selection and wrapper authoring" section, including "MODELS.csv format", "Refreshing the models", the canonical wrapper body, and "Wrapper templates and frontmatter standards". That last subsection ends with the paragraph "A skill carries frontmatter (rule 9)…"; delete it too, since rule 7 already states it.
7. `README.md` "Supported harnesses": delete the line "Change the session model (not the wrapper pin):" and the table below it.
8. Leave the rule list (rules 5, 6, 8, 10–13 and the citations of them) for stage 5.

## Tests

- `test ! -e agents && test ! -e templates && test ! -e MODELS.csv && test ! -e scripts/aa-metrics.sh && test ! -e scripts/harness-models.sh` succeeds.
- `git grep -nE 'MODELS\.csv|agents/|templates/wrappers|aa-metrics|harness-models|SUBAGENT-CONTRACT' -- scripts .github .gitattributes` prints nothing.
- `scripts/test.sh` exits 0. The fixture origin is built from the working tree, so it no longer contains the deleted files. This covers the not-a-clone, missing-clone, and bootstrap paths.
- `scripts/lint.sh` exits 0.
- The CI shellcheck command reports only the pre-existing `SC1071`. `scripts/*.sh` now matches only `lint.sh` and `test.sh`.
- `grep -n 'model-selection-and-wrapper-authoring\|#models\|MODELS.csv' README.md` prints only rule-list lines (rules 11, 12, 13 and their citations), which stage 5 removes.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds.

## Acceptance criteria

- [ ] `agents/`, `templates/`, `MODELS.csv`, `scripts/aa-metrics.sh`, and `scripts/harness-models.sh` are gone from the tree
- [ ] A clone validates with `USER-AGENTS.md` and `skills/` (plus `.git` for `require_clone`); failure messages unchanged
- [ ] README has no Contents row, overview paragraph, section, or table for `MODELS.csv`, agent bases, the contract, wrappers, wrapper templates, or session-model changes
- [ ] `scripts/test.sh` and `scripts/lint.sh` exit 0; shellcheck shows no new finding
- [ ] `skills/` (including the now-broken `skills/models-ai-tools`) and `USER-AGENTS.md` unchanged

## Commit message

`refactor!: delete agent bases, wrappers, and model tooling`

## Dependencies

- Requires stages: 3

## Implementation log
