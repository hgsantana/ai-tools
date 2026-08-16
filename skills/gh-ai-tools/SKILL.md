---
name: gh-ai-tools
description: >
  Query and manage GitHub resources via the GitHub CLI (gh). Use whenever the user asks about
  GitHub issues, pull requests, repos, releases, or checks, or wants something created,
  modified, or removed on GitHub. Also use for /gh-ai-tools.
---

# GitHub CLI (gh)

## Entry gate — required category: planner

This skill must run on a **planner** model. Before anything else:

1. Decide whether you are one (*Agent categories*, in the global agent instructions).
2. **You are** — run the skill here, spawning the subagents it names.
3. **You are not, or cannot tell** — do not start it and do not delegate it. Send one short chat message in
   the user's language: name the model running this session (or say the harness does not expose it); say how
   to get a planner here — switch this session to the harness's strongest model, or start the work over from
   the `planner-ai-tools` agent, which is pinned to one; then ask whether to run anyway. Wait for the answer.
4. **Yes** — run the skill here, as its planner, for the rest of the session; ask again only if the model
   changes. **No, or no answer** — stop here: no exploration, no writes, no spawns.

Name the stake in that message, so the answer is an informed one: this skill can merge, close, and push to GitHub repositories, which other people see immediately.

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
