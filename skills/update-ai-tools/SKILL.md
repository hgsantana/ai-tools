---
name: update-ai-tools
description: >
  Update an existing installation per the README: remove current-version
  artifacts, reset $HOME/.ai-tools to origin/master, and install from the
  fresh tree. Use for /update-ai-tools. Impact: can discard local commits
  and edits, and refreshes harness configuration. Each destructive step
  requires explicit approval. Agent: mechanical-ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

# Update

Run task `update` for an existing ai-tools installation.

## Scope and approvals

The routing gate already surfaced the impact. Settle scope before acting. Present every destructive step separately with its flag, what it discards, and why it is needed. Execute only explicitly approved steps; omit declined flags. Approval never carries over.

## Source of truth

`$HOME/.ai-tools/README.md` defines the processes and their Safety rules; the scripts are their executable form — run them. Use the shell scripts on Linux, macOS, WSL, and Git Bash.

| Task | Script | Flags needing explicit user approval |
|---|---|---|
| `update` | `scripts/shell/update.sh` | `--discard-local` |
| `remove` | `scripts/shell/remove.sh` | `--instructions`, `--purge` (with `--yes` only inside that same approval) |

Use agents, remotes, URLs, paths, and flags defined by the tree, README, or scripts' `--help`; these sources prevail over recollection.

## Workflow

This file is the brief for the dispatched agent. Execute the Workflow.

1. **Scope** — ask which harnesses and task-specific options are in scope. Pass the answer as `--harnesses`; an explicit "all" selects every supported harness.
2. **Dry run** — run `scripts/shell/update.sh` with `--dry-run` and the scoped flags. Save its output to `$AI_TOOLS/dev/tmp/update-dry-run.log` and hand over that path, together with each destructive flag the task needs as its own approval request — action, what it discards, and why.
3. **Execute** — run the script with exactly the approved flags.
4. **Interpret** — exit 0: clean. Exit 2: report every `WARN` with its reason. Exit 1: report the failed precondition and use only the remedy named in README Troubleshooting. Never bypass a safety refusal by resetting or deleting manually.

Read-only steps — discovery, `--dry-run`, `verify.sh` — run freely.

## Boundaries

- Touch only `$AI_TOOLS` and the harness destinations the scripts name.
- Leave `$HOME/AGENTS.md` untouched — user-owned, outside every procedure. **Never touch `$HOME/AGENTS.md`.**
- Report skipped conflicts to the user and preserve the scripts' `safe_*` semantics.
- Scripts are idempotent; recover from a partial task by re-running it.

## Report

Write `$AI_TOOLS/dev/tmp/update-report.md` with exact invocations, each `done: … ok, … skipped, … warnings` line, every `SKIP`/`WARN` and its reason, and the resulting tree state (`HEAD` and cleanliness). Chat gets that path—opened where supported—plus the outcome, pending approvals, and a reminder to restart harnesses that cache agents or skills.
