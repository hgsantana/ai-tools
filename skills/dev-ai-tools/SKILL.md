---
name: dev-ai-tools
description: >
  Implement plans or ad-hoc work using harness-agnostic agent categories. Use when the user
  runs "/dev-ai-tools". With no argument or argument starting with "plans", process every base plan at
  plans/*.md (not stage files, not finished/). Otherwise treat the argument as an ad-hoc
  implementation request. Planner validates; implementer codes; mechanical gathers evidence.
argument-hint: [plans | implementation request]
---

# Dev

Harness-agnostic implementation skill. **You (the session running `/dev-ai-tools`) act as planner** for
orchestration and judgment. You never write production or test code in the target repository
while this skill is active — you delegate that to **implementer**. Evidence gathering and
mechanical text go to **mechanical**.

See global `AGENTS.md` for category definitions. Map categories to whatever subagents/models the
current harness provides; never require a vendor-specific agent name.

## Routing

| Arguments | Mode |
|-----------|------|
| empty | **A** — plan queue |
| starts with `plans` | **A** — plan queue (remainder = extra instructions) |
| anything else | **B** — ad-hoc implementation |

## Category division of labor

| Work | Category |
|------|----------|
| Orchestrate stages, write briefs, decide acceptance, anti-cheat test audit, commit after validation, set `E` / `TV` / `F` | **planner** (this session) |
| Implement a stage or brief (edit production/test code) | **implementer** only |
| Run build/test and return raw output; list diffs; extract logs; draft mechanical feedback text | **mechanical** |
| Explore codebase for brief prep (Mode B) | **mechanical** / harness explore |

Gathering agents return **facts**, not verdicts. Re-evaluate any “it looks correct” claim yourself.

**Hard limit:** initial attempt + up to **3** correction rounds per stage/task. Then set `E` and stop that stage.

## Context isolation (token discipline)

When spawning an **implementer** for a stage:

1. Give it **only**:
   - The **base plan file** (or a short extract: Goal + Execution graph + this stage’s status row), and
   - The **single stage file** `plans/<slug>-<n>.md` for that stage
2. Instruct it **not** to open other `plans/<slug>-*.md` stage files, other base plans, or
   `plans/finished/**` unless a path is explicitly listed inside the assigned stage file as a
   dependency artifact (rare).
3. Do not paste the full contents of other stages into the prompt.

This is mandatory: other stages stay out of context.

## Status protocol

Base plan table (created by `/plan-ai-tools`):

| Stage | Status | Session |
|------:|:------:|---------|
| 1 | | |
| … | | |

| Code | Meaning | Who sets |
|------|---------|----------|
| `W` | Working — implementation in progress | **implementer** first action; also writes Session |
| `V` | Validating — work handed to planner for judgment | **implementer** when done |
| `R` | Retry — reworking after planner feedback | **implementer** when starting a correction; updates Session |
| `E` | Error — exhausted retries | **planner** |
| `T` | Testing — writing/running tests as a dedicated pass | agent doing it (Session) |
| `TV` | Testing validation | **planner** |
| `F` | Finished | **planner** |

### Implementer obligations (put these in every implementer prompt)

1. **First action:** open the base plan, set this stage’s Status to `W` (or `R` on correction) and
   Session to the current harness session/agent id (or best available resume handle).
2. Implement only the assigned stage.
3. Append an **Implementation log** section at the end of the stage file: what changed, files
   touched, commands run, results, anything incomplete.
4. **Last action before returning:** set Status to `V` on the base plan (implementer marks ready
   for validation — planner does not set `V`).
5. Do not set `F`, `E`, or `TV`.

### Planner obligations

- After `V`: validate (diff, acceptance criteria, test quality, build/tests via **mechanical**).
- On success: set `F`, then move `plans/<slug>-<n>.md` → `plans/finished/<slug>-<n>.md`.
  Update the base Stages link if useful (optional note “finished”).
- On failure within retry budget: append correction notes to the **same stage file** (keep full
  history), leave or set instructions, spawn **implementer** again; implementer sets `R` + Session.
- After 3 failed correction rounds: set `E`, append a failure report to the stage file, and
  **discuss recovery options with the user** (re-plan that stage, drop it, change approach).
  Prefer deferring `E` stages if other stages do not depend on them; run independent stages first.
- When **all** stages are `F` (or intentionally skipped with user OK): move base
  `plans/<slug>.md` → `plans/finished/<slug>.md`.

## Mode A — plan queue

1. Repository root (`git rev-parse --show-toplevel`). Stop if not a git repo.
2. Discover **base plans only**: `plans/*.md` at the root of `plans/`, excluding names that match
   `*-<digits>.md` (stage files) and excluding `plans/finished/**`.
   A base plan is a file that has a `## Status` table and links to `./<slug>-N.md` stages,
   or any `plans/<name>.md` that is not a stage suffix file.
3. If none: warn and stop.
4. `git status --short`: if uncommitted work exists, warn the user before spawning implementers.
5. Ensure `plans/` is in `.gitignore`.
6. Order plans (oldest first unless extra instructions say otherwise). For each base plan:
   1. Read **only that base plan** to learn the execution graph and status table.
   2. Build stage waves from the graph. Skip stages already `F`. Prefer unfinished non-`E` stages;
      leave `E` for the end or user discussion.
   3. For each wave:
      - **Sequential** stages: one after another.
      - **Parallel-safe** stages: spawn multiple **implementer** agents in one batch; never two
        implementers on the same files.
      - Each implementer gets base + **one** stage file only (context isolation).
   4. When an implementer returns with `V`: **planner** validates (see Validation).
   5. Optional test-focused pass: if the stage requires a separate test agent, that agent sets `T`
      and Session; then planner sets `TV` while judging, then `F` or correction.
   6. On `F`: commit for that stage if the stage/base describes a commit boundary (planner runs
      commit after validation — Conventional Commits, check staged files for secrets/binaries).
   7. Next stage/wave.
7. If a stage hits `E` and others are independent, continue those; then escalate `E` stages with
   the user (re-plan options). Do not invent a new plan file without user direction; `/plan-ai-tools` may
   be suggested for a replacement stage design.
8. When a base plan is fully done, move it to `plans/finished/`.
9. Wrap-up: which plans finished, which stages are `E`/blocked, correction counts.

### Identifying base vs stage files

- Stage file pattern: `plans/<slug>-<n>.md` where `<n>` is a positive integer.
- Base file: `plans/<slug>.md` without the `-<n>` suffix.
- Never treat `plans/finished/**` as queue input.
- Never execute a stage file without its base.

## Mode B — ad-hoc request

1. Derive kebab-case `<slug>` from the request.
2. If a relevant base plan already exists under `plans/`, prefer Mode A for that plan.
3. If vague, ask clarifying questions before spawning **implementer**.
4. Explore with **mechanical**/explore enough for real paths.
5. Write `plans/dev/<slug>-brief.md` (handoff only; not a base plan unless you also structure stages).
   Minimum: Original request (verbatim), Goal, Context, Source of truth, Tasks with paths, Tests by
   type, Docs, Acceptance criteria, Commits, Required report back to planner.
6. Warn on dirty git status.
7. Spawn **implementer** on the brief (single task unless you split into a mini plan via `/plan-ai-tools`).
8. Validate; correction rounds with `plans/dev/<slug>-feedback-<n>.md`; same 1+3 limit.
9. Commit only after validation if the brief authorized it.

Mode B does not require the multi-file status table unless you create a full `/plan-ai-tools` structure.

## Validation (planner)

Implementer report and status `V` are claims, not proof.

1. Read the stage file log and the allowed paths.
2. `git status` / `git diff` / recent log — what actually changed.
3. Read changed files against acceptance criteria.
4. **Test audit:** Do tests exercise observable behavior? Would they pass if the feature were
   broken? Were existing tests weakened? Are types split into separate files when required?
5. Run build/tests via **mechanical**; require project thresholds (e.g. 80% coverage when the repo
   mandates it).
6. On pass → `F` + move stage file + commit if applicable.
7. On fail → append concrete correction tasks to the stage file; implementer resumes with `R`.

## Spawning conventions

- Sequential item: one **implementer**, wait for result.
- Parallel-safe batch: multiple **implementer** spawns without shared file ownership.
- Correction: prefer resume via Session id in the status table when the harness supports it;
  otherwise new **implementer** with base + stage file (which now includes prior logs and feedback).
- **mechanical** never edits production/test code in the target repo under this skill.

## Boundaries

- Only **implementer** writes repository code (and stage/base status + logs as specified).
- **planner** does not implement; does set `E` / `TV` / `F` and performs commits after validation.
- Always warn on dirty worktree before first implementer spawn.
- Do not chain into `/plan-ai-tools` automatically; on `E`, discuss with the user and offer `/plan-ai-tools` if redesign is needed.
- Do not use this skill for pure Q&A.
