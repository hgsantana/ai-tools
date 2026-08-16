---
name: plan-ai-tools
description: >
  Restricted-invocation skill — invoke only when (a) the user runs "/plan-ai-tools",
  (b) another skill's documented workflow calls it by name, or (c) the planner-ai-tools
  agent runs it. Explores the repository and writes a multi-file implementation plan
  under plans/, then stops. Never implements code.
argument-hint: "[description of the change, feature, or fix to plan]"
---

# Plan

## Entry gate — required category: planner

This skill must run on a **planner** model. Before anything else:

1. Decide whether you are one (*Agent categories*, in the global agent instructions).
2. **You are** — run the skill here, spawning the subagents it names.
3. **You are not, or cannot tell** — do not start it and do not delegate it. Send one short chat message in
   the user's language: name the model running this session (or say the harness does not expose it); say how
   to get a planner here — switch this session to the harness's strongest model, or start the work over from
   the `planner-ai-tools` agent, which is pinned to one; then ask whether to run anyway. Wait for the answer.
4. **Yes** — run the skill here, as its planner, for the rest of the session; ask again only if the model
   changes. **No, or no answer** — stop here: no exploration, no writes, no spawns.

Name the stake in that message, so the answer is an informed one: every stage that follows is shaped by this plan, and the implementation runs on top of it.

**Category roles** (see the global agent instructions):

| Role here | Category |
|-----------|----------|
| You, running this skill | **planner** (settled by entry gate) |
| Exploration subagents | **mechanical** (read-only) or harness explore type |
| Implementation | Not used |

## Purpose

Author a multi-file implementation plan under `plans/` and stop. Never edit source code, run tests, or spawn implementers.

## Invocation modes

| Mode | Trigger | Reaching the user | After saving |
|------|---------|-------------------|--------------|
| **In session** | User types `/plan-ai-tools`, or a calling skill | Directly — ask, iterate, confirm | Stop. Never implement, never invoke `/dev-ai-tools`. |
| **As agent** | The `planner-ai-tools` agent runs it | **Not at all.** Return open questions and let the session relay them | Return the plan paths plus a five-line summary. The session asks the user whether to implement. |

In agent mode you have no channel to the user: never block waiting for an answer. Stop and return the
questions — numbered, each with the options you see and your recommendation — and continue when the session
resumes you with the answers.

## Workflow

1. **Clarify task & scope**: Resolve ambiguities and explicit out-of-scope boundaries up front — asking the user in session mode, returning the questions in agent mode.
2. **Read sources of truth**: Repository root and sub-directory `README.md`/`AGENTS.md`, plus `$HOME/AGENTS.md` if present.
3. **Explore codebase**: Spawn read-only **mechanical** agents in parallel for broad discovery; use direct read/grep for pinpoint lookups. Announce each spawn in chat.
4. **Draft plan**: Base file + stage files (isolated, explicit paths with reasons, tests split by type, docs stage if behavior changes, Conventional Commit boundaries, sequential/parallel tags).
5. **Settle the plan**: In session mode, present it in the user's language (goal, stages, files, tests, risks, out-of-scope boundaries) and iterate until accepted. In agent mode, return anything still open instead. Saved files follow English disk rules.
6. **Save**: Write base `plans/<slug>.md` and stage `plans/<slug>-<n>.md` files with empty Status/Agent cells. Leave the repository's `.gitignore` alone unless the user asks for it.
7. **Stop**: Report saved paths and stage count — in chat, or in the return payload.

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

- Write only under `plans/`.
- Never edit code, run verification builds, or invoke `/dev-ai-tools`.
- Never delegate this skill to a subagent.
- Activate only via `/plan-ai-tools`, a calling skill, or the `planner-ai-tools` agent.
