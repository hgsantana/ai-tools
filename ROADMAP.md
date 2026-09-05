# Roadmap

This file records ideas; the README remains the source of truth for rules and processes.

Each entry is a single-paragraph story ready for `/vibe-ai-tools` (refine and deliver) or `/plan-ai-tools` (plan only). The order is advisory; later stories generally build on earlier ones. When a story ships, remove it — the commit, rule, and resulting documentation become its record.

Status: `idea` (awaiting refinement) · `next` (agreed and ready) · `doing` (planned under `dev/`) · `done` (shipped; remove the entry).

| # | Story | Status |
|---|---|---|
| 4 | [Health-check entry point](#4-health-check-entry-point) | idea |
| 6 | [Changelog for alpha testers](#6-changelog-for-alpha-testers) | idea |
| 8 | [Decisions that outlive the plan](#8-decisions-that-outlive-the-plan) | idea |
| 9 | [Resuming an interrupted delivery](#9-resuming-an-interrupted-delivery) | idea |
| 10 | [Execution outside a git repository](#10-execution-outside-a-git-repository) | idea |
| 11 | [Untrusted input handling](#11-untrusted-input-handling) | idea |
| 12 | [Adding a harness, by checklist](#12-adding-a-harness-by-checklist) | idea |
| 13 | [Cost visibility in the dispatch ledger](#13-cost-visibility-in-the-dispatch-ledger) | idea |

## Consistency

### 4. Health-check entry point

`verify` is a first-class read-only process with a script, while update and removal also have slash commands. Add a `verify-ai-tools` skill that dispatches `implementer-ai-tools` to run `verify` and maps each finding to the matching README Troubleshooting entry: dangling links and stale copies to Update, and a wrong agent model to the Grok pin or wrapper comparison. Route: `/vibe-ai-tools`.

### 6. Changelog for alpha testers

Rule 4 lets the README describe only the current alpha state. Give testers a concise history by adding `CHANGELOG.md` with one entry per version: shipped changes and breaking effects. Have the linter require an entry whenever the version changes. Route: `/vibe-ai-tools`.

## Capability

### 8. Decisions that outlive the plan

The vibe workflow answers planner questions on the user's behalf and logs those decisions and trade-offs under gitignored `dev/tmp/vibe/`, while archival removes the plan. Preserve the reasoning behind shipped changes by defining a small versioned decision record under `docs/decisions/`, one file per accepted decision, promoted from the vibe decisions file before the pull request opens. This lets reviewers assess the rationale with the change and retains it after archival. Route: `/vibe-ai-tools`.

### 9. Resuming an interrupted delivery

`dev-ai-tools` defines recovery for an interrupted subagent through its dispatch ledger, snapshot-based liveness, and intake audit of orphaned `W` stages. Extend that recovery to the vibe workflow: define how a new session detects an interrupted delivery, which files authorize continuation through the existing gate, and what it verifies before resuming a partially implemented plan branch. Route: `/plan-ai-tools`.

### 10. Execution outside a git repository

Planning outside a Git repository stores plans in `$HOME/.ai-tools-plans`, while execution assumes a Git root, a branch per plan, path-scoped commits, diff-based validation, and a pull request or review patch. Define the execution contract: either a reduced non-Git mode with explicit limits or an early stop with actionable guidance. Route: `/plan-ai-tools`.

## Hardening

### 11. Untrusted input handling

Several agents consume untrusted input: `gh-ai-tools` reads issue and pull request bodies, cloud agents read metadata and tags, and any agent may read a fetched page. Expand the one-line security rule into concrete handling: classify external text as data, quote it safely in reports, and require approval requests to originate from trusted instructions rather than fetched content. Route: `/plan-ai-tools`.

### 12. Adding a harness, by checklist

Adding a harness requires coordinated edits: one wrapper per agent, a researched `MODELS.csv` row, the Supported harnesses table, installation steps, script discovery, and any newly tighter constraint. Consolidate these requirements into an ordered checklist, and have the linter verify that every wrapper folder has both a MODELS.csv row and a Supported harnesses entry. Route: `/vibe-ai-tools`.

### 13. Cost visibility in the dispatch ledger

The dispatch ledger records the model behind every attempt. Extend it and the final summary with the usage data each harness exposes per attempt—tokens, duration, or a documented estimate—so outcomes and cost appear together. Mark unavailable values explicitly and base every number on reported evidence. Route: `/plan-ai-tools`.
