# Stage 1: Green lint baseline

## Objective

`scripts/lint.sh` exits 0 on the untouched `USER-AGENTS.md`. On master it exits 2 with six warnings:

- `<skill_question>`, `<skill_options>`, and `<default>` are structural tags missing from `XML_VOCAB`.
- The compound reference `` `<session_workflow> <step>` `` is parsed as one malformed attribute reference.

This stage changes lint and the README vocabulary table only. `USER-AGENTS.md` and `skills/` stay byte-identical.

## Files

- Create: none
- Modify:
  - `scripts/lint.sh`: `XML_VOCAB` and `xml_references`
  - `README.md`: the vocabulary table in "Semantic XML grammar" only. The README requires a new tag to be registered in the table and in `XML_VOCAB` in the same commit.
- Remove: none

## Steps

1. In `scripts/lint.sh`, append `skill_question skill_options default` to `XML_VOCAB` (keep one space-separated line).
2. In `scripts/lint.sh` `xml_references`, split a backticked span holding several tags into one reference per tag. After `ref` and `q` are computed inside the awk loop, replace `print q "|" ref` with:

   ```awk
   n = split(ref, parts, /> +</)
   for (i = 1; i <= n; i++) print q "|" parts[i]
   ```

   `` `<session_workflow> <step>` `` then yields `session_workflow` and `step`, both bare vocabulary references. Single-tag spans are unchanged (`n == 1`).
3. In `README.md` "Semantic XML grammar", vocabulary table:
   - Replace the row `` `<skill_offer>`, `<offer_message>`, `<handling>` / `<response type>` `` with `` `<skill_offer>`, `<offer_message>`, `<skill_question>`, `<skill_options>`, `<handling>` / `<response type>` ``, meaning "the gate, its chat message, question, and option templates, and its answers".
   - Replace the row `` `<fallback>` `` with `` `<default>`, `<fallback>` ``, meaning "native-tool question rule and its chat fallback".
4. Leave everything else untouched: no version bump (stage 5) and no other README text.

## Tests

- `scripts/lint.sh; echo $?` prints `0`, with `done: ... 0 warnings`.
- The lint output contains `ok: reference names a vocabulary tag: <session_workflow> in .../USER-AGENTS.md` and `ok: reference names a vocabulary tag: <step> in .../USER-AGENTS.md`.
- Negative probe in a disposable worktree:
  1. `wt=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-lint.XXXXXX"); git worktree add -q "$wt/t" HEAD`
  2. Append the line `` See `<bogus_tag> <step>`. `` inside `<skill_offer>` of `$wt/t/USER-AGENTS.md`.
  3. `"$wt/t/scripts/lint.sh"` exits 2 with `reference to a tag outside the vocabulary <bogus_tag>`.
  4. Clean up with `git worktree remove --force "$wt/t"`.
- `scripts/test.sh` exits 0.
- The CI shellcheck command reports only the pre-existing `SC1071` on `scripts/shell/install-zsh.sh`.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds.

## Acceptance criteria

- [ ] `scripts/lint.sh` exits 0 on the working tree
- [ ] `XML_VOCAB` and the README vocabulary table both register `skill_question`, `skill_options`, and `default`
- [ ] Compound backticked references resolve tag by tag; single-tag references behave as before
- [ ] `scripts/test.sh` exits 0; shellcheck shows no new finding
- [ ] `skills/` and `USER-AGENTS.md` unchanged

## Commit message

`fix(lint): register USER-AGENTS gate tags and split compound references`

## Dependencies

- Requires stages: none

## Implementation log

- Edited `scripts/lint.sh`:
  - Appended `skill_question skill_options default` to `XML_VOCAB` (line 808).
  - In `xml_references` (awk block), replaced `print q "|" ref` with a `split(ref, parts, /> +</)` loop that prints one `q "|" parts[i]` line per tag, so a compound backticked span like `` `<session_workflow> <step>` `` yields two bare references instead of one malformed one.
- Edited `README.md` "Semantic XML grammar" vocabulary table (two rows only):
  - `` `<skill_offer>`, `<offer_message>`, `<handling>` / `<response type>` `` → `` `<skill_offer>`, `<offer_message>`, `<skill_question>`, `<skill_options>`, `<handling>` / `<response type>` ``.
  - `` `<fallback>` `` → `` `<default>`, `<fallback>` ``.
- Commands run (all from repo root, working tree with the above edits, nothing committed):
  - `./scripts/lint.sh; echo $?` → exit `0`, `done: 567 ok, 1 skipped, 0 warnings` (the 1 skip is the pre-existing version-bump SKIP without `--base`). Output includes `ok: reference names a vocabulary tag: <session_workflow> in .../USER-AGENTS.md` and `ok: reference names a vocabulary tag: <step> in .../USER-AGENTS.md`, and no warnings at all.
  - `./scripts/test.sh` → exit `0`, `done: 361 ok, 0 skipped, 0 warnings`.
  - `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` → exit `1`, single finding `SC1071` on `scripts/shell/install-zsh.sh` only (pre-existing, matches the documented baseline).
  - `git diff --quiet master -- skills USER-AGENTS.md; echo $?` → `0` (both byte-identical to master).
  - Negative probe: `wt=$(mktemp -d ...); git worktree add -q "$wt/t" HEAD`. Note: `HEAD` checks out the last *commit*, not this uncommitted working-tree fix, so the freshly created worktree initially held the old (unfixed) `lint.sh`. Copied the working tree's fixed `scripts/lint.sh` into `$wt/t/scripts/lint.sh` to exercise the actual fix, then appended `` See `<bogus_tag> <step>`. `` inside `<skill_offer>` of `$wt/t/USER-AGENTS.md`. Ran `$wt/t/scripts/lint.sh`: exit `2`, with `WARN: reference to a tag outside the vocabulary <bogus_tag> in $wt/t/USER-AGENTS.md` and no error for `<step>` (correctly resolved as in-vocabulary). Cleaned up with `git worktree remove --force "$wt/t"` and removed the temp dir; `git worktree list` afterward shows no leftover entry.
- `skills/` and `USER-AGENTS.md` left byte-identical to master throughout (verified above).
- Set Status row 1 to `V` in `dev/remove-agents/0-remove-agents.md`.
