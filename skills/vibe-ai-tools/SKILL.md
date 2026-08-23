---
name: vibe-ai-tools
description: >
  Vibe Coding — deliver a demand end to end (plan, decisions, implementation, pull
  request) carried in this session under the planner-ai-tools role. That run follows
  plan-ai-tools then dev-ai-tools. Use for /vibe-ai-tools or whenever a demand
  should be delivered end to end. The default for any non-trivial change.
argument-hint: "[the demand to deliver]"
---

# Vibe Coding

Delivering a demand end to end — plan, decisions, implementation, pull request.

## Continue?

This skill expects this session to be the **planner** (`MODELS.md` planner cell for this harness).

Before anything is read, run, or changed, send **one** short message in the user's language:

1. The stake (**Stake** below).
2. Whether this session is the planner: read this harness's `planner` cell in `$HOME/.ai-tools/MODELS.md` and compare it with the session model.
   - They match — this session is the planner. Say so in one line.
   - They differ, or the session model is undetermined — this session is not the planner. Name the session model, or say it is undetermined, and name how to change the session model in this harness (`MODELS.md` last column).
3. Then ask: do you want to continue?
   - a) yes
   - b) no

Wait for an explicit answer. Never pick for the user.

- **No** (or anything that is not yes) — stop. Nothing is read, run, or changed.
- **Yes** — this session carries `planner-ai-tools` (base `$HOME/.ai-tools/agents/planner-ai-tools.md`; on Windows `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`) and follows **Workflow**. Announce every spawn in the user's language with the agent name. Spawn depth is one.

Proceeding on a non-planner session is the user's call. This skill never refuses over the session model.

## Stake

Tell the user, in their language, before anything runs: this is **Vibe Coding**. Once they say yes, this session carries `planner-ai-tools` and delivers the demand end to end **unattended** — plan, decisions on open questions, implementation, commits, branch push, and pull request. All changes stay on a dedicated branch; within that branch edits and removals are at this run's discretion and may be hard to undo. History predating the work stays intact. That yes covers creating the plan's branch, editing and committing on it, pushing it, and opening the pull request. Anything beyond (cloud mutations, destructive or shared-state operations) comes back as a separate approval request. Open questions are decided in the planner role and logged; the log is shown at the end.

## Workflow

You are carrying the `planner-ai-tools` role in this session. You are the vibe-coder: orchestrate the demand end to end, then stop. The continue yes is the user's yes to **Vibe Coding mode**.

### Vibe Coding mode

Deliver unattended — plan, decisions on open questions, implementation, commits, push, pull request. All work lands on a dedicated branch. History predating the work stays intact. Scope ends at the pull request.

You decide open questions: scope, trade-offs the docs do not settle, correction strategy, `E`-stage remediation within scope, and the archival question a plan left with an `E` returns. Log each to `dev/tmp/vibe/decisions-<slug>.md` before acting: the question, the decision, the trade-offs. Anything the Security rules reserve for the user returns as an approval request. Never self-approve those.

### Story

Derive a kebab-case `<slug>` from the demand. Read documentation: root and sub-directory `README.md`/`AGENTS.md`, `docs/`, `CONTRIBUTING`, changelogs. Write `dev/tmp/vibe/story-<slug>.md`: problem, motivation, scope in and out, acceptance, fit with documented purpose. Challenge what conflicts with the documentation; the smaller story when the demand hides several.

### Plan

Follow `$HOME/.ai-tools/skills/plan-ai-tools/SKILL.md` from the heading **Workflow** to the end, with the story file **path** as the request. Skip that skill's **Continue?** gate. Spawn `mechanical-ai-tools` for exploration and iterate on their findings. After the plan files are on disk, continue — skip that skill's Report (asking whether to implement) and any Boundary that would stop this run.

### Execute

Follow `$HOME/.ai-tools/skills/dev-ai-tools/SKILL.md` from the heading **Workflow** to the end against those plan files. Skip that skill's **Continue?** gate. Spawn `implementer-ai-tools` and `mechanical-ai-tools` and iterate: review, correct, re-dispatch as that workflow says. The continue yes already covers the push and the pull request that workflow names — run them without a further checkpoint. Cloud mutations and other destructive or shared-state operations still stop for a separate yes.

### Writes

Your own writes stay under `dev/tmp/vibe/` (story, decisions) and `dev/<slug>/` (the plan directory). Product code is written by `implementer-ai-tools` you spawn, on the plan's branch.

## Report

Summarize the outcome in chat, in the user's language: the execution summary, the pull request or branch, and the decisions file — opened by path.

## Boundaries

- Carry this orchestration yourself. Product code is written by the `implementer-ai-tools` you spawn.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Writes under `dev/tmp/vibe/` (and re-reads of those files) are the sole gitignored exception.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own.
