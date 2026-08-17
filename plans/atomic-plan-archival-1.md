# Stage 1: Orchestrator lifecycle

## Objective

`agents/orchestrator-ai-tools.md` states the new lifecycle exactly once, in a new `## Plan archival` section, and every other mention of archival in the file becomes a cross-reference to it. No per-stage or mid-run move survives. Reentry, refusal, branch reuse and the never-scan-the-archive invariant are deterministic and clock-free.

## Files

- Modify: `agents/orchestrator-ai-tools.md` — the only file this stage touches; it is where the orchestrator's behaviour lives (README rule 5)

Do not touch `agents/<harness>/**` (README rule 6), `scripts/**`, `skills/**`, `.gitignore`, or any other agent base file.

## Steps

Apply the eight edits below verbatim. Nothing else in the file changes; in particular, leave the *Context isolation* line "Implementers must not open other stage files, base plans, or `plans/finished/**`" exactly as it is — it stays true.

### 1. Routing — add the reentry input

In the `## Routing` table, insert one row between the `plans/<file>.md …` row and the `Anything else` row:

```markdown
| An archived slug, or `plans/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
```

### 2. Branch per plan — reuse the branch on reentry

In `## Branch per plan`, insert a bullet immediately after the bullet beginning "One branch per base plan" and before the "Mode B: same rule per brief" bullet:

```markdown
- A reentered plan (*Plan archival*) reuses its existing `plan/<slug>` branch, which carries the work already accepted; cut a new one only when it is absent.
```

### 3. Plan intake — the whole set is under `plans/`

Replace the line:

> Before dispatching a plan, load its base file and all stage files (`plans/<slug>-*.md` and `plans/finished/<slug>-*.md`) in full.

with:

> Before dispatching a plan, load its base file and every stage and fix file of that plan (`plans/<slug>-*.md`) in full — the whole set is under `plans/` (*Plan archival*).

### 4. Planner obligations — remove the per-stage moves

Three bullets in `### Planner obligations` change; the rest of the list is untouched.

Replace:

> - **On pass (`F`)**: move `plans/<slug>-<n>.md` and associated `plans/<slug>-F*.md` fix files to `plans/finished/`; commit if the stage defines a commit boundary.

with:

> - **On pass (`F`)**: commit if the stage defines a commit boundary; no file moves (*Plan archival*).

Replace:

> - **On 3 failed corrections (`E`)**: set `E`, append a failure report to the stage file, move fix files to `plans/finished/`, and proceed with independent stages.

with:

> - **On 3 failed corrections (`E`)**: set `E`, append a failure report to the stage file, and proceed with independent stages.

Replace:

> - When all stages reach `F`/`E`, move the base plan to `plans/finished/`.

with:

> - When all stages reach `F`/`E`, archive the set (*Plan archival*).

### 5. New section `## Plan archival`

Insert it after the `## Status protocol` section (that is, after the last `### Planner obligations` bullet) and before `## Mode A — plan queue`, verbatim:

```markdown
## Plan archival

A plan's **set** is its base plan `plans/<slug>.md` plus every `plans/<slug>-*.md` stage and fix file. The set is one unit and travels as one: it is created under `plans/` and every file of it stays there, whatever its status, until the plan is over. Never move a file of a plan while any stage of that plan is non-terminal. Terminal is `F` or `E`.

- **Archive** when every stage row of the base plan reads `F` or `E` — with or without failures — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and it must never find its file moved. Move the whole set in one operation into `plans/finished/<slug>/`; nothing of that plan is left under `plans/`.
- The moved files are versioned while `plans/finished/` is ignored, so the move is a tracked deletion: commit it path-scoped as `chore(plans): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean.
- **The queue never reads the archive.** `plans/finished/**` is never scanned, globbed, or listed as a source of work (Mode A step 2). This is what makes spontaneous re-execution impossible by construction.
- **Reentry** happens only on a dispatch naming an archived plan by slug or path, and resolves to exactly `plans/finished/<slug>/<slug>.md`; anything else is not an archived set — report it and touch nothing. Read that base plan's stage table:
  - at least one `E` → move the whole set back into `plans/` intact, commit the restore as `chore(plans): reopen <slug>`, then run it as a normal Mode A plan;
  - every stage `F` → the set is final: refuse, touch nothing, and report the refusal. Refuse the same way when `plans/<slug>.md` already exists — never merge two sets under one slug.
- On reentry, `F` stages keep their status and are never re-run; only `E` stages execute. Each re-enters the status protocol at `W` with a fresh 1 + 3 correction budget, its Dispatch log continuing the existing attempt counter.
```

### 6. Mode A step 6

Replace:

> 6. Move fully resolved base plans to `plans/finished/`. Return the final summary, including one PR approval request or local review request per completed plan branch.

with:

> 6. Archive every resolved plan (*Plan archival*). Return the final summary, including one PR approval request or local review request per completed plan branch.

### 7. Validation — a pass moves nothing

In `## Validation`, replace item 6:

> 6. Pass → `F`, move files, commit. Fail → `R1` tasks or `R2+` fix files.

with:

> 6. Pass → `F`, commit. Fail → `R1` tasks or `R2+` fix files.

### 8. Final summary — report the archive and the refusals

In `## Final summary`, replace the closing sentence:

> Close with: final status counts (`F`/`E`), paths of moved plan files and commits created, everything awaiting user approval, and for each `E` its cause and the remediation the user must decide on.

with:

> Close with: final status counts (`F`/`E`), each plan's archive directory and the commits created, everything awaiting user approval, every refused reentry with its reason, and for each `E` its cause and the remediation the user must decide on.

## Tests

This repository ships prose artifacts and has no test suite; verification is command output, collected by **mechanical** and pasted into the Implementation log.

- `git grep -n "plans/finished" -- agents/orchestrator-ai-tools.md` returns exactly six lines: the *Context isolation* prohibition, the Mode A step 2 exclusion, and the four inside `## Plan archival` (archive target, ignore note, never-scan invariant, reentry path). The pre-change hits at *Plan intake*, *Planner obligations* (three) and Mode A step 6 are gone.
- `grep -nE "move|Move|moved" agents/orchestrator-ai-tools.md` returns hits only inside `## Plan archival` (the archive move, the tracked-deletion note, the reentry move) — the six pre-change hits at *Planner obligations* (three), Mode A step 6, *Validation* item 6 and *Final summary* are gone.
- `git grep -n "Plan archival" -- agents/orchestrator-ai-tools.md` shows the section heading plus the six cross-references (Routing, Branch per plan, Plan intake, two Planner obligations bullets, Mode A step 6).

## Acceptance criteria

- [ ] `## Plan archival` exists once, between `## Status protocol` and `## Mode A — plan queue`, with the text above unchanged.
- [ ] No instruction anywhere in the file moves a stage, fix, or base file before every stage of that plan is terminal.
- [ ] The archive trigger reads only the stage table and the Dispatch log Outcome cells — no timestamp, elapsed time, or clock comparison is introduced (consistent with *Lost runs*).
- [ ] Reentry is possible only via an explicit named dispatch, requires at least one `E`, refuses an all-`F` set and a `plans/<slug>.md` collision, and reports the refusal.
- [ ] The queue statement and Mode A step 2 agree: `plans/finished/**` is never a source of work.
- [ ] The file is English, states the rule once, and adds no wording that contradicts *Lost runs* or the one-live-writer rule (README rules 14–15).

## Commit

None — this stage defines no commit boundary. Stage 3 commits the whole plan (README rule 52 requires the version bump in the same commit as the shipped-content change).

## Dependencies

- Requires stages: none
- Parallel-safe with: stage 2 (disjoint files)

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | fe332a05-e535-4d55-9744-c2c4ed36f88c | V → accepted |

## Validation (planner)

Diff inspected on `agents/orchestrator-ai-tools.md` (21 insertions, 7 deletions, single file). All eight edits applied verbatim; no other file touched; the *Context isolation* line is unchanged.

Acceptance criteria, each passed:

1. `## Plan archival` exists once, between `## Status protocol` and `## Mode A — plan queue`, text unchanged.
2. No instruction moves a stage, fix, or base file before every stage is terminal — the three per-stage moves are gone from *Planner obligations*, Mode A step 6, and *Validation* item 6.
3. The trigger reads only the stage table and the Dispatch log Outcome cells; no timestamp or elapsed-time wording introduced.
4. Reentry requires an explicit named dispatch and at least one `E`; all-`F` and `plans/<slug>.md` collision are both refused and reported.
5. Mode A step 2 still excludes `plans/finished/**`, matching the never-scan invariant.
6. English, one statement, no contradiction with *Lost runs* or one-live-writer.

Test-count note (not a defect): the stage's predicted grep counts undercount its own mandated text. `git grep -n "plans/finished"` returns 7 lines, not 6 — the extra is the Routing row that edit 1 requires. `grep -nE "move|Move|moved"` returns 5 lines, not 3 — the extras are line 125 (inside `## Plan archival`) and line 117, the "no file moves" bullet that edit 4 mandates verbatim. Every pre-change hit the test required to disappear is gone. The prescribed text governs over the predicted counts.

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Applied the eight edits to `agents/orchestrator-ai-tools.md` verbatim as specified in this stage file's `## Steps` section: (1) Routing table reentry row, (2) Branch per plan reentry bullet, (3) Plan intake sentence, (4) three Planner obligations bullet replacements, (5) new `## Plan archival` section inserted after the Planner obligations list and before `## Mode A — plan queue`, (6) Mode A step 6, (7) Validation item 6, (8) Final summary closing sentence.
- Ran the three verification commands from `## Tests`. Real output below.

Command 1: `git grep -n "plans/finished" -- agents/orchestrator-ai-tools.md`
```
17:| An archived slug, or `plans/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
64:Implementers must not open other stage files, base plans, or `plans/finished/**`. Keep parent stage files and unassigned fix files out of decomposed fix prompts.
127:- **Archive** when every stage row of the base plan reads `F` or `E` — with or without failures — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and it must never find its file moved. Move the whole set in one operation into `plans/finished/<slug>/`; nothing of that plan is left under `plans/`.
128:- The moved files are versioned while `plans/finished/` is ignored, so the move is a tracked deletion: commit it path-scoped as `chore(plans): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean.
129:- **The queue never reads the archive.** `plans/finished/**` is never scanned, globbed, or listed as a source of work (Mode A step 2). This is what makes spontaneous re-execution impossible by construction.
130:- **Reentry** happens only on a dispatch naming an archived plan by slug or path, and resolves to exactly `plans/finished/<slug>/<slug>.md`; anything else is not an archived set — report it and touch nothing. Read that base plan's stage table:
138:2. Discover base plans: `plans/*.md` (excluding `*-<digits>.md` stage files, `*-F<digits>.md` fix files, `plans/finished/**`, and `plans/dev/**`). Never execute stages/fixes without their base.
```
Actual: 7 lines, not the 6 predicted by the test description. The extra hit is line 17, the new Routing row from edit 1 (`| An archived slug, or \`plans/finished/<slug>/\` | ...`), which is verbatim text mandated by the stage's edit 1 and was not counted among the test's predicted six. Applied verbatim per instructions; flagging the count mismatch as fact, not fixing it.

Command 2: `grep -nE "move|Move|moved" agents/orchestrator-ai-tools.md`
```
117:- **On pass (`F`)**: commit if the stage defines a commit boundary; no file moves (*Plan archival*).
125:A plan's **set** is its base plan `plans/<slug>.md` plus every `plans/<slug>-*.md` stage and fix file. The set is one unit and travels as one: it is created under `plans/` and every file of it stays there, whatever its status, until the plan is over. Never move a file of a plan while any stage of that plan is non-terminal. Terminal is `F` or `E`.
127:- **Archive** when every stage row of the base plan reads `F` or `E` — with or without failures — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and it must never find its file moved. Move the whole set in one operation into `plans/finished/<slug>/`; nothing of that plan is left under `plans/`.
128:- The moved files are versioned while `plans/finished/` is ignored, so the move is a tracked deletion: commit it path-scoped as `chore(plans): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean.
131:  - at least one `E` → move the whole set back into `plans/` intact, commit the restore as `chore(plans): reopen <slug>`, then run it as a normal Mode A plan;
```
Actual: 5 lines, not the 3 predicted by the test description. Two extra hits: line 117 (`no file moves`, outside `## Plan archival`, verbatim text mandated by edit 4's third replacement) and line 125 (the section's own intro sentence, containing "move"/"Never move", inside `## Plan archival` but not one of the three items the test description named). All five are verbatim text mandated by the stage's edits. Applied verbatim per instructions; flagging the count mismatch as fact, not fixing it.

Command 3: `git grep -n "Plan archival" -- agents/orchestrator-ai-tools.md`
```
17:| An archived slug, or `plans/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
26:- A reentered plan (*Plan archival*) reuses its existing `plan/<slug>` branch, which carries the work already accepted; cut a new one only when it is absent.
50:Before dispatching a plan, load its base file and every stage and fix file of that plan (`plans/<slug>-*.md`) in full — the whole set is under `plans/` (*Plan archival*).
117:- **On pass (`F`)**: commit if the stage defines a commit boundary; no file moves (*Plan archival*).
121:- When all stages reach `F`/`E`, archive the set (*Plan archival*).
123:## Plan archival
149:6. Archive every resolved plan (*Plan archival*). Return the final summary, including one PR approval request or local review request per completed plan branch.
```
Actual: 7 lines (1 heading + 6 cross-references: Routing, Branch per plan, Plan intake, two Planner obligations bullets, Mode A step 6) — matches the test description exactly.

Status: V
