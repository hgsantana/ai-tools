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
