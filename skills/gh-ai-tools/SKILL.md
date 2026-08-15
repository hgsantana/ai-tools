---
name: gh-ai-tools
description: >
  Query and manage GitHub resources via the GitHub CLI (gh). Use whenever the user asks about
  GitHub issues, pull requests, repos, releases, or checks, or wants something created,
  modified, or removed on GitHub. Also use for /gh-ai-tools.
---

# GitHub CLI (gh)

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not, or cannot tell** — never delegate this skill and never start its workflow yet. Send one
   chat message, in the user's language: the required category is not met; the model running this session,
   named (or that the harness does not expose it); the question — run it anyway?; and how to switch model
   in this harness plus which model or bundled skill fits **planner** best here. Then wait.
4. Run here only if the user authorizes it. That authorization holds for the rest of the session and is
   asked again only if the model changes. Declined or unanswered — stop: no exploration, no writes, no
   spawns.

## Rules

Use `gh` CLI for issues, pull requests, checks, releases, and repositories.

- Freely run **read-only / query** commands (list, view, status, checks).
- You may **suggest** mutations (creating/modifying/closing issues/PRs, pushing); only the user decides.
- **NEVER** create, modify, close, merge, comment on, or remove any GitHub resource without **explicit** user authorization for that specific action. Approval never carries over, even inside unattended `/dev-ai-tools`. Local commits do not require approval; pushing does.
- Before actions visible to others (opening/closing PRs, commenting, pushing, releases), state what will happen and the target audience.
- Keep chat replies concise: tables or summaries. Save full output to a file only if requested.

## Delegated exploration

Planner may spawn **mechanical** or **implementer** subagents to explore `gh` (discover commands, read state, collect output):
- Strictly read-only query commands.
- Return facts, never verdicts or change proposals.
- Planner alone decides and executes mutating commands after presenting cost/risk/reason and receiving explicit per-action approval.
- Entry-gate authorization does not authorize mutations.

## Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

Fetch facts via `gh` when given a GitHub URL instead of guessing.
