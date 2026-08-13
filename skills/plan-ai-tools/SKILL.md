---
name: plan-ai-tools
description: >
  Restricted-invocation skill — invoke only when (a) the user runs "/plan-ai-tools",
  (b) another skill's documented workflow calls it by name, or (c) the global AGENTS.md
  change flow calls it for a non-trivial change. Explores the repository and writes a
  multi-file implementation plan under plans/, then stops. Never implements code.
argument-hint: [description of the change, feature, or fix to plan]
disable-model-invocation: false
---

# Plan

Produce a step-by-step implementation plan for a change to the current repository, save it under `plans/`, and stop.

This skill never writes, edits, or deletes source code; never runs builds or tests as a delivery step; and never hands work to an implementer. Its only output is plan files on disk.

**Category roles** (see global `AGENTS.md`)

| Role here | Category |
|-----------|----------|
| You, orchestrating this skill | **planner** |
| Codebase exploration subagents | **mechanical** (read-only) or the harness explore type |
| Implementation | not used |

## Invocation modes

| Invoked by | After the plan is saved |
|------------|-------------------------|
| The user typing `/plan-ai-tools` — direct mode | Stop. Never implement, never offer to implement, never name `/dev-ai-tools` as a next step you would take. |
| The global `AGENTS.md` change flow, or another skill that names this step — flow mode | Stop and return control to the caller, which decides what happens next. |

In flow mode the caller implements immediately after acceptance, so the acceptance request (step 5) must state that accepting starts implementation now, and list the base plans already under `plans/` that the run will also cover (`plans/*.md`, excluding `-<n>.md` stage files and `plans/finished/**`). In direct mode, say nothing about implementing.

Either way, this skill itself never implements.

## Workflow

1. **Determine the task.** Use the user's argument if given, otherwise ask what to plan. Ask targeted clarifying questions while the request is vague — this is the phase where questions belong.

2. **Read the source of truth.** `README.md` and `AGENTS.md` at the repository root and in relevant subdirectories; their conventions override generic assumptions. Also read `$HOME/AGENTS.md` if it exists (Windows: `%USERPROFILE%\AGENTS.md`); it overrides this repository's global `AGENTS.md` defaults, but not the current project's `AGENTS.md` or `README.md`. The global `AGENTS.md` categories and change flow still apply unless the user file overrides them.

3. **Explore the codebase.** Dispatch read-only explore agents (**mechanical** or the harness explore type) to find entry points, patterns, related modules, test conventions, and build config. Launch independent explorations in parallel; use direct read/grep for pinpoint lookups. Announce each spawn per the global `AGENTS.md` category rules: name the category and the concrete model the harness assigned it, in the user's language, at the point of spawning.

4. **Draft the plan** as a base file plus one file per stage (format below):
   - Numbered stages, each implementable from its own stage file plus the base Goal and Execution graph alone
   - Exact paths to create, modify, or remove, each with a reason
   - Tests split by type where relevant: unit, integration, mutation, security, performance
   - Documentation updates as the last stage when behavior or public surface changes
   - Conventional Commits boundaries described, never executed
   - Per stage: **sequential** or **parallel-safe** relative to the others, feeding the execution graph and `/dev-ai-tools` fan-out

5. **Get acceptance.** Present the plan and revise until the user accepts it. Nothing reaches `plans/` before acceptance. This is the one place where chat detail is wanted: give enough for the user to judge each stage — goal, stages with their files, tests, risks — without dumping whole file contents. Present it in the user's language; the saved files are English either way.

6. **Save** (after acceptance):
   - Ensure `plans/` exists and is listed in the repository `.gitignore`; append it if missing
   - Base file `plans/<slug>.md`, stage files `plans/<slug>-<n>.md` for n = 1, 2, …
   - Pick a distinct slug rather than overwriting an unrelated existing base plan
   - Leave every Status and Session cell empty

7. **Stop.** Report only the saved paths and the stage count, in a few lines. An accepted plan is always on disk before this skill ends.

## Plan file format

This section is the canonical definition of the plan layout and status codes; `/dev-ai-tools` reproduces the codes to stay self-contained.

Example slug `i18n-ui-and-content-language`:

```text
plans/
  i18n-ui-and-content-language.md      # base
  i18n-ui-and-content-language-1.md    # stage 1
  i18n-ui-and-content-language-2.md    # stage 2
  finished/                            # /dev-ai-tools moves completed files here
```

### Base file (`plans/<slug>.md`)

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

Terse dependency list; every stage appears exactly once.
Example: stage 1 before 2 and 3 (parallel-safe with each other); stage 4 after 2 and 3.

## Stages

1. [Short title](./<slug>-1.md) — one-line summary
2. [Short title](./<slug>-2.md) — one-line summary

## Notes

Optional: commit strategy, risks, out of scope.
```

**Status codes** — maintained by `/dev-ai-tools`; leave empty when creating the plan.

| Code | Meaning | Who sets it |
|------|---------|-------------|
| *(empty)* | Not started | — |
| `W` | Working — implementation in progress | **implementer**, also writes Session |
| `V` | Validating — handed to the planner for judgment | **implementer** |
| `R` | Retry — reworking after planner feedback | **implementer**, updates Session |
| `T` | Testing — dedicated test-writing/running pass | the agent doing it, also writes Session |
| `TV` | Testing validation — planner judging tests | **planner** |
| `E` | Error — correction limit exhausted | **planner** |
| `F` | Finished — stage accepted | **planner** |

**Session** column: harness session or agent id (or equivalent resume handle) for the worker active on that stage. Critical for resuming after a network or budget failure.

### Stage file (`plans/<slug>-<n>.md`)

Self-contained: an **implementer** given the base Goal and Execution graph plus this file alone can finish the stage without reading other stage files.

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

## Tests

- Unit (`path_test.go` / `*.spec.ts`): must exercise …
- Integration: …

## Acceptance criteria

- [ ] Observable criterion
- [ ] Build and tests required for this stage pass

## Commit

Suggested message: `feat: …` (or fix/chore/…)

## Dependencies

- Requires stages: … (or none)
- Parallel-safe with: …

## Implementation log

(Append-only. Implementers and planner add sections here during `/dev-ai-tools`.)
```

## Boundaries

- Write only under `plans/`, plus `.gitignore` when adding the `plans/` entry.
- Never spawn an **implementer** for production code, and never invoke `/dev-ai-tools` from inside this skill. In flow mode the caller starts it after this skill has ended — that is the caller's step, not yours.
- Activate only on explicit `/plan-ai-tools`, a skill that names this step, or the global `AGENTS.md` change flow.
