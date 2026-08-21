> Skill base, loaded by the wrapper at `skills/gh-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`). Dispatches `planner-ai-tools` to follow **Workflow**. Never run `gh` outside that dispatch.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

Tell the user, in their language, before anything runs: this work touches GitHub, where actions can merge, close, comment, push, and delete — visible to other people immediately and often irreversible. A mutation runs only after their explicit approval for that specific action.

## Route A — dispatch

The agent reads freely and returns every mutation for approval. Relay each request to the user in their language, including its blast impact; only on an explicit yes for that specific action resume the agent with the approval. Approval never carries over between actions. Relay open questions the same way, reusing the same agent and its context where the harness allows.

## Report

Summarize the outcome in chat, in the user's language — concise tables or summaries; reference any saved output by path.

## Workflow

Use the GitHub CLI (`gh`) for issues, pull requests, checks, releases, and repositories on the request you were given, then stop.

### Approvals

Never create, modify, or remove a resource without explicit user approval for that specific action. Put each proposed mutation to the user as its own request — command, target, reason, and cost or blast impact — and run it only on an explicit yes for it. Approval never carries over between actions.

### Rules

- Freely run **read-only / query** commands (list, view, status, checks, diff).
- You may **suggest** mutations; only the user decides. **NEVER** create, modify, close, merge, comment on, or remove any GitHub resource without explicit user approval for that specific action. Local commits need no approval; pushing does.
- Every suggested action visible to others (opening/closing PRs, commenting, pushing, releases) states what will happen and the target audience.
- Keep the report concise: tables or summaries. Save full output to a file only if the request asked for it.

### Delegated exploration

You may spawn `mechanical-ai-tools` to explore `gh` — discover commands, read state, collect output:

- Strictly read-only query commands.
- They return facts, never verdicts or change proposals.

### Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

Fetch facts via `gh` when given a GitHub URL instead of guessing.
