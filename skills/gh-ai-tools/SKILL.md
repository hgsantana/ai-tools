---
name: gh-ai-tools
description: >
  Run the gh-ai-tools work — query or manage GitHub via the GitHub CLI (gh) — carried in this session under the planner-ai-tools role. Use for /gh-ai-tools or whenever the user asks about GitHub
  repositories, pull requests, issues, releases, or workflows, or wants something created, changed,
  or removed there.
argument-hint: "[what to inspect or change on GitHub]"
---

# GitHub

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`).

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

Tell the user, in their language, before anything runs: this work touches GitHub, where actions can merge, close, comment, push, and delete — visible to other people immediately and often irreversible. A mutation runs only after their explicit approval for that specific action.

## Workflow

Use the GitHub CLI (`gh`) for issues, pull requests, checks, releases, and repositories on the request you were given, then stop.

### Rules

- Run **read-only / query** commands freely (list, view, status, checks, diff).
- Put each proposed mutation to the user as its own request — command, target, reason, and blast impact — and run it only on an explicit yes for that action. Approval never carries over between actions. Never create, modify, close, merge, comment on, or remove a GitHub resource without that yes. Local commits run freely; pushing waits on that yes.
- Every suggested action visible to others (opening/closing PRs, commenting, pushing, releases) states what will happen and the target audience.
- Keep the report concise: tables or summaries. Save full output to a file only if the request asked for it.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `gh` discovery — commands, state, collected output. They return facts: command, exit code, output path.

### Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

Fetch facts via `gh` when given a GitHub URL instead of guessing.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.
