# Stage 1: Derivation rule and tiered table

## Objective

Rewrite the closing block of `MODELS.md` → *Antigravity CLI slugs* so the table
is derived rather than asserted, and extend README rule 13 with the normative
tie-break. Both files, one commit (rule 12).

## Files

- Modify: `/home/hugo/.ai-tools/MODELS.md` — replace the closing paragraph and
  the three-identical-slug table of the *Antigravity CLI slugs* section
- Modify: `/home/hugo/.ai-tools/README.md` — extend rule 13 (line 64) with the
  derivation and tie-break

Touch nothing else. The `antigravity` map row stays `flash` for all three
categories; no wrapper, no other rule, no version line changes.

## Established facts (do not re-derive)

Verified this pass against the official pages and the repository's own AA data:

- <https://antigravity.google/docs/subagents> describes `model` only as "Model
  tier used when invoked (`inherit`, `flash`, or `pro`)" and never resolves
  `flash` or `pro` to a family + version. The CLI slug namespace *is* fully
  resolved. That asymmetry is why the annotation is legitimate where the map cell
  is not — keep it visible in the wording.
- <https://antigravity.google/docs/cli/headless> confirms `agy models`,
  `--effort low|medium|high`, and a non-zero exit on an unknown slug.
- `/home/hugo/.ai-tools/dev/wip/models-reasoning.md`, section `antigravity`, is
  the selection pass behind the row. It selected **Gemini 3.7 Flash · medium**
  for planner, **· medium** for implementer, and **· low** for mechanical.
  Planner and implementer are the collision; mechanical was already `low`.
- Same file and `/home/hugo/.ai-tools/dev/wip/csv/artificialanalysis-models.csv`:
  Gemini 3.7 Flash has a complete AA row (Intelligence Index, Cost per Task, Time
  per Task, all numeric and > 0) at `high`, `medium`, and `low`. Gemini 3.6 Flash
  is measured at `high` only. Gemini 3.5 Flash is complete at `high` only
  (its `medium` row has an Intelligence Index but no Cost or Time).
- Antigravity publishes no per-token price and no per-model quota multiplier.
  **The annotation states no cost or quota figure**, and no AA number.

## Steps

1. In `/home/hugo/.ai-tools/MODELS.md`, replace this exact block — the last
   paragraph and table of the file:

   ```markdown
   The three agents map to the `flash` tier the map pins, at the family's documented default reasoning tier:

   | Agent | `agy --model` |
   |---|---|
   | planner-ai-tools | `gemini-3.7-flash-medium` |
   | implementer-ai-tools | `gemini-3.7-flash-medium` |
   | mechanical-ai-tools | `gemini-3.7-flash-medium` |
   ```

   with exactly:

   ```markdown
   The map cell cannot carry a reasoning tier; the slug bakes one in, so the differentiation lives here. Rule 13's derivation, in three steps:

   1. **Resolve** each category from the `antigravity` row and the selection pass behind it ([Choosing the models](README.md#choosing-the-models)).
   2. **Translate** the resolved family + version and reasoning tier into the slug that names them.
   3. **Tie-break** repeats: the implementer's slug is the base, the planner moves one published tier up and the mechanical one down; with no tier above or below, that category repeats the base.

   The current pass selected Gemini 3.7 Flash at `medium` for planner and implementer alike, and at `low` for mechanical. Planner and implementer collide, so `gemini-3.7-flash-medium` is the base: the planner rises to `high` and the mechanical falls to `low` — the tier that pass had already chosen for it.

   3.7 over 3.6 and 3.5: it is the newest Flash and the only one with a complete AA row — Intelligence Index, Cost per Task, Time per Task — at all three tiers; 3.6 and 3.5 are measured at `high` alone. Antigravity publishes no per-token price and no per-model quota multiplier, its plans page tying rate limits only to the amount of work the agent does, so this table orders published reasoning tiers and claims no cost or quota figure.

   | Agent | `agy --model` |
   |---|---|
   | planner-ai-tools | `gemini-3.7-flash-high` |
   | implementer-ai-tools | `gemini-3.7-flash-medium` |
   | mechanical-ai-tools | `gemini-3.7-flash-low` |
   ```

2. In `/home/hugo/.ai-tools/README.md`, rule 13 (line 64), insert the derivation
   between the existing sentences. After `A skill invoking such a CLI takes
   `--model` from the annotation.` and before `Today: Antigravity, …`, insert:

   > Derive each row: resolve the category from that harness's map row and the selection pass behind it, then translate the resolved family + version and reasoning tier into the CLI's slug. When two or more categories land on the same slug, the **implementer's** is the base — the planner moves one reasoning tier up and the mechanical one tier down, within the tiers that CLI publishes for the family; with no tier above or below, that category repeats the base.

   Leave the rest of rule 13, its number, and every neighbouring rule untouched.

3. Run `/home/hugo/.ai-tools/tools/lint.sh` and record its exit code and any
   finding lines in the Implementation log.

## Tests

No unit or integration suite covers documentation. The verification is
`tools/lint.sh`, which checks `MODELS.md`/wrapper parity — the map row is
unchanged, so its findings must be identical to the pre-change run. Capture both
runs and compare:

```bash
git stash list >/dev/null
/home/hugo/.ai-tools/tools/lint.sh 2>&1 | grep -i 'warn\|fail' | sort > /tmp/lint-after.txt
```

Compare against a baseline taken before the edit; any new line is a failure.

## Acceptance criteria

- [ ] `MODELS.md` states the three derivation steps, with the tie-break naming
      the implementer's slug as the base, the planner up, the mechanical down,
      and the repeat-the-base fallback.
- [ ] `MODELS.md` justifies 3.7 over 3.6/3.5 by newest Flash + the only complete
      AA row at all three tiers.
- [ ] The annotation table reads `gemini-3.7-flash-high`, `-medium`, `-low`.
- [ ] The annotation carries no cost figure, no quota figure, and no AA number.
- [ ] README rule 13 states the tie-break normatively; rule numbering unchanged.
- [ ] The `antigravity` map row still reads `flash` in all three columns.
- [ ] The README version line is unchanged.
- [ ] `tools/lint.sh` produces no finding absent from the pre-change baseline.
- [ ] No file other than `MODELS.md` and `README.md` is modified.

## Commit

Path-scoped to `MODELS.md` and `README.md` (the tree is dirty elsewhere — never
`git add -A`).

Suggested message: `docs: derive Antigravity CLI slugs per category`

## Dependencies

- Requires stages: none
- Parallel-safe with: none (only stage)

## Implementation log

- Pre-change `tools/lint.sh` run: exit 0, `done: 350 ok, 1 skipped, 0 warnings`.
- Replaced the MODELS.md closing paragraph+table exactly per Steps 1 (verified old-text match before editing); inserted the rule 13 tie-break sentence exactly per Step 2 (verified old-text match before editing). `git diff -- MODELS.md README.md` confirms each edit is localized to its named block; the rest of both files' diffs (version bump 0.0.27→0.0.28, rule renumbering 13→28, the already-added "Antigravity CLI slugs" intro/slug-list content) predates this stage — it was already uncommitted in the working tree at dispatch (`git status --porcelain` before any edit showed both files already `M`).
- Post-change `git status --porcelain`: only `MODELS.md` and `README.md` gained further changes; the thirteen unrelated files remain exactly as they were, `dev/` stays untracked.
- Post-change `tools/lint.sh` run: exit 0, `done: 350 ok, 1 skipped, 0 warnings` — identical to the pre-change baseline, no new finding.
- `antigravity` map row in MODELS.md still reads `flash | flash | flash` (unchanged, confirmed via diff — no `-` lines in that row).
- README version line (`0.0.28-ALPHA`) and rule numbering: not touched by this stage's edit (present unchanged before and after the Step 2 edit); rule 13 is the only rule whose body text changed.


## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | V | implementer-ai-tools | sonnet | 9ec29701-e8ed-4acd-bf59-202ce1123482 | accepted — every acceptance criterion verified against the diff by planner-ai-tools |

## Validation (planner-ai-tools)

Verified against the working-tree diff, not the implementer's report:

- `git status --porcelain`: only `MODELS.md` and `README.md` carry this stage's
  edits; the thirteen pre-existing dirty files are untouched.
- `git diff --stat`: `README.md` still shows 85 changed lines, identical to the
  pre-change count — the rule 13 sentence was inserted into a line already part
  of the pre-existing hunk, so no new README hunk appeared. `MODELS.md` grew from
  19 to 27 added lines, matching the new derivation prose exactly.
- README rules run 1..28 unbroken; rule 13 keeps its number and its original two
  sentences, with the derivation and tie-break inserted between them.
- MODELS.md map row 21 still reads `| `antigravity` | Google Antigravity |
  `flash` | `flash` | `flash` |`.
- README version line unchanged at `0.0.28-ALPHA`.
- Annotation table reads `gemini-3.7-flash-high` / `-medium` / `-low`; the prose
  carries no cost figure, no quota figure, and no AA number.
- `tools/lint.sh`: exit 0, `done: 350 ok, 1 skipped, 0 warnings` — identical to
  the pre-change baseline.

Verdict: **F**.
