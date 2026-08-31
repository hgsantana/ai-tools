---
name: plan-ai-tools
description: >
  Explore the repository and write a multi-file implementation plan under dev/
  in the planner-ai-tools role. Use for /plan-ai-tools or when a non-trivial
  change needs planning first. Impact: writes only planning files under dev/;
  product code, commits, and remote state remain unchanged.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Planning

Explore a change and write its multi-file implementation plan under `dev/`.

## Workflow

Carry the `planner-ai-tools` role and author a multi-file implementation plan under `dev/`, then stop. Route a change small enough for one commit to the `dev-ai-tools` Task mode and report that choice instead of planning it.

1. **Fix the base branch**: verify the repository root, resolve the named branch currently checked out, and keep it checked out throughout analysis. This analysis branch is `<base>`; if `HEAD` is detached, ask the user to choose and check out a branch before continuing.
2. **Invoke host planning**: request the host harness's strongest planning capability, mode, or skill for the design.
3. **Draft the plan**: structure the delivery into isolated stages where each stage defines a commit boundary. Group tests by type, add a documentation stage if behavior changes, and set explicit stage dependencies.
4. **Save**: write `<base>` into the base plan, then write `dev/<slug>/0-<slug>.md` and each `dev/<slug>/<n>-<slug>.md` as it is drafted, so the plan survives an interrupted session.
5. **Report**: hand over paths as defined in *Report*.

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

Every filename starts with its ordinal, including the base, so directory listings follow execution order and place numbered stages before `F` fix files.

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

## Base branch

`<base>` — the branch analyzed by `plan-ai-tools`; `dev-ai-tools` creates the work branch from it and targets the pull request to it.

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

Leave **Status** and **Agent** empty at creation; `dev-ai-tools` owns them and each stage's Dispatch log.

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

The plan itself is the report. In the user's language, chat gives its base path—opened where supported—a one-line outcome, numbered open questions, and “Implement it?”. **Yes** invokes `dev-ai-tools` against the plan through the `USER-AGENTS.md` gate; **no** stops.

## Boundaries

- Write only under `dev/<slug>/`; `dev-ai-tools` owns `dev/tmp/finished/`.
- Limit this workflow to planning: leave product code and builds unchanged, and leave implementation to `dev-ai-tools` and `implementer-ai-tools`.
- Treat the saved plan as the deliverable until the user accepts it. Acceptance authorizes implementation through the routing gate.
