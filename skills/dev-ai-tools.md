# Dev

> Base instruction. Harness wrappers under skills/<harness>/<name>/SKILL.md point here; edit this file, never a wrapper.

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not, or cannot tell** — never delegate this skill, and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. **Authorized** — run this skill here, in this session, acting as its **planner** yourself. That
   authorization holds for the rest of the session and is asked again only if the model changes. Declined or
   unanswered — stop: no exploration, no writes, no spawns.

**Role assignment**: The agent running this skill is the **planner** (orchestrates and validates; never writes repository code). Code editing is assigned to **implementer**; builds, tests, and evidence gathering to **mechanical**.

## Routing

| Argument | Mode | Scope |
|----------|------|-------|
| Empty or `plans` (plus instructions) | **A** | All base plans under `plans/` |
| `plans/<file>.md …` | **A** | Named base plans only |
| Anything else | **B** | Ad-hoc implementation |

## Execution contract

Runs **unattended** (work was approved prior to invocation).

- Never pause for confirmations or checkpoints.
- Blockers become status `E` in the stage file; continue independent stages and report blockers in final summary.
- Security gates in `AGENTS.md` override unattended execution (cloud mutations/destructive actions require explicit approval).

### Output discipline

- Plan files store all detail (steps, logs, diffs, outputs).
- No per-stage chat progress narration.
- Chat receives one terminal summary in user's language (see Final summary). Disk files follow English rules.

## Division of labor

| Work | Category |
|------|----------|
| Orchestrate stages, author briefs, review diffs, audit tests, commit, manage status (`W`/`R`/`T`/`E`/`F`) | **planner** (this session) |
| Implement assigned stage or brief (edit code/tests) | **implementer** |
| Run builds/tests, return raw logs/diffs, draft mechanical text | **mechanical** |

**Limit**: 1 initial attempt + up to 3 correction rounds per stage, then set `E`.

## Plan intake (planner, once per plan)

Before dispatching a plan, load its base file and all stage files (`plans/<slug>-*.md` and `plans/finished/<slug>-*.md`) in full.
- Do this **once** at the start of that plan's execution; do not reload across waves or spawns.
- Scope is strictly the active plan; never load unrelated plans or `plans/dev/**`.
- Intake informs the planner's orchestration context; it is not forwarded in full to implementers.

## Context isolation (token discipline)

When spawning an **implementer**, provide **only**:
1. Base plan extract: Goal, Execution graph, and stage status row.
2. The single assigned stage file `plans/<slug>-<n>.md` (or, for decomposed corrections after `R1`, only the specific fix file `plans/<slug>-F<m>.md`).

Implementers must not open other stage files, base plans, or `plans/finished/**`. Keep parent stage files and unassigned fix files out of decomposed fix prompts to prevent context pollution.

## Status protocol

| Code | Meaning | Set by |
|------|---------|--------|
| `W` | Working — implementation in progress | **planner** |
| `V` | Validating — ready for planner review | **implementer** |
| `R1`, `R2`, `R3` | Retry 1, 2, 3 — rework after feedback | **planner** |
| `T` | Testing — dedicated test pass | **planner** |
| `TV` | Testing validation — test review | **testing agent** |
| `E` | Error — retry limit exhausted | **planner** |
| `F` | Finished — stage accepted | **planner** |

### Implementer obligations

1. Record own session ID in the current Dispatch log row of the assigned stage/fix file on start.
2. Implement only the assigned stage/fix file.
3. Append factual **Implementation log** to the stage/fix file (actions and evidence, not subjective claims).
4. Set status to `V` (or `TV` for tests) upon completion. Never set `W`, `R*`, `T`, `E`, or `F`.

### Planner obligations

- Set `W` (initial), `R1–R3` (corrections), or `T` (tests) in the base plan status table before dispatching, updating the `Agent` column to the category and concrete model/skill being dispatched.
- Append a Dispatch log row (attempt, status, category, runner) before every spawn; fill its outcome after validating (see Dispatch ledger).
- Validate on `V`/`TV` via actual diff inspection (see Validation).
- **On pass (`F`)**: Move `plans/<slug>-<n>.md` and associated `plans/<slug>-F*.md` fix files to `plans/finished/`; commit if stage defines a commit boundary.
- **On first failure (`R1`)**: Append concrete correction tasks to the stage file `plans/<slug>-<n>.md`, set `R1`, and re-dispatch/resume implementer with the annotated stage file.
- **On second failure (`R2` / post-R1)**: Decompose remaining corrections into isolated fix files:
  1. Create fix files as `plans/<slug>-F<m>.md` (e.g., `feature-proxy-F1.md`).
  2. Record task-to-fix-file mapping in the parent stage file `plans/<slug>-<n>.md`.
  3. Dispatch implementers with only base plan extract and the specific `plans/<slug>-F<m>.md` file.
  4. Set status to `R2` (or `R3` if sub-fixes require retry).
- **On 3 failed corrections (`E`)**: Set `E`, append failure report to stage file, move fix files to `plans/finished/`, and proceed with independent stages.
- When all stages reach `F`/`E`, move base plan `plans/<slug>.md` to `plans/finished/`.

## Mode A — plan queue

1. Verify git repository root (`git rev-parse --show-toplevel`).
2. Discover base plans: `plans/*.md` (excluding `*-<digits>.md` stage files, `*-F<digits>.md` fix files, and `plans/finished/**`).
3. Stop if no plans exist. Ensure `plans/` is in `.gitignore`.
4. Check `git status --short`. If dirty, note in summary and stage commits path-by-path (avoid `git add -A`).
5. Process base plans oldest first:
   1. Perform Plan intake.
   2. Build stage waves from execution graph (skip `F` stages; defer `E`).
   3. Run waves: sequential stages one-by-one; parallel-safe stages in concurrent non-overlapping implementer batches.
   4. Validate on `V`. Run dedicated test pass (`T`/`TV`) if required.
   5. On `F`, commit if stage defines a boundary (Conventional Commits; check for secrets/binaries).
6. Move fully resolved base plan to `plans/finished/`. Output final summary.

### Base, stage, and fix files

- Base file: `plans/<slug>.md` (no `-<n>` or `-F<m>` suffix).
- Stage file: `plans/<slug>-<n>.md` (`<n>` positive integer).
- Fix file: `plans/<slug>-F<m>.md` (post-`R1` decomposed correction).
- Exclude stage files, fix files, `plans/finished/**`, and `plans/dev/**` from queue input. Never execute stages/fixes without their base.

## Mode B — ad-hoc request

1. Derive kebab-case `<slug>` from request. If covered by existing base plan, run Mode A instead.
2. Ask clarifying questions up front (sole interactive point).
3. Explore paths with **mechanical**.
4. Write `plans/dev/<slug>-brief.md` (verbatim request, goal, context, paths, typed tests, docs, criteria, commit rules, report format).
5. Spawn **implementer** on brief (split into sequential briefs if oversized).
6. Validate diff on completion. Run correction rounds via `plans/dev/<slug>-feedback-<n>.md` (1 + 3 limit).
7. Commit only after validation if authorized in brief.

## Validation (planner)

Implementer claims and passing builds are evidence, not acceptance. Base verdicts strictly on verified facts:

1. Review stage objective, allowed files, criteria, and implementation log.
2. Inspect actual diff (`git status`, `git diff`, log).
3. Senior review criteria:
   - All changes align with objective and stay within allowed files.
   - Required items are fully implemented (no stubs or log-only mentions).
   - No extraneous or unrequested changes.
   - Conforms to codebase style and conventions.
   - Downstream stages/users require no cleanups.
4. Pass/fail each acceptance criterion individually with reasons.
5. **Test audit**: Verify tests assert observable behavior, would fail on regressions, and maintain coverage thresholds without weakening existing suites.
6. Pass → set `F`, move files to `plans/finished/`, commit. Fail → append tasks to stage file (`R1`) or decompose into `plans/<slug>-F<m>.md` files (`R2`/`R3`).

## Spawning conventions

- Sequential: One **implementer**, await completion.
- Parallel batch: Multiple concurrent **implementers** on disjoint file sets.
- Correction (R1): Resume the previous attempt's session ID from the Dispatch log if the harness supports it, or spawn implementer with base + annotated stage file.
- Correction breakdown (R2+ / post-R1): Spawn implementer with base plan + individual `plans/<slug>-F<m>.md` fix file. Map files in parent stage file.
- **mechanical** never edits production or test code.
- Announce every spawn in chat in user's language (category + concrete model/skill).

## Dispatch ledger (planner)

Every dispatch (initial, correction, or test pass) appends one row to a **Dispatch log** table in the target stage, fix, or brief file, before the subagent starts. It is the per-attempt history behind the base plan's single-line `Agent` column:

```markdown
## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | <concrete model or skill> | <id> | V → failed validation |
| 2 | R1 | implementer | <concrete model or skill> | <id> | V → accepted |
```

- **Attempt** counts from 1; correction rounds continue the same counter (`R1` = attempt 2).
- **Runner** is the concrete model or bundled skill actually spawned — the same value announced in chat and mirrored into the base plan `Agent` column. Record it in the file only here and there; never hard-code runner names in prompts.
- **Session ID** is written by the dispatched subagent itself on start, and is what a correction round resumes.
- **Outcome** is filled by the planner after validation (`accepted`, `failed validation`, `E — limit exhausted`).
- Decomposed fix files (`plans/<slug>-F<m>.md`) keep their own Dispatch log; the parent stage file's task-to-fix mapping links them.
- Mode B records the ledger in `plans/dev/<slug>-brief.md`.

This table is the only source for the attempt counts and runners reported in the Final summary.

## Final summary (planner)

One chat message in the user's language, emitted after the queue (Mode A) or the brief (Mode B) completes. Per stage or brief, in execution order:

1. **What was delivered** — one or two lines, factual, drawn from the accepted diff.
2. **Attempts** — total attempts and their breakdown (e.g., `2 attempts (initial + 1 correction round)`), plus fix-file count when corrections were decomposed.
3. **Runner** — category and concrete model or skill per attempt; note explicitly when attempts used different runners.

Close with: final status counts (`F`/`E`), paths of the moved plan files and commits created, and for each `E` its cause and the remediation the user must decide on.

Report only what the ledger and the plan files record; never estimate attempt counts or infer a runner that was not announced.

## Boundaries

- Only **implementer** writes repository code.
- **planner** orchestrates, manages status (`W`, `R*`, `T`, `E`, `F`), validates, and commits.
- Never chain into `/plan-ai-tools` from execution failures (report redesigns in summary for user).
- Never delegate root skill to subagents.
- Do not use for pure Q&A.
