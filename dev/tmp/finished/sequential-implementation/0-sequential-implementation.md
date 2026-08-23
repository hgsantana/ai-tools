# Sequential implementation only

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools (sonnet) |
| 2 | F | implementer-ai-tools (sonnet) |
| 3 | F | implementer-ai-tools (sonnet) |

## Goal

Implementation stops running in parallel: every subagent that writes product files runs one at
a time, in the plan's stage order. Read-only work — exploration, research, builds, tests,
evidence collection — keeps its concurrency. The wave / concurrent-batch model leaves
`dev-ai-tools`, the parallel tags leave the plan format, and the rule is stated once in the
README, in `USER-AGENTS.md`, and in the planner base.

## Execution graph

1 before 2; 3 after 2. Stages run one at a time, in that order.

## Stages

1. [Serial execution loop](./1-sequential-implementation.md) — `dev-ai-tools` dispatches one writer at a time; waves and concurrent batches removed
2. [Plan format without parallel tags](./2-sequential-implementation.md) — drop `sequential/parallel` tags and `Parallel-safe with:`; stage order stays
3. [State the rule once](./3-sequential-implementation.md) — README rule 8, `USER-AGENTS.md`, planner base, version bump

## Notes

- Source of truth: `README.md` rules (rule 1–2). Story: `dev/tmp/vibe/story-sequential-implementation.md`. Decisions: `dev/tmp/vibe/decisions-sequential-implementation.md`.
- Text-only change: no scripts, no wrappers, no `MODELS.md`, no new lint check (decision D5).
- Caps to respect: `USER-AGENTS.md` 8,000 characters (rule 3), skill `description` 500 characters (rule 9), wrapper 1,000 characters (rule 6). Skill bodies have no cap; rule 15 (extreme conciseness) and rule 16 (state the positive) still apply.
- Commit boundary per stage; Conventional Commits. `tools/lint.sh` and `tools/test.sh` must pass at stage 3.
- Out of scope: parallel read-only exploration in `plan-ai-tools` step 3 and `agents/planner-ai-tools.md` step 3 stays; spawn depth, the three agents, and the routing gate are untouched.
