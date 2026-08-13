---
name: dev-ai-tools
description: >
  Implement plans or ad-hoc work using harness-agnostic agent categories. Use when the user runs
  "/dev-ai-tools". With no argument, or an argument starting with "plans", process base plans at
  plans/*.md (not stage files, not finished/). Any other argument is an ad-hoc implementation
  request. Planner validates; implementer codes; mechanical gathers evidence. Runs unattended.
argument-hint: "[plans [path…] | implementation request]"
---

# Dev

Harness-agnostic implementation skill. **The session running `/dev-ai-tools` acts as planner** for orchestration and judgment: it never writes production or test code in the target repository while this skill is active. Code goes to **implementer**; evidence gathering and mechanical text go to **mechanical**.

See the global `AGENTS.md` for category definitions. Map categories to whatever subagents or models the harness provides; never require a vendor-specific agent name.

## Routing

| Argument | Mode |
|----------|------|
| empty | **A** — every base plan under `plans/` |
| `plans` (plus optional extra instructions) | **A** — every base plan under `plans/` |
| `plans/<file>.md …` — one or more base plan paths | **A** — only the named plans |
| anything else | **B** — ad-hoc implementation |

## Execution contract

This skill runs **unattended**. The user already approved the work before it started.

- Do not ask for confirmation, do not pause for checkpoints, do not request permission to continue.
- Record blockers on the plan as status `E` with a failure report in the stage file, keep running every stage that does not depend on them, and surface the blockers in the final summary.
- Exception: the security gates in the global `AGENTS.md` still hold. Cloud mutations and destructive or shared-state operations need explicit per-action approval, even mid-run.

### Output discipline

- Detail goes to the plan files: stage steps, implementation logs, validation notes, diffs, command output, failure reports. Never paste them into chat.
- No progress narration. No per-stage chat updates.
- Chat gets one short summary at the end, in the user's language — per plan, one line of stage counts by status, plus paths to read for detail, plus any `E` stage with its one-line cause and the recommended recovery. Plan files, logs, and implementer prompts follow the global Disk rule in `AGENTS.md` (concise English unless an exception applies).

## Division of labor

| Work | Category |
|------|----------|
| Orchestrate stages, write briefs, judge acceptance by reviewing the actual diff against the plan, audit tests for cheating, commit after validation, set `TV` / `E` / `F` | **planner** — this session |
| Implement a stage or brief, editing production and test code | **implementer** only |
| Run build/test and return raw output, list diffs, extract logs, draft mechanical feedback text, explore for brief prep | **mechanical** |

Gathering agents return **facts**, not verdicts. Re-evaluate any "it looks correct" claim yourself.

**Hard limit:** 1 initial attempt + up to 3 correction rounds per stage or task, then set `E` and move on.

## Plan intake (planner, once per plan)

Before dispatching the first stage of a base plan, the planner loads that plan **in full**: the base file plus every stage file belonging to it — including stages already `F`, whose files live in `plans/finished/<slug>-<n>.md`. Read those files, do not skim them.

- Scope is the base plan about to run: `plans/<slug>-*.md` plus `plans/finished/<slug>-*.md`. Never another plan's stages, never the rest of `plans/finished/**`, never `plans/dev/**`.
- Skip whatever is already in context — if this session just produced the plan, its stages are loaded; read only the files that are missing.
- Do it **once**, at the start of that plan's execution. Do not re-read stage files per wave, per spawn, or per correction round; work from context and re-open only the single file a validation or correction round actually needs.
- When the run covers several base plans, do the intake per plan, at the moment that plan starts — never all plans up front.

Why: the planner authors every spawn prompt, and a prompt is only as good as its author's picture of the whole plan — what finished stages already delivered, what later stages will assume, which files are already spoken for. This context stays with the planner; it never widens what a spawn receives.

## Context isolation (token discipline)

When spawning an **implementer** for a stage, give it **only**:

1. The base plan file, or an extract of it: Goal, Execution graph, and this stage's status row
2. The single stage file `plans/<slug>-<n>.md`

Instruct it not to open other stage files, other base plans, or `plans/finished/**` unless the assigned stage file explicitly lists a path as a dependency artifact (rare). Never paste other stages into the prompt. This is mandatory: other stages stay out of context.

Plan intake does not widen this budget. Carry forward only what the stage genuinely needs, distilled into a couple of lines of the prompt — an interface a finished stage produced, a convention set earlier, a file another stage owns. Never attach or quote other stage files to do it.

## Status protocol

The base plan carries the status table created by `/plan-ai-tools`, which holds the canonical definition; the codes are reproduced here so this skill is self-contained.

| Code | Meaning | Who sets it |
|------|---------|-------------|
| `W` | Working — implementation in progress | **implementer**, also writes Session |
| `V` | Validating — handed to the planner for judgment | **implementer** |
| `R` | Retry — reworking after planner feedback | **implementer**, updates Session |
| `T` | Testing — dedicated test-writing/running pass | the agent doing it, also writes Session |
| `TV` | Testing validation — planner judging tests | **planner** |
| `E` | Error — correction limit exhausted | **planner** |
| `F` | Finished — stage accepted | **planner** |

### Implementer obligations (put these in every implementer prompt)

1. **First action:** open the base plan, set this stage's Status to `W` (or `R` on a correction) and Session to the current harness session or agent id.
2. Implement only the assigned stage.
3. Append an **Implementation log** section to the stage file: what changed, files touched, commands run, results, anything left incomplete.
4. **Last action:** set Status to `V` on the base plan. The implementer marks work ready for validation; the planner never sets `V`.
5. Never set `T`, `TV`, `E`, or `F`.

### Planner obligations

- After `V`, validate by reading the actual diff and judging it against the plan (see Validation). Do not accept on build/test success alone.
- On pass: set `F`, move `plans/<slug>-<n>.md` to `plans/finished/`, and commit if the stage describes a commit boundary.
- On failure within the retry budget: append concrete correction tasks to the **same stage file**, keeping full history, then spawn an **implementer** again, which sets `R` and Session.
- After 3 failed corrections: set `E`, append a failure report with the recommended recovery to the stage file, and continue with stages that do not depend on it.
- When every stage is `F` (or `E` stages are all reported), move the base `plans/<slug>.md` to `plans/finished/`.

## Mode A — plan queue

1. Find the repository root (`git rev-parse --show-toplevel`); stop if this is not a git repository.
2. Discover **base plans only**: `plans/*.md` at the root of `plans/`, excluding `*-<digits>.md` stage files and `plans/finished/**`. A base plan has a `## Status` table and links to `./<slug>-N.md` stages. If the argument named specific paths, use exactly those.
3. Stop if none exist; say so in one line.
4. Ensure `plans/` is in `.gitignore`.
5. Check `git status --short`. If the worktree is dirty, note it in the final summary and stage commits **path by path** for the files each stage touched — never `git add -A`, so pre-existing work stays out of the commits.
6. Order plans oldest first unless extra instructions say otherwise. For each base plan:
   1. Do the Plan intake for that base plan — base file plus all of its stage files, finished ones included. Take the execution graph and status table from the base file.
   2. Build stage waves from the graph. Skip stages already `F`; leave `E` stages for the end.
   3. Run each wave: **sequential** stages one after another; **parallel-safe** stages as one batch of **implementer** spawns, never two implementers on the same files. Each gets base + one stage file.
   4. When an implementer returns `V`, validate by reading the actual diff and judging it against the plan (see Validation). Do not accept on build/test success alone.
   5. If a stage needs a dedicated test pass, that agent sets `T` and Session; the planner then sets `TV` while judging, then `F` or a correction round.
   6. On `F`, commit that stage if the plan describes a commit boundary — Conventional Commits, and check staged files for secrets and binaries first.
7. When a base plan is fully resolved, move it to `plans/finished/`.
8. Close with the final summary described in Output discipline.

### Base vs stage files

- Stage file: `plans/<slug>-<n>.md`, `<n>` a positive integer. Base file: `plans/<slug>.md` with no `-<n>` suffix.
- Never treat `plans/finished/**` or `plans/dev/**` as queue input.
- Never execute a stage file without its base.

## Mode B — ad-hoc request

1. Derive a kebab-case `<slug>` from the request.
2. If a base plan under `plans/` already covers it, run Mode A for that plan instead.
3. Ask clarifying questions only here, before any implementer starts; after that the run is unattended.
4. Explore with **mechanical** or the harness explore type until the paths are real.
5. Write `plans/dev/<slug>-brief.md` — a handoff, not a base plan. Minimum: the original request verbatim, goal, context, source of truth, tasks with paths, tests by type, docs, acceptance criteria, commits, and the report the implementer owes the planner.
6. Spawn an **implementer** on the brief. If the work is too large for one brief, split it into several briefs yourself and sequence them — do not call `/plan-ai-tools`.
7. Validate by reading the actual diff and judging it against the brief (see Validation). Do not accept on build/test success alone. Run correction rounds with `plans/dev/<slug>-feedback-<n>.md`, same 1 + 3 limit.
8. Commit only after validation, and only if the brief authorized it.

Mode B needs no status table unless you build a full plan structure.

## Validation (planner)

An implementer report and a `V` status are claims, not proof. A green build and passing tests are **not** acceptance.

1. Read the stage objective, allowed files, acceptance criteria, and implementation log.
2. Inspect the **actual** diff — run `git status`, `git diff`, and recent log. Do not rely on a summary of the changes.
3. Judge the diff as a senior reviewer:
   - Does every change serve the stage objective and stay inside the allowed files?
   - Is anything the plan required missing, stubbed, or only mentioned in the log?
   - Is anything extra, speculative, or a drive-by the plan did not ask for?
   - Do comments, names, and structure match the repository's conventions?
   - Would a later stage or the user still have to fix this for the plan to be true?
4. Each acceptance criterion is pass or fail with a reason. "Tests passed" is not a reason.
5. **Test audit:** do the tests exercise observable behavior? Would they fail if the feature were broken? Were existing tests weakened? Are types split into separate files where the project requires it?
6. Run build and tests via **mechanical**, and enforce project thresholds (for example 80% coverage when the repository mandates it). Treat that output as **evidence**, not the verdict.
7. Pass only when the diff satisfies the plan **and** the review criteria. Then set `F`, move the stage file, commit if applicable. Fail → append concrete correction tasks to the stage file; the implementer resumes at `R`.

## Spawning conventions

- Sequential item: one **implementer**, wait for the result.
- Parallel-safe batch: several **implementer** spawns with no shared file ownership.
- Correction: resume via the Session id in the status table when the harness supports it; otherwise spawn a new **implementer** with base + stage file, which now carries the prior logs and feedback.
- **mechanical** never edits production or test code under this skill.
- Every spawn — **implementer** or **mechanical**, in Mode A, Mode B, or validation — gets announced per the global `AGENTS.md` category rules: name the category and the concrete model the harness assigned it, in the user's language, at the point of spawning, not folded into a later summary.

## Boundaries

- Only **implementer** writes repository code, plus the status and log updates specified above.
- **planner** does not implement; it sets `TV` / `E` / `F` and commits after validation.
- Never chain into `/plan-ai-tools`. If an `E` stage needs a redesign, say so in the final summary and let the user start a new plan.
- Do not use this skill for pure question answering.
