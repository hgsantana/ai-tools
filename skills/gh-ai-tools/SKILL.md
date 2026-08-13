---
name: gh-ai-tools
description: >
  Query and manage GitHub resources via the GitHub CLI (gh). Use whenever the user asks about
  GitHub issues, pull requests, repos, releases, or checks, or wants something created,
  modified, or removed on GitHub. Also use for /gh-ai-tools.
---

# GitHub CLI (gh)

Use the `gh` CLI for issues, pull requests, checks, releases, and repos.

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

## Useful commands

- `gh pr list` / `gh pr view` / `gh pr diff` / `gh pr checks` — pull requests
- `gh issue list` / `gh issue view` — issues
- `gh repo view` — repository info
- `gh api <endpoint>` — API for uncovered cases
- `gh run list` / `gh run view` — CI runs

If given a GitHub URL, use `gh` to fetch facts rather than guessing.
