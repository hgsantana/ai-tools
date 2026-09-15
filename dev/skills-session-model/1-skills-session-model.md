# Stage 1: Delete models-ai-tools

## Objective

Remove `skills/models-ai-tools`. Its whole purpose (`MODELS.csv`, wrapper pins, `scripts/harness-models.sh`, `scripts/aa-metrics.sh`) was deleted by `plan/remove-agents`, and implementer models are now chosen at runtime. Remove every enumeration of the skill and of its skill-only protocol tag `<selection_method>`.

## Files

- Create: none
- Modify:
  - `scripts/lint.sh`: the `maintainer` list in `check_skill_layout`, and `XML_VOCAB`
  - `README.md`: rule 5 (optional-blocks list) and the Semantic XML grammar vocabulary table
- Remove:
  - `skills/models-ai-tools/SKILL.md` (the whole `skills/models-ai-tools/` directory)

## Steps

1. `git rm -r skills/models-ai-tools`.
2. `scripts/lint.sh`, `check_skill_layout`: change `local maintainer="update-ai-tools remove-ai-tools models-ai-tools"` to `local maintainer="update-ai-tools remove-ai-tools"`.
3. `scripts/lint.sh`, `XML_VOCAB`: delete the word `selection_method`. Keep the rest of the single space-separated line unchanged.
4. `README.md` rule 5: change "Optional blocks `<status_protocol>`, `<return_protocol>`, `<selection_method>`, and `<plan_file_format>` hold protocol…" to "Optional blocks `<status_protocol>`, `<return_protocol>`, and `<plan_file_format>` hold protocol…".
5. `README.md` vocabulary table: change the row `` `<selection_method>`, `<plan_file_format>` / `<structure>` `` to `` `<plan_file_format>` / `<structure>` ``. Keep the meaning "skill-specific protocol".
6. Change nothing else: no version bump (stage 7), and `docs/USAGE.md` already omits the skill.

## Tests

- `scripts/lint.sh; echo $?` prints `0`, and the output contains no `models-ai-tools` line.
- `scripts/test.sh; echo $?` prints `0`. Install and verify cases loop over `skills/*-ai-tools`, and no case names the deleted skill.
- `git grep -nE 'models-ai-tools|selection_method' -- . ':!dev'` prints nothing.
- `test ! -e skills/models-ai-tools`.
- The CI shellcheck command reports only the known `SC1071`.
- `git diff --quiet HEAD -- USER-AGENTS.md scripts/shell scripts/test` succeeds.

## Acceptance criteria

- [ ] `skills/models-ai-tools/` no longer exists in the tree or the index
- [ ] `scripts/lint.sh` no longer lists the skill or registers `selection_method`
- [ ] README rule 5 and the vocabulary table no longer name `<selection_method>`
- [ ] lint and test exit 0; shellcheck shows no new finding

## Commit message

`refactor(skills)!: delete models-ai-tools`

## Dependencies

- Requires stages: none

## Implementation log

- `git rm -r skills/models-ai-tools` was already staged by a prior attempt (`D  skills/models-ai-tools/SKILL.md`, the only file in that directory). Verified `test ! -e skills/models-ai-tools` passes — directory absent from tree and index.
- `scripts/lint.sh` `check_skill_layout`: `maintainer` list was already reduced to `"update-ai-tools remove-ai-tools"` by the prior attempt — verified against Step 2, correct, no change needed.
- `scripts/lint.sh` `XML_VOCAB`: `selection_method` was already removed from the space-separated line by the prior attempt — verified against Step 3, correct, no change needed.
- `README.md` rule 5: already updated to drop `<selection_method>` from the optional-blocks sentence — verified against Step 4, correct, no change needed.
- `README.md` vocabulary table: already updated, row now reads `` `<plan_file_format>` / `<structure>` `` — verified against Step 5, correct, no change needed.
- No production edits were needed this pass: the prior attempt's changes to `scripts/lint.sh` and `README.md` matched the Steps exactly. Only verification, this log, and the base-plan Status update were performed here.
- `grep -rnE 'models-ai-tools|selection_method' --exclude-dir=dev --exclude-dir=.git .` — exit 1 (no matches).
- `scripts/lint.sh; echo $?` — exit 0, `316 ok, 1 skipped, 0 warnings` (skip is the version-bump check, expected without `--base`); no `models-ai-tools` line in output.
- `scripts/test.sh; echo $?` — exit 0, `305 ok, 0 skipped, 0 warnings`; no case names `models-ai-tools`.
- `test ! -e skills/models-ai-tools` — passes (absent).
- `git diff --quiet HEAD -- USER-AGENTS.md scripts/shell scripts/test; echo $?` — exit 0 (no changes to those paths).
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` — reports only the known `SC1071` on `scripts/shell/install-zsh.sh` (pre-existing, not a regression).
- Note for the parent: the working tree also carries unrelated, in-progress edits to `skills/az-ai-tools/SKILL.md`, `skills/dev-ai-tools/SKILL.md`, `skills/gc-ai-tools/SKILL.md`, `skills/gh-ai-tools/SKILL.md`, and `skills/update-ai-tools/SKILL.md` from concurrent stage work (stages 2/3). None of these are stage 1's scope and none were touched here; the lint/test runs above already reflect their current state and pass cleanly.
