---
name: plan-ai-tools
description: >
  Explore the repository and write a multi-file implementation plan under
  dev/, then stop — carried in this session under the planner-ai-tools role.
  Use for /plan-ai-tools or whenever a non-trivial change should be planned
  first. Impact: none destructive — writes only under dev/; no product code,
  no commits, no push.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Planning

Designing a change: exploring the repository and writing a multi-file implementation plan under `dev/`, then stopping.

## Workflow

You carry the `planner-ai-tools` role in this session. Author a multi-file implementation plan under `dev/` for the request you were given, then stop. Never implement under this skill.

1. **Invoke host planning**: delegate the design by requesting that the host harness use the strongest planning capability, mode, or skill it possesses.
2. **Draft the plan**: structure the delivery into isolated stages where each stage defines a commit boundary. Group tests by type, add a documentation stage if behavior changes, and set explicit stage dependencies.
3. **Save**: write the base file `dev/<slug>/0-<slug>.md` and stage files `dev/<slug>/<n>-<slug>.md` with empty Status/Agent cells, incrementally as they are drafted rather than only at the end (*Truth on disk*).
4. **Report**: state the base plan path, stage file paths, and at most five lines of summary in chat. Anything open remains a numbered question to the user. Ask whether to implement via `dev-ai-tools`.

## Plan file format

Canonical format for multi-file plans (`dev-ai-tools` reads and updates these):

```text
dev/
  <slug>/
    0-<slug>.md       # base plan
    1-<slug>.md       # stage 1
    2-<slug>.md       # stage 2
    F1-<slug>.md      # fix file, added by `dev-ai-tools` during corrections
  tmp/
    finished/<slug>/  # the whole plan directory, moved here by `dev-ai-tools` in one move, only once every stage is terminal (`F` or `E`)
```

The ordinal is first on every file, base included, so a listing of `dev/<slug>/` reads in order — digits sort before the `F` of a fix file.

### Base file (`dev/<slug>/0-<slug>.md`)

```markdown
# <Title>

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | | |
| 2 | | |

## Goal

1–3 sentences: what changes and why.

## Execution graph

Dependency list; every stage appears exactly once.
Example: 1 before 2 and 3; 4 after 2 and 3.
Stages run one at a time, in an order consistent with these dependencies.

## Stages

1. [Short title](./1-<slug>.md) — one-line summary
2. [Short title](./2-<slug>.md) — one-line summary

## Notes

Optional: commit strategy, risks, out of scope.
```

**Status codes** (maintained by `dev-ai-tools`; left empty at creation):

| Code | Meaning | Set by |
|------|---------|--------|
| *(empty)* | Not started | — |
| `W` | Working — implementation in progress | `planner-ai-tools` |
| `V` | Validating — ready for planner review | `implementer-ai-tools` |
| `R1`, `R2`, `R3` | Retry 1, 2, 3 — rework after feedback | `planner-ai-tools` |
| `T` | Testing — dedicated test pass | `planner-ai-tools` |
| `TV` | Testing validation — test review | `mechanical-ai-tools` |
| `E` | Error — correction limit exhausted | `planner-ai-tools` |
| `F` | Finished — stage accepted | `planner-ai-tools` |

**Agent**: who is working the stage — agent name plus the concrete model dispatched. Per-attempt history lives in the stage file's Dispatch log, maintained by `dev-ai-tools`.

### Stage file (`dev/<slug>/<n>-<slug>.md`)

Self-contained: implementable from base Goal/Execution graph and this file alone. Each stage file defines a single Conventional Commit boundary.

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
- [ ] Build and required tests pass

## Commit

Suggested message: `feat: …` (or fix/chore/…)

## Dependencies

- Requires stages: … (or none)

## Implementation log

(Append-only log added by implementers and planner during execution.)
```

## Report

- Report in chat, in the user's language: a few lines on what the plan does plus the plan file paths.
- Ask whether to implement. **Yes** — invoke the `dev-ai-tools` skill against those plans (`USER-AGENTS.md` gates that activation). **No** — stop; the saved plan is the deliverable.
- The saved plan is the deliverable until the user accepts it. Never implement a plan they have not accepted.

## Boundaries

- Write only under `dev/`. `dev-ai-tools` owns the archive under `dev/tmp/finished/`.
- Never edit product code, run verification builds, spawn `implementer-ai-tools`, or implement anything.
- The saved plan is the deliverable; decide with the user whether to implement it.
