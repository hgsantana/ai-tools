# Plan

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

**Category roles** (see global `AGENTS.md`):

| Role here | Category |
|-----------|----------|
| You, running this skill | **planner** (settled by entry gate) |
| Exploration subagents | **mechanical** (read-only) or harness explore type |
| Implementation | Not used |

## Purpose

Author a multi-file implementation plan under `plans/` and stop. Never edit source code, run tests, or spawn implementers.

## Invocation modes

| Mode | Trigger | Behavior after saving plan |
|------|---------|----------------------------|
| **Direct** | User types `/plan-ai-tools` | Stop. Never implement or propose implementing. |
| **Flow** | Global change flow or calling skill | Stop and return control to caller. Acceptance request must state execution starts immediately and list covered plans (`plans/*.md`, excluding stage/finished files). |

## Workflow

1. **Clarify task & scope**: Resolve ambiguities and explicit out-of-scope boundaries up front.
2. **Read sources of truth**: Repository root and sub-directory `README.md`/`AGENTS.md`, plus `$HOME/AGENTS.md` if present.
3. **Explore codebase**: Spawn read-only **mechanical** agents in parallel for broad discovery; use direct read/grep for pinpoint lookups. Announce each spawn in chat.
4. **Draft plan**: Base file + stage files (isolated, explicit paths with reasons, tests split by type, docs stage if behavior changes, Conventional Commit boundaries, sequential/parallel tags).
5. **Get acceptance**: Present in user's language (goal, stages, files, tests, risks, out-of-scope boundaries). Iterate until accepted. Saved files follow English disk rules.
6. **Save**: Ensure `plans/` is in `.gitignore`. Write base `plans/<slug>.md` and stage `plans/<slug>-<n>.md` files with empty Status/Agent cells.
7. **Stop**: Report saved paths and stage count in chat.

## Plan file format

Canonical format for multi-file plans (`/dev-ai-tools` reads and updates these):

```text
plans/
  <slug>.md           # base plan
  <slug>-1.md         # stage 1
  <slug>-2.md         # stage 2
  finished/           # completed files moved here by /dev-ai-tools
```

### Base file (`plans/<slug>.md`)

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
Example: 1 before 2 and 3 (parallel-safe); 4 after 2 and 3.

## Stages

1. [Short title](./<slug>-1.md) — one-line summary
2. [Short title](./<slug>-2.md) — one-line summary

## Notes

Optional: commit strategy, risks, out of scope.
```

**Status codes** (maintained by `/dev-ai-tools`; left empty at creation):

| Code | Meaning | Set by |
|------|---------|--------|
| *(empty)* | Not started | — |
| `W` | Working — implementation in progress | **planner** |
| `V` | Validating — ready for planner review | **implementer** |
| `R1`, `R2`, `R3` | Retry 1, 2, 3 — rework after feedback | **planner** |
| `T` | Testing — dedicated test pass | **planner** |
| `TV` | Testing validation — test review | **testing agent** |
| `E` | Error — correction limit exhausted | **planner** |
| `F` | Finished — stage accepted | **planner** |

**Agent**: Who is working the stage — category plus the concrete model or skill dispatched (e.g., `implementer / <model>`). Per-attempt history and session IDs live in the stage file's Dispatch log, maintained by `/dev-ai-tools`.

### Stage file (`plans/<slug>-<n>.md`)

Self-contained: implementable from base Goal/Execution graph and this file alone.

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
- Parallel-safe with: …

## Implementation log

(Append-only log added by implementers and planner during execution.)
```

## Boundaries

- Write only under `plans/` and `.gitignore`.
- Never edit code, run verification builds, or invoke `/dev-ai-tools`.
- Never delegate this skill to a subagent.
- Activate only via `/plan-ai-tools`, calling skills, or global change flow.
