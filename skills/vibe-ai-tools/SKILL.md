---
name: vibe-ai-tools
description: >
  Deliver a demand end to end: spawn planner-ai-tools following plan-ai-tools
  with user relay, then execute the approved plan as dev-ai-tools to completion.
  Default for non-trivial changes. Use for /vibe-ai-tools. Impact: plans with
  user review, then delivers unattended on a dedicated branch (commits, push,
  PR); edits and removals there can be hard to undo. History before the work
  stays intact. Cloud mutations and destructive ops still need a separate yes.
argument-hint: "[the demand to deliver]"
---

# Vibe Coding

Deliver a demand end to end: plan with the user via `planner-ai-tools`, then execute the approved plan to completion following `dev-ai-tools`.

## Workflow

Operate in the planner category. Run the two steps below in order, then stop. You carry the `planner-ai-tools` role in this session.

### 1. Plan (planner relay)

Derive a kebab-case `<slug>` from the demand.

1. **Spawn planner**: announce the spawn in the user's language, then spawn `planner-ai-tools`.
2. **Brief**: instruct `planner-ai-tools` to follow the `plan-ai-tools` skill in its entirety (workflow, multi-file format `dev/<slug>/0-<slug>.md` and `dev/<slug>/<n>-<slug>.md`, truth on disk, and boundaries), passing the user's request as the input demand.
3. **User relay**: act as a relay between `planner-ai-tools` and the user:
   - Relay questions, ambiguities, or design choices raised by `planner-ai-tools` to the user in chat (in the user's language).
   - Resume or re-dispatch `planner-ai-tools` with the user's answers.
4. **Plan approval**: when `planner-ai-tools` finishes drafting the plan files under `dev/<slug>/`, present the base plan path, stage file paths, and summary in chat (in the user's language). Ask the user for explicit approval to execute the plan. Do not proceed to execution until the user explicitly accepts the plan.

### 2. Execute (full delivery)

Once the user approves the plan:

1. **Full intake**: read the accepted plan in its entirety — the base plan (`dev/<slug>/0-<slug>.md`) and all stage files (`dev/<slug>/<n>-<slug>.md`) — along with the repository `README.md`, instructions and official repository documentation (`docs/`, `CONTRIBUTING`, etc.).
2. **Execute as `dev-ai-tools`**: follow the `dev-ai-tools` skill completely to the end of delivery:
   - Create and switch to the dedicated branch `plan/<slug>`, committing the initial plan files.
   - Execute stages sequentially according to the execution graph, maintaining context isolation and dispatch ledgers.
   - Dispatch `implementer-ai-tools` (and `mechanical-ai-tools` for tests/evidence) with self-contained stage briefs.
   - Inspect diffs, audit tests, and validate against acceptance criteria before committing each stage.
   - On completion of all stages, archive the plan set to `dev/tmp/finished/<slug>`, commit the plan removal as `chore(dev): archive <slug>`, and push `plan/<slug>` to open the pull request unattended.
   - If any stage terminates in `E`, stop archival and return the approval items to the user.
   - Cloud mutations and destructive operations always stop for explicit user approval.

## Report

Summarize the delivery in chat, in the user's language: the plan slug, commits created, validation results, local archive path (`dev/tmp/finished/<slug>`), and the opened pull request URL (or local review patch path).

## Boundaries

- Operate in the planner category for this run.
- Spawn depth is one: only this session spawns agents.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own.
