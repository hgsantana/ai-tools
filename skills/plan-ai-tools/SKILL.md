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

You carry the `planner-ai-tools` role in this session. Author a multi-file implementation plan under `dev/` for the request you were given, then stop. Implementation belongs to `dev-ai-tools`; a change small enough for a single commit belongs to its Task mode, so say so and stop rather than planning it.

1. **Invoke host planning**: delegate the design by requesting that the host harness use the strongest planning capability, mode, or skill it possesses.
2. **Draft the plan**: structure the delivery into isolated stages where each stage defines a commit boundary. Group tests by type, add a documentation stage if behavior changes, and set explicit stage dependencies.
3. **Save**: write the base file `dev/<slug>/0-<slug>.md` and the stage files `dev/<slug>/<n>-<slug>.md` incrementally, as each is drafted rather than all at the end — a plan on disk survives a lost session.
4. **Report** — hand over paths, not prose (*Report*).

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
    finished/<slug>/  # local archive copy, made by `dev-ai-tools` once every stage is terminal
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

**Status** and **Agent** are left empty at creation: `dev-ai-tools` owns them, along with each stage file's Dispatch log.

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

The plan is the report: it is already on disk, so chat gets its base file path — opened in the user's editor where the harness can — rather than a retelling of it. With the path go one line on what the plan does, the numbered questions still open, and the ask: implement it? **Yes** invokes `dev-ai-tools` against those plans (`USER-AGENTS.md` gates that activation); **no** stops. All in the user's language.

## Boundaries

- Write only under `dev/<slug>/`. `dev-ai-tools` owns the archive under `dev/tmp/finished/`.
- Edit no product code, run no verification build, spawn no `implementer-ai-tools`, implement nothing.
- The saved plan is the deliverable until the user accepts it; a plan they have not accepted is never implemented.
