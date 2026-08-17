# Stage 2: Planner format and user-wide Plans rule

## Objective

The canonical on-disk layout in `agents/planner-ai-tools.md` and the user-wide `Plans` rules in `USER-AGENTS.md` describe the atomic lifecycle — each stating it once, in its own register: the planner in layout terms with status codes, `USER-AGENTS.md` in plain words without them. `USER-AGENTS.md` stays under the 12,000-character cap (README rule 3).

## Files

- Modify: `agents/planner-ai-tools.md` — carries the canonical plan-file layout the orchestrator reads and updates
- Modify: `USER-AGENTS.md` — install artifact: the user-wide `Plans` rules the session model follows

Do not touch `agents/orchestrator-ai-tools.md` (stage 1 owns it), `README.md` (stage 3), `agents/<harness>/**`, `scripts/**`, `skills/**`, or `.gitignore`.

## Steps

### 1. `agents/planner-ai-tools.md` — canonical layout

In `## Plan file format`, replace the whole fenced `text` tree:

```text
plans/
  <slug>.md           # base plan
  <slug>-1.md         # stage 1
  <slug>-2.md         # stage 2
  finished/           # completed files moved here by the orchestrator
```

with:

```text
plans/
  <slug>.md           # base plan
  <slug>-1.md         # stage 1
  <slug>-2.md         # stage 2
  <slug>-F1.md        # fix file, added by the orchestrator during corrections
  finished/<slug>/    # the whole set, moved here by the orchestrator in one move, only once every stage is terminal (`F` or `E`)
```

Leave the `**Status codes**` table and its `E`/`F` rows unchanged: the tree comment is this file's single statement of the lifecycle, and repeating it under the table would be the drift this change exists to remove.

### 2. `agents/planner-ai-tools.md` — boundary

In `## Boundaries`, replace:

> - Write only under `plans/`.

with:

> - Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.

### 3. `USER-AGENTS.md` — the `Plans` section

Replace the first bullet of `## Plans`:

> - Saved under `plans/` in the working repository; completed plans move to `plans/finished/`.

with these two bullets, in this order, as the first two of the section:

> - Saved under `plans/` in the working repository. A plan's whole set — base plan, stage files, fix files — stays there for the entire execution and moves to `plans/finished/<slug>/` in a single move, only once every stage has finished or failed for good.
> - An archived set is never picked up on its own. One holding a stage that failed for good returns to `plans/` only when the orchestrator is dispatched on it by name; one whose stages all finished is final, and the attempt is refused.

Change nothing else in the section. In particular the ignore-policy bullet ("Every generated subdirectory under `plans/` is transient and must be ignored (`plans/*/`), including `finished/`, `dev/`, and `vibe/`") stays exactly as it is — it already covers `plans/finished/<slug>/`, and `.gitignore` needs no change.

Use no status codes (`F`, `E`, `W`) in `USER-AGENTS.md`: it defines none, and introducing them here would cost characters against the cap and duplicate the agent base files.

## Tests

No test suite in this repository; verification is command output, collected by **mechanical** and pasted into the Implementation log.

- `wc -c USER-AGENTS.md` is below 12,000 (README rule 3; it was 10,873 before this stage).
- `git grep -n "finished" -- USER-AGENTS.md agents/planner-ai-tools.md` returns only: the two new `Plans` bullets, the unchanged ignore-policy bullet, the layout tree comment, and the `F` status row ("Finished — stage accepted").
- `git grep -n "plans/finished" -- agents/planner-ai-tools.md` returns only the `Boundaries` line.

## Acceptance criteria

- [ ] The planner's layout tree shows `finished/<slug>/` receiving the whole set in one move once every stage is terminal, and lists fix files as part of that set.
- [ ] The planner's `Boundaries` forbid writing into `plans/finished/`.
- [ ] `USER-AGENTS.md` states the atomic move and the named-dispatch reentry, each once, without status codes, and its ignore-policy bullet is untouched.
- [ ] `wc -c USER-AGENTS.md` < 12,000.
- [ ] No sentence in either file contradicts stage 1's `## Plan archival`, and neither file describes a per-file or mid-run move.

## Commit

None — this stage defines no commit boundary. Stage 3 commits the whole plan.

## Dependencies

- Requires stages: none
- Parallel-safe with: stage 1 (disjoint files)

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | fe332a05-e535-4d55-9744-c2c4ed36f88c | V → accepted |

## Validation (planner)

Diff inspected on `agents/planner-ai-tools.md` and `USER-AGENTS.md`. Both replacements are verbatim; nothing else in either file changed, and `agents/orchestrator-ai-tools.md`, `README.md`, `.gitignore`, `scripts/**`, `skills/**` were untouched.

Acceptance criteria, each passed:

1. The layout tree shows `finished/<slug>/` receiving the whole set in one move once every stage is terminal, and lists `<slug>-F1.md` as part of the set.
2. `Boundaries` now forbids writing into `plans/finished/`.
3. `USER-AGENTS.md` states the atomic move and the named-dispatch reentry once each, with no status codes; the ignore-policy bullet is untouched.
4. `wc -c USER-AGENTS.md` = 11273 < 12,000 (README rule 3).
5. Neither file contradicts stage 1's `## Plan archival`, and neither describes a per-file or mid-run move.

Test-note (not a defect): the stage predicted `git grep -n "finished"` would also return the `F` status row; grep is case-sensitive and that row reads `Finished`. The row is unchanged, as the stage requires.

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Session `fe332a05-e535-4d55-9744-c2c4ed36f88c` implemented steps 1-3.
- Step 1: replaced the `## Plan file format` tree in `agents/planner-ai-tools.md` with the fix-file line and `finished/<slug>/` atomic-move line, per the stage text verbatim.
- Step 2: replaced the `Boundaries` bullet `- Write only under \`plans/\`.` with `- Write only under \`plans/\`, never into \`plans/finished/\` — the archive is the orchestrator's.`
- Step 3: replaced the first `## Plans` bullet in `USER-AGENTS.md` with the two new bullets (atomic move + named-dispatch reentry), leaving the rest of the section untouched.
- `git diff -- USER-AGENTS.md agents/planner-ai-tools.md` confirmed only the intended lines changed (shown below).

```
diff --git a/USER-AGENTS.md b/USER-AGENTS.md
index 97838e2..a3b3c45 100644
--- a/USER-AGENTS.md
+++ b/USER-AGENTS.md
@@ -78,7 +78,8 @@ These instructions being written in English never forces English on a working re
 
 ## Plans
 
-- Saved under `plans/` in the working repository; completed plans move to `plans/finished/`.
+- Saved under `plans/` in the working repository. A plan's whole set — base plan, stage files, fix files — stays there for the entire execution and moves to `plans/finished/<slug>/` in a single move, only once every stage has finished or failed for good.
+- An archived set is never picked up on its own. One holding a stage that failed for good returns to `plans/` only when the orchestrator is dispatched on it by name; one whose stages all finished is final, and the attempt is refused.
 - `plans/dev/` holds ad-hoc briefs and feedback for the orchestrator, and stays out of the plan queue.
 - `plans/vibe/` holds the vibe agent's story and decision records (`story-<slug>.md`, `decisions-<slug>.md`), and stays out of the plan queue.
 - Outside a git repository, save to `$HOME/.ai-tools-plans` (`%USERPROFILE%\.ai-tools-plans` on Windows).
diff --git a/agents/planner-ai-tools.md b/agents/planner-ai-tools.md
index 1ce4ead..00f95e1 100644
--- a/agents/planner-ai-tools.md
+++ b/agents/planner-ai-tools.md
@@ -24,7 +24,8 @@ plans/
   <slug>.md           # base plan
   <slug>-1.md         # stage 1
   <slug>-2.md         # stage 2
-  finished/           # completed files moved here by the orchestrator
+  <slug>-F1.md        # fix file, added by the orchestrator during corrections
+  finished/<slug>/    # the whole set, moved here by the orchestrator in one move, only once every stage is terminal (`F` or `E`)
 ```
 
 ### Base file (`plans/<slug>.md`)
@@ -120,7 +121,7 @@ Suggested message: `feat: …` (or fix/chore/…)
 
 ## Boundaries
 
-- Write only under `plans/`.
+- Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.
 - Never edit product code, run verification builds, spawn implementers, or implement anything.
 - Never delegate this role to another agent.
 - The saved plan is the deliverable; the session decides with the user whether to implement it.
```

### Test results

`wc -c USER-AGENTS.md`:
```
11273 USER-AGENTS.md
```
Below the 12,000-char cap (was 10,873 before this stage; +400 chars for the two new bullets).

`git grep -n "finished" -- USER-AGENTS.md agents/planner-ai-tools.md`:
```
USER-AGENTS.md:81:- Saved under `plans/` in the working repository. A plan's whole set — base plan, stage files, fix files — stays there for the entire execution and moves to `plans/finished/<slug>/` in a single move, only once every stage has finished or failed for good.
USER-AGENTS.md:82:- An archived set is never picked up on its own. One holding a stage that failed for good returns to `plans/` only when the orchestrator is dispatched on it by name; one whose stages all finished is final, and the attempt is refused.
USER-AGENTS.md:86:- In a git repository, root plan files (`plans/*.md`) are versioned: keep them out of ignore rules and include them in path-scoped commits. Every generated subdirectory under `plans/` is transient and must be ignored (`plans/*/`), including `finished/`, `dev/`, and `vibe/`.
agents/planner-ai-tools.md:28:  finished/<slug>/    # the whole set, moved here by the orchestrator in one move, only once every stage is terminal (`F` or `E`)
agents/planner-ai-tools.md:124:- Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.
```
Note: the stage text says this grep should also surface "the `F` status row (\"Finished — stage accepted\")" — it does not, because that row reads `Finished` (capital F) and `git grep` without `-i` is case-sensitive against the lowercase pattern `"finished"`. All other expected lines are present; no unexpected lines appear.

`git grep -n "plans/finished" -- agents/planner-ai-tools.md`:
```
agents/planner-ai-tools.md:124:- Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.
```
Only the `Boundaries` line, as expected.

Status: V
