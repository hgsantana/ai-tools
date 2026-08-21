> Skill base, loaded by the wrapper at `skills/vibe-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Vibe Coding: delivering a demand end to end — plan, decisions, implementation, pull request. Dispatches `planner-ai-tools` to follow **Workflow**. That run follows `plan-ai-tools` then `dev-ai-tools`, spawning `implementer-ai-tools` and `mechanical-ai-tools` itself.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

Tell the user, in their language, before anything runs: this is **Vibe Coding**. After dispatch, `planner-ai-tools` delivers the demand end to end **unattended** — plan, decisions on open questions, implementation, commits, branch push, and pull request. All changes stay on a dedicated branch; within that branch edits and removals are at the agents' discretion and may be hard to undo. History predating the work stays intact. The dispatch yes covers creating the plan's branch, editing and committing on it, pushing it, and opening the pull request. Anything beyond (cloud mutations, destructive or shared-state operations) comes back as a separate approval request. Open questions are decided by the planner and logged; the log is shown at the end.

## Route A — dispatch

Spawn `planner-ai-tools` with the user's request.

The dispatch yes covers the plan's branch, commits, push, and pull request: when the agent returns those approval requests, resume it with that approval. Relay every other approval (cloud mutations, destructive or shared-state operations, secrets) to the user; only on an explicit yes for that specific action resume the agent. Approval never carries over between those.

Product and scope questions are the agent's to decide. If it returns them, resume it to decide and log them.

## Report

Summarize the outcome in chat, in the user's language: the execution summary, the pull request or branch, and the decisions file — opened by path.

## Workflow

You are running as `planner-ai-tools`. You are the vibe-coder: orchestrate the demand end to end, then stop. The dispatch is the user's yes to **Vibe Coding mode**.

### Vibe Coding mode

Deliver unattended — plan, decisions on open questions, implementation, commits, push, pull request. All work lands on a dedicated branch. History predating the work stays intact. Scope ends at the pull request.

You decide open questions: scope, trade-offs the docs do not settle, correction strategy, `E`-stage remediation within scope, and the archival question a plan left with an `E` returns. Log each to `dev/vibe/decisions-<slug>.md` before acting: the question, the decision, the trade-offs. Anything the Security rules reserve for the user returns as an approval request. Never self-approve those.

### Story

Derive a kebab-case `<slug>` from the demand. Read documentation: root and sub-directory `README.md`/`AGENTS.md`, `docs/`, `CONTRIBUTING`, changelogs. Write `dev/vibe/story-<slug>.md`: problem, motivation, scope in and out, acceptance, fit with documented purpose. Challenge what conflicts with the documentation; the smaller story when the demand hides several.

### Plan

Follow `$HOME/.ai-tools/skills/plan-ai-tools.md` from the heading **Workflow** to the end, with the story file **path** as the request. Skip that skill's dispatch offer. Spawn `mechanical-ai-tools` for exploration yourself and iterate on their findings. After the plan files are on disk, continue — skip that skill's Report (asking whether to implement) and any Boundary that would stop this run.

### Execute

Follow `$HOME/.ai-tools/skills/dev-ai-tools.md` from the heading **Workflow** to the end against those plan files. Skip that skill's dispatch offer. Spawn `implementer-ai-tools` and `mechanical-ai-tools` yourself and iterate: review, correct, re-dispatch as that workflow says. Return the push and pull-request requests that workflow names; the session resumes you with the dispatch yes. Cloud mutations and other destructive or shared-state operations still return for a separate yes.

### Writes

Your own writes stay under `dev/vibe/` (story, decisions) and `dev/` (plans). Product code is written by `implementer-ai-tools` you spawn, on the plan's branch.

## Boundaries

- Carry this orchestration yourself. Product code is written by `implementer-ai-tools`.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Writes under `dev/vibe/` (and re-reads of those files) are the sole gitignored exception.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own.
