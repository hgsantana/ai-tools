---
name: plan
description: >
  Restricted-invocation skill — invoke only when (a) the user explicitly runs "/plan",
  (b) another skill's documented workflow calls it by name, or (c) global AGENTS.md
  Mandatory Steps call it for a non-trivial code change. Produces a multi-file
  implementation plan under plans/ and stops — never implements code.
argument-hint: [description of the change, feature, or fix to plan]
disable-model-invocation: false
---

# Plan

Produce a step-by-step implementation plan for a change to the current repository, then stop.
This skill never writes, edits, or removes production source code, never runs builds or tests
as a delivery step, and never hands off to an implementer.

**Category roles (see global `AGENTS.md`)**

| Role in this skill | Category |
|--------------------|----------|
| You (orchestrating this skill) | **planner** |
| Codebase exploration subagents | **mechanical** (read-only explore) or harness explore type |
| Implementation | not used |

Never hard-code vendor model names. The harness maps **planner** / **implementer** / **mechanical**.

## Workflow

1. **Determine the task.** Use the user's arguments if provided; otherwise ask what to plan.
   If the request is vague, ask targeted clarifying questions before exploring.

2. **Read the source of truth.** Check for `README.md` and `AGENTS.md` at the repository root
   (and relevant subdirectories). Their conventions override generic assumptions. Also honor
   the global `AGENTS.md` agent categories and mandatory steps.

3. **Explore the codebase.** Dispatch one or more read-only explore agents (**mechanical** or
   harness explore) to locate entry points, patterns, related modules, test conventions, and
   build config. Launch independent explores in parallel. Use direct read/grep for pinpoint lookups.

4. **Synthesize the plan** as a **base file + one file per stage** (see format below):
   - Numbered stages, each independently reviewable and implementable from its own file alone
     plus the base goal section
   - Exact file paths to create / modify / remove, with a short reason
   - Tests split by type where relevant: unit, integration, mutation, security/intrusion,
     performance, etc.
   - Documentation updates as a last stage when behavior or public surface changes
   - Suggested Conventional Commits boundaries (describe; do not run git writes)
   - For every stage: **sequential** vs **parallel-safe** relative to other stages (feeds the
     execution graph and `/dev` fan-out)

5. **Iterate with the user.** Present the plan and revise until the user explicitly accepts it.
   Do not write plan files to disk before acceptance.

6. **Save the plan** (after acceptance):
   - Ensure `plans/` exists and is listed in the repository `.gitignore` (append if missing;
     plan files are local working state)
   - Write the base file: `plans/<slug>.md`
   - Write each stage: `plans/<slug>-<n>.md` for n = 1, 2, …
   - Do not overwrite an unrelated existing base slug; pick a distinct name
   - Initialize the status table with empty Status and Session cells

7. **Stop.** Confirm saved paths and end. Do not offer to implement, do not spawn **implementer**,
   do not run builds/tests as delivery, do not move files to `plans/finished/`.
   If the user wants implementation, they run `/dev` separately.

## Multi-file layout

Example slug `i18n-ui-and-content-language`:

```text
plans/
  i18n-ui-and-content-language.md      # base
  i18n-ui-and-content-language-1.md    # stage 1
  i18n-ui-and-content-language-2.md    # stage 2
  finished/                            # /dev moves completed files here
```

### Base file (`plans/<slug>.md`)

Must start with a status table, then goal, execution graph, and stage index.

```markdown
# <Title>

## Status

| Stage | Status | Session |
|------:|:------:|---------|
| 1 | | |
| 2 | | |

## Goal

1–3 sentences: what changes and why.

## Execution graph

Terse dependency list. Every stage appears in exactly one place.
Example: Stage 1 before 2 and 3 (parallel-safe with each other); stage 4 after 2 and 3.

## Stages

1. [Short title](./<slug>-1.md) — one-line summary
2. [Short title](./<slug>-2.md) — one-line summary

## Notes

Optional: commit strategy overview, risks, out of scope.
```

**Status codes** (maintained mainly by `/dev`; leave empty when creating):

| Code | Meaning | Who sets it |
|------|---------|-------------|
| *(empty)* | Not started | — |
| `W` | Working — implementer in progress | **implementer** (also writes Session) |
| `V` | Validating — implementer handed off for judgment | **implementer** |
| `R` | Retry — implementer reworking after feedback | **implementer** (updates Session) |
| `E` | Error — failed after correction limit | **planner** (orchestrator) |
| `T` | Testing — tests being written/run | agent doing that work (also Session) |
| `TV` | Testing validation — orchestrator judging tests | **planner** (orchestrator) |
| `F` | Finished — stage accepted | **planner** (orchestrator) |

**Session** column: harness session / agent id (or equivalent resume handle) for the active worker
on that stage. Critical for resume after network or budget failure.

### Stage file (`plans/<slug>-<n>.md`)

Self-contained enough that an **implementer** given **only** the base file’s Goal + Execution
graph context **and this stage file** can complete the stage without reading other stage files.

```markdown
# Stage <n>: <Title>

## Objective

What this stage delivers.

## Files

- Create: `path` — reason
- Modify: `path` — reason
- Remove: `path` — reason

## Steps

1. …
2. …

## Tests

- Unit (`path_test.go` / `*.spec.ts`): must exercise …
- Integration: …

## Acceptance criteria

- [ ] Observable criterion 1
- [ ] Build/tests required for this stage pass
- [ ] …

## Commit

Suggested message: `feat: …` (or fix/chore/…)

## Dependencies

- Requires stages: … (or none)
- Parallel-safe with: …

## Implementation log

(Append-only. Implementers and orchestrator add sections below during `/dev`.)
```

## Boundaries

- Only write under `plans/` (and `.gitignore` if adding `plans/`).
- Never spawn **implementer** for production code from this skill.
- Never chain into `/dev` automatically.
- Activate only on explicit `/plan`, a skill that names this step, or global AGENTS.md mandatory steps.
