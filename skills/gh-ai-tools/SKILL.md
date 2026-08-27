---
name: gh-ai-tools
description: >
  Query or manage GitHub via the GitHub CLI (gh). Use for /gh-ai-tools or
  GitHub
  repositories, pull requests, issues, releases, or workflows. Impact:
  mutations can merge, close, comment, push, and delete — visible to others
  immediately and often irreversible. Reads run freely; each mutation needs
  an explicit yes for that action.
argument-hint: "[what to inspect or change on GitHub]"
---

# GitHub

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`).

## Workflow

Use the GitHub CLI (`gh`) for issues, pull requests, checks, releases, and repositories on the request you were given, then stop.

### Rules

- Run **read-only / query** commands freely (list, view, status, checks, diff).
- Put each proposed mutation to the user as its own request — command, target, reason, and blast impact — and run it only on an explicit yes for that action. Approval never carries over between actions. Never create, modify, close, merge, comment on, or remove a GitHub resource without that yes. Local commits run freely; pushing waits on that yes.
- Every suggested action visible to others (opening/closing PRs, commenting, pushing, releases) states what will happen and the target audience.
- Collected output — inventories, cost breakdowns, logs, listings — goes to a file under `dev/tmp/` and is handed over as a path. Chat carries the direct answer to what was asked; a result that genuinely fits in a line or two needs no file.

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

Write the findings to `dev/tmp/<topic>.md` and give the user its path — opened in their editor where the harness can. Chat carries, in the user's language, the direct answer to what was asked and any mutation still awaiting a yes.
