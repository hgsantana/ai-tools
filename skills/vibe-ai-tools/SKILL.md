---
name: vibe-ai-tools
description: >
  Plan a change under dev/, then execute that plan through dev-ai-tools,
  deciding in-scope implementation questions. Use for /vibe-ai-tools.
  Impact: after the plan is on disk, edits on a dedicated branch, commits,
  pushes, and opens a pull request unattended; edits and removals can be hard
  to undo. Pre-existing history remains intact. Cloud and destructive
  operations require separate approval. Agent: planner-ai-tools.
argument-hint: "[the change to deliver]"
---

# Vibe Coding

Plan a change under `dev/`, then execute that plan.

## Workflow

This file is the brief for the dispatched agent. Execute the Workflow.

### 1. Plan

Follow the Workflow in `$HOME/.ai-tools/skills/plan-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\plan-ai-tools\SKILL.md`) in this run — do not spawn another `planner-ai-tools` for planning. Write `dev/<slug>/` to disk. Skip that skill's `/dev-ai-tools` offer.

### 2. Execute

Only after those plan files exist on disk, read `$HOME/.ai-tools/skills/dev-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\dev-ai-tools\SKILL.md`) and follow it against that specified slug.

During implementation, decide in-scope questions and a failed-stage (`E`) choice yourself instead of returning them to the user. Record each choice and rationale in `dev/tmp/vibe/<slug>-decisions.md`, creating it when needed. Stop conditions that remain: a blocker you cannot resolve, or an approval reserved by the Security rules.

## Report

`dev-ai-tools` writes `dev/tmp/<slug>-report.md`. In the user's language, chat gives that path—opened where supported—a one-line outcome, and the pull request URL or the local review-patch path. Other chat content is limited to planning questions before the plan is on disk, and final approval reserved by Security.

## Boundaries

- Spawn the agent that owns each piece of work; carry allowed work here when spawning fails.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Preserve all history that predates this work: never force-push, rewrite pre-existing commits, or delete another branch. The plan's own branch may be deleted.
