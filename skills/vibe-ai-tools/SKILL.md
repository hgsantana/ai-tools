---
name: vibe-ai-tools
description: >
  Vibe Coding: refine a demand into a user story (product owner), then follow
  plan-ai-tools and dev-ai-tools end to end. Default for any non-trivial
  change. Use for /vibe-ai-tools. Impact: after naming this skill, first iterates
  the story with the user; once agreed, delivery is unattended on a dedicated
  branch (commits, push, PR); edits and removals there can be hard to undo.
  History before the work stays intact. Cloud mutations and destructive or
  shared-state ops still need a separate yes.
argument-hint: "[the demand to deliver]"
---

# Vibe Coding

Refine a demand into a user story with the user, then plan and deliver it end to end.

## Workflow

Operate in the planner category. Run the three steps below in order, then stop. The continue yes is the user's yes to **Vibe Coding mode**. You are carrying the `planner-ai-tools` role in this session.

### 1. Story (product owner)

Derive a kebab-case `<slug>` from the demand.

Read only official repository documentation — root and sub-directory `README.md` / `AGENTS.md`, `docs/`, `CONTRIBUTING`, changelogs, and equivalent published docs. Do not read product code or unofficial notes to learn the repository.

Once the repository's purpose, goals, and contracts are clear, iterate with the user as product owner: ask questions, propose suggestions, close ambiguous points, and refine until the demand is fully mapped and understood. Prefer the smaller story when the demand hides several. Challenge what conflicts with the documentation.

When the story is agreed, write `dev/tmp/vibe/story-<slug>.md`: problem, motivation, scope in and out, acceptance, fit with documented purpose. Do not start planning until that file is on disk and the user has agreed the story.

### 2. Vibe Coding mode

After the story is saved: deliver unattended — plan, decisions on open questions, implementation, commits, push, pull request. All work lands on a dedicated branch. History predating the work stays intact. Scope ends at the pull request.

You decide open questions that arise after the story is saved: scope, trade-offs the docs do not settle, correction strategy, `E`-stage remediation within scope, and the archival question a plan left with an `E` returns. Log each to `dev/tmp/vibe/decisions-<slug>.md` before acting: the question, the decision, the trade-offs. Anything the Security rules reserve for the user returns as an approval request. Never self-approve those.

#### A. Plan

Read `$HOME/.ai-tools/skills/plan-ai-tools/SKILL.md` and follow it in full, using the story file path as the request. The routing gate already passed — do not re-gate. After the plan files are on disk, continue — skip that skill's Report (asking whether to implement) and any Boundary that would stop this run.

#### B. Execute

Read `$HOME/.ai-tools/skills/dev-ai-tools/SKILL.md` and follow it in full against the plan just produced, naming that plan (its slug / `dev/<slug>/`) as the work to execute. Do not re-gate. The continue yes already covers the push and the pull request that workflow names — run them without a further checkpoint. Cloud mutations and other destructive or shared-state operations still stop for a separate yes.

## Writes

Own writes stay under `dev/tmp/vibe/` (story, decisions). Plan files and product code are written only as plan-ai-tools and dev-ai-tools prescribe.

## Report

Summarize the outcome in chat, in the user's language: the story path, the execution summary, the pull request or branch, and the decisions file — opened by path.

## Boundaries

- Operate in the planner category for this run.
- Stay inside the working repository. The sole exception is a file a harness requires outside the repository by design.
- Writes under `dev/tmp/vibe/` (and re-reads of those files) are the sole gitignored exception.
- History predating this work stays intact: no force-push, no rewriting pre-existing commits, no deleting branches other than the plan's own.
