---
name: gh-ai-tools
description: >
  Query or manage GitHub through the GitHub CLI (gh). Use for /gh-ai-tools or
  repositories, pull requests, issues, releases, and workflows. Impact:
  mutations can merge, close, comment, push, or delete; they are immediately
  visible to others and often irreversible. Reads run freely; each mutation
  requires an explicit yes.
argument-hint: "[what to inspect or change on GitHub]"
---

# GitHub

Issues, pull requests, checks, releases, and repositories through the GitHub CLI (`gh`).

## Workflow

Use `gh` for the requested issues, pull requests, checks, releases, or repository operation, then stop.

### Rules

- Run **read-only queries** freely: list, view, status, checks, and diff.
- Present each mutation as a separate approval request with its command, target, reason, and blast impact. Execute it only after an explicit yes for that action; approval never carries over. Local commits run freely; pushing requires that yes.
- For every action visible to others—opening or closing pull requests, commenting, pushing, or publishing releases—state the outcome and audience.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `gh` discovery — commands, state, collected output. They return facts: command, exit code, output path.

### Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

When given a GitHub URL, fetch its facts through `gh`.

## Report

Write inventories, logs, diffs, and listings to `dev/tmp/<topic>.md`, then give the user its path—opened in their editor where supported. In the user's language, chat carries the direct answer and any mutation awaiting approval. A one- or two-line result may stay in chat alone.
