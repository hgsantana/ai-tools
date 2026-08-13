---
name: gh-ai-tools
description: >
  Query and manage GitHub resources via the GitHub CLI (gh). Use whenever the user asks about
  GitHub issues, pull requests, repos, releases, or checks, or wants something created,
  modified, or removed on GitHub. Also use for /gh-ai-tools.
---

# GitHub CLI (gh)

Use the `gh` CLI for issues, pull requests, checks, releases, and repos.

## Entry gate — required category: planner

Before anything else in this skill:

1. Identify whether you satisfy **planner** (global `AGENTS.md` → Agent categories).
2. **You satisfy it** — run this skill here, spawning the subagents it names.
3. **You do not** — spawn the harness's planner (a model, or a bundled skill invoked with this skill's
   requirements added to its own rules), hand it this skill and the user's request in full, and become a
   relay layer: pass messages verbatim in both directions, summarizing nothing, approving nothing.
4. **You are the agent spawned to run this skill** — the gate is already satisfied. Go straight to the
   workflow and never delegate this skill onward.
5. **Roster not enumerable and no spawning available** — run here and say so in chat.

## Rules

- Freely use `gh` for **read-only / query** operations (list, view, status, checks).
- You may **suggest** creating, modifying, or closing issues/PRs, pushing, or other changes;
  only the user decides.
- **NEVER** create, modify, close, merge, comment on, or remove any GitHub resource without
  **explicit** user authorization for that specific action. Prior approval does not carry over, and
  this gate holds even inside an unattended `/dev-ai-tools` run. Local commits are not covered here;
  pushing is.
- Before side effects visible to others (PR open/close, comments, push, release), state what will
  happen and who will see it.
- Keep chat replies concise: a short table or summary, not a raw dump. For long or raw output, summarize in chat and save the full result to a file only if the user wants it kept.

## Delegated exploration

The planner running this skill may spawn **mechanical** or **implementer** subagents to explore `gh`: discover which commands exist, read current state, collect output.

- Strictly read-only. Query commands only — never create, modify, or remove anything.
- They return facts, never verdicts. They do not judge what should change.
- Only the planner decides on a mutating command and runs it, after presenting cost, risk, and reason, and getting explicit authorization for that specific action.
- When the planner is itself a spawned agent, that authorization request travels the relay verbatim. The relay never approves in the user's place.

## Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

If given a GitHub URL, use `gh` to fetch facts rather than guessing.
