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
4. **Plan approval**: when `planner-ai-tools` finishes drafting the plan files under `dev/<slug>/`, give the user the base plan path — opened in their editor where the harness can — with one line on what it does, and ask for explicit approval to execute it. Execution waits on that yes.

### 2. Execute (full delivery)

Once the user approves the plan, follow the `dev-ai-tools` skill in Plan mode against `dev/<slug>/`, to the end of delivery: branch, sequential stages, validation, archival, push, and pull request. Its rules govern the run, including the ones that stop it — a blocker, a decision the implementation uncovered, or an approval the Security rules reserve.

The one deviation: this gate already promised no further checkpoints, so a plan ending with a failed stage does not return the archival choice — decide it, and record the choice and its reasoning in the decisions file.

## Report

`dev-ai-tools` already wrote the delivery report to `dev/tmp/<slug>-report.md`. Chat gets that path — opened in the user's editor where the harness can — plus one line of outcome and the pull request URL (or the local review patch path), in the user's language. The relayed planning questions and the final approval are the only other things this skill puts on screen.

## Boundaries

- Operate in the planner category for this run.
- Spawn depth is one: only this session spawns agents.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own.
