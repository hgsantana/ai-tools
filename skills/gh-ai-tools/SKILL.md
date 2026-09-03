---
name: gh-ai-tools
description: >
  Query or manage GitHub accounts, administration, environments, Actions,
  issues, and releases through the GitHub CLI (gh). Use for /gh-ai-tools;
  handle repository code work directly. Impact: remote mutations can change
  access, settings, automation, or hosted data. Reads run freely; each mutation
  requires explicit approval. Min. role: implementer.
argument-hint: "[GitHub platform resource to inspect or manage]"
---

# GitHub Platform

Manage GitHub-hosted resources and configuration through the GitHub CLI (`gh`).

## Workflow

Use `gh` for the requested GitHub platform query or administration, then stop.

### Scope

Use this skill for:

- account, authentication, organization, team, collaborator, and permission state;
- repository creation, archival, deletion, transfer, visibility, settings, rulesets, and branch protection;
- environments, deployment policies, secrets, variables, apps, webhooks, and integrations;
- Actions workflows, runs, checks, builds, artifacts, caches, and automation settings;
- issues, discussions, projects, releases, packages, and other GitHub-hosted records.

Repository code work bypasses this skill and runs directly in the current session under the repository instructions. That includes commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code diffs and reviews, and creating, updating, reviewing, or merging pull requests. GitHub-side policy for those features—such as rulesets, required checks, and pull-request settings—remains platform administration and is in scope.

### Rules

- Run read-only platform queries freely.
- Present each remote mutation as a separate approval request with its command, target, reason, and blast impact. Execute it only after an explicit yes for that action; approval never carries over.
- For every action visible to others or affecting their access or automation, state the outcome and audience.

### Delegated exploration

Spawn `mechanical-ai-tools` for read-only `gh` discovery—commands, state, and collected output. It returns facts: command, exit code, and output path.

### Useful commands

- `gh auth status` / `gh api user` — account and authentication
- `gh repo view` / `gh api repos/<owner>/<repo>` — repository state and settings
- `gh api orgs/<org>` / `gh api teams/<team>` — organizations, teams, and access
- `gh secret` / `gh variable` / `gh api .../environments` — configuration and environments
- `gh workflow` / `gh run` / `gh cache` — Actions, builds, artifacts, and caches
- `gh issue` / `gh release` / `gh api <endpoint>` — hosted records and other platform resources

When given a GitHub URL for an in-scope platform resource, fetch its facts through `gh`.

## Report

Write inventories, logs, and listings to `dev/tmp/<topic>.md`, then give the user its path—opened in their editor where supported. In the user's language, chat carries the direct answer and any mutation awaiting approval. A one- or two-line result may stay in chat alone.
