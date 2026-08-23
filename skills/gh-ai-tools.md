> Skill base, loaded by the wrapper at `skills/gh-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`). Runs the `planner-ai-tools` role in the user's session. Run `gh` only once the planner gate passes.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`). This session carries that role behind the contract's planner gate.

## Stake

Tell the user, in their language, before anything runs: this work touches GitHub, where actions can merge, close, comment, push, and delete — visible to other people immediately and often irreversible. A mutation runs only after their explicit approval for that specific action.

## Route A — run here

Read freely; put every mutation to the user as its own approval request, in their language, including its blast impact. Only an explicit yes for that specific action runs it, and approval never carries over between actions. Open questions — yours or a spawned worker's — reach the user the same way.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.

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
