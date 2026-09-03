---
name: vibe-ai-tools
description: >
  Deliver a demand end to end: plan through planner-ai-tools with user relay,
  then execute the approved plan through dev-ai-tools. Default for non-trivial
  changes; use for /vibe-ai-tools. Impact: after review, works unattended on a
  dedicated branch, commits, pushes, and opens a PR; edits and removals can be
  hard to undo. Pre-existing history stays intact. Cloud and destructive
  operations still require a separate yes. Min. role: planner.
argument-hint: "[the demand to deliver]"
---

# Vibe Coding

Plan a demand with the user through `planner-ai-tools`, then deliver the approved plan through `dev-ai-tools`.

## Workflow

Carry the `planner-ai-tools` role and run these two steps in order, then stop.

### 1. Plan (planner relay)

Derive a kebab-case `<slug>` from the demand.

1. **Spawn planner**: announce the spawn in the user's language, then spawn `planner-ai-tools`.
2. **Brief**: pass the user's request and instruct `planner-ai-tools` to follow the complete `plan-ai-tools` skill, including its workflow, multi-file format, disk-based source of truth, and boundaries.
3. **User relay**: act as a relay between `planner-ai-tools` and the user:
   - Relay questions, ambiguities, and design choices from `planner-ai-tools` to the user in the user's language.
   - Resume or re-dispatch `planner-ai-tools` with the user's answers.
4. **Plan approval**: when the plan under `dev/<slug>/` is complete, give the user its base path—opened where supported—and a one-line outcome. Ask for explicit approval; execution begins after that yes.

### 2. Execute (full delivery)

After approval, follow `dev-ai-tools` in Plan mode against `dev/<slug>/` through branch creation, sequential stages, validation, archival, push, and pull request. Its stop conditions remain in force: a blocker, a decision uncovered during implementation, or an approval reserved by the Security rules.

One deviation applies: because this gate promised an unattended run, decide how to handle a failed stage instead of returning the archival choice. Record the choice and rationale in `dev/tmp/vibe/<slug>-decisions.md`, creating it when needed.

## Report

`dev-ai-tools` writes `dev/tmp/<slug>-report.md`. In the user's language, chat gives that path—opened where supported—a one-line outcome, and the pull request URL or local review-patch path. Other chat content is limited to relayed planning questions and final approval.

## Boundaries

- Operate in the planner category for this run.
- Spawn the agent that owns each piece of work; carry allowed work here when spawning fails.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Preserve all history that predates this work: never force-push, rewrite pre-existing commits, or delete another branch. The plan's own branch may be deleted.
