> Skill base, loaded by the wrapper at `skills/plan-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Designing a change: exploring the repository and writing a multi-file implementation plan under `dev/`, then stopping. Dispatches `planner-ai-tools` to follow **Workflow**. Plan only inside that dispatch. Never implement under this skill.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

No destructive stake: planning writes only under `dev/` and changes no product code. Say so in one line — the user is choosing a route, not accepting a risk.

## Route A — dispatch

The agent cannot reach the user, so it returns open questions instead of asking them. Relay them in the user's language, collect the answers, and resume the same agent with them — reusing its context where the harness allows.

## Report

- Report in chat, in the user's language: a few lines on what the plan does plus the plan file paths.
- Ask whether to implement. **Yes** — invoke the `dev-ai-tools` skill against those plans, which offers its own routes and surfaces its stake. **No** — stop; the saved plan is the deliverable.
- The saved plan is the deliverable until the user accepts it. Never implement a plan they have not accepted.

## Workflow

You are running as `planner-ai-tools`. Author a multi-file implementation plan under `dev/` for the request you were given, then stop.

## Decisions that are the user's

Ask them — numbered when there are several, each with the options you see and your recommendation — and continue with the answers: scope boundaries, trade-offs the repository's documentation does not settle, and anything the Security rules reserve for the user. Never guess one.

## Workflow

1. **Clarify task & scope**: resolve ambiguities and explicit out-of-scope boundaries up front — returning open questions when they are the user's to answer.
2. **Read sources of truth**: repository root and sub-directory `README.md`/`AGENTS.md`, plus `$HOME/AGENTS.md` if present.
3. **Explore the codebase**: spawn read-only `mechanical-ai-tools` in parallel for broad discovery; use direct read/grep for pinpoint lookups.
4. **Draft the plan**: base file + stage files (isolated, explicit paths with reasons, tests split by type, docs stage if behavior changes, Conventional Commit boundaries, sequential/parallel tags).
5. **Save**: write base `dev/<slug>/0-<slug>.md` and stage `dev/<slug>/<n>-<slug>.md` files with empty Status/Agent cells, incrementally as they are drafted rather than only at the end — a planner that dies mid-run must leave its partial draft on disk for a successor to resume (*Truth on disk*).
6. **Report**: the base plan path, the stage file paths, and at most five lines of summary — every other detail stays on disk. Anything still open is a numbered question.

## Where plans live

- `dev/` in the working repository holds every plan. Outside a git repository, write to `$HOME/.ai-tools-plans` (Windows: `%USERPROFILE%\.ai-tools-plans`) instead — the same per-plan directory layout applies there too.
- In a git repository each plan is a versioned directory `dev/<slug>/`: keep it out of ignore rules and include it in path-scoped commits. Generated state is transient and lives under one ignored root, `dev/tmp/`; the whole ignore policy is the single rule `/dev/tmp/`.
- `dev/tmp/` (ad-hoc briefs and feedback for `dev-ai-tools`, plus `dev/tmp/finished/` and `dev/tmp/vibe/`) stays out of the plan queue. Plan only as `dev/<slug>/0-<slug>.md`.
- A plan is **working state, not a historical record**: it is versioned so an execution survives a lost session, a new machine, or a fresh clone. It earns its place in the repository only while it still has to be resumed — `dev-ai-tools` removes it from the tree when the work ships.
- Plan files hold the detail — steps, validation notes, command output. Chat gets a short summary and file links.

## Truth on disk

Durable state — anything a later agent, a retry, or a recovery will depend on — lives in files. Context windows overflow and runs die mid-draft; a file survives both.

- Write before you depend on it: it is on disk before the turn ends or the spawn happens.
- Communicate by reference: pass file paths, not file contents.
- On conflict, the file wins over any message or recollection.

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
Example: 1 before 2 and 3 (parallel-safe); 4 after 2 and 3.

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
| `TV` | Testing validation — test review | **testing agent** |
| `E` | Error — correction limit exhausted | `planner-ai-tools` |
| `F` | Finished — stage accepted | `planner-ai-tools` |

**Agent**: who is working the stage — agent name plus the concrete model dispatched. Per-attempt history lives in the stage file's Dispatch log, maintained by `dev-ai-tools`.

### Stage file (`dev/<slug>/<n>-<slug>.md`)

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

- Write only under `dev/`. `dev-ai-tools` owns the archive under `dev/tmp/finished/`.
- Never edit product code, run verification builds, spawn `implementer-ai-tools`, or implement anything.
- The saved plan is the deliverable; the session decides with the user whether to implement it.
