---
name: improve-ai-tools
description: >
  Repeatedly have fresh planner agents plan and deliver relevant, multi-stage
  repository improvements by chaining plan-ai-tools and dev-ai-tools. Use for
  /improve-ai-tools when an autonomous campaign should consume the available
  budget. Impact: creates or resumes a local campaign branch, repeatedly edits
  or removes files, runs commands and tests, and makes multiple local commits
  until budget exhaustion or a blocker. It never pushes or writes outside the
  repository.
argument-hint: "[campaign name and optional priorities or exclusions]"
---

# Continuous Improvement

Run an autonomous, local campaign that repeatedly plans and delivers relevant repository improvements. One iteration is one accepted plan and may contain multiple stages and commits.

## Workflow

Carry the planner category only as a dispatcher. The root session announces spawns, supplies paths, routes status envelopes, and starts the next pass. It does not explore, plan, edit, run commands, test, inspect diffs, judge, stage, or commit. Every pass uses a new `planner-ai-tools` instance with no conversation history; in harnesses that support it, spawn with an empty context such as Codex `fork_turns: none`. If spawning fails, stop rather than carrying its work.

The `USER-AGENTS.md` routing question is the campaign's sole gate. Once the user chooses `/improve-ai-tools`, the planners may accept their own recommendations and decide every in-scope question. The gate authorizes local campaign-branch creation, versioned edits and removals, commands, tests, and commits through campaign termination. Do not ask the user to approve a plan or another campaign decision; block when completion needs authority outside *Boundaries*.

Pass durable paths instead of prior-agent prose. Each brief tells the agent to read this complete Workflow from `$HOME/.ai-tools/skills/improve-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\improve-ai-tools\SKILL.md`), then names the repository, campaign state, nested skill, and assigned pass. The initial planning brief also carries the user request. Agents write substance to disk and return only `IMPROVE <STATUS> <path>`.

### 1. Planning pass

Announce and spawn a fresh, zero-context `planner-ai-tools`. Assign it to initialize or resume the campaign and run `plan-ai-tools`:

1. Read the complete `plan-ai-tools` Workflow from `$HOME/.ai-tools/skills/plan-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\plan-ai-tools\SKILL.md`) and the repository instructions.
2. Resolve the repository root and a kebab-case `<campaign>` from the explicit name or objective. Use branch `improve/<campaign>` and resolve its base from repository rules or the local default branch without network access.
3. For a new campaign, require a clean worktree, create and check out the campaign branch, then create `dev/tmp/improve/<campaign>/`. For an existing campaign, switch to its branch only from a clean worktree; when already on it, preserve partial work.
4. Write or update `dev/tmp/improve/<campaign>/campaign.md` with the request, priorities, exclusions, repository root, base, branch, current `HEAD`, active plan path, completed reports, and status. Keep decisions under `decisions/` and iteration summaries under `iterations/`.
5. On resume, return `RESUME <plan-path>` when one plan is already active. Reconcile its files, branch, and worktree without resetting, cleaning, stashing, amending, squashing, or reverting.
6. Otherwise inspect the current campaign `HEAD` and choose one cohesive, relevant improvement or correction supported by repository evidence. Prefer correctness, reliability, tests, maintainability, security, performance, and stale behavior documentation over cosmetic churn. Reject artificially small or speculative work; the objective must justify `plan-ai-tools` Plan mode and may span as many stages and commits as needed.
7. Run the `plan-ai-tools` Workflow and write its canonical plan under `dev/<slug>/`. Resolve open design choices yourself from evidence and campaign priorities. The improve gate replaces `plan-ai-tools`' user approval: return `PLAN <base-plan-path>` without asking “Implement it?”.

Return `PLAN`, `RESUME`, `NONE`, or `BLOCKED`. Two consecutive `NONE` results from independent fresh planners end the campaign. Give the confirmation planner the campaign scope and current repository, but not the first planner's conclusion or reasoning.

### 2. Execution pass

On `PLAN` or `RESUME`, announce and spawn a different fresh, zero-context `planner-ai-tools`. Give it only this Workflow, `campaign.md`, the exact plan path, and the complete `dev-ai-tools` Workflow at `$HOME/.ai-tools/skills/dev-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\dev-ai-tools\SKILL.md`). Assign it to execute and judge the accepted plan in `dev-ai-tools` Plan mode.

The execution planner owns the entire `dev-ai-tools` sequence. It loads the plan, dispatches `implementer-ai-tools` for production and test edits, dispatches `mechanical-ai-tools` for builds, tests, and evidence, inspects the real diffs, audits acceptance criteria and tests, orders corrections, commits accepted stages, archives the completed plan, and writes the final report. It may spawn its own helpers according to `dev-ai-tools`; the root session does not orchestrate those workers or duplicate the judgment.

Apply these campaign overrides to `dev-ai-tools`:

- Treat the saved plan as already accepted and run unattended. Decide in-scope questions from the plan, repository rules, evidence, and campaign priorities; record them under the campaign's `decisions/` directory.
- Verify the exact repository root and `improve/<campaign>` before every write. Keep all plan, implementation, test, archival, and report work on that branch; do not create or switch to `plan/<slug>`.
- Preserve `dev-ai-tools`' plan-introduction, per-stage, and archival commits. Its one-commit-per-stage rule remains; the improve iteration itself has no commit limit.
- Keep delivery local. Replace push, pull-request creation, and local review-patch delivery with an update to `campaign.md` and an iteration summary containing the plan path, report path, commit list, final `HEAD`, and clean/dirty state.
- A terminal execution failure is `BLOCKED`; leave resumable state untouched instead of asking the user to relax acceptance or deliver failed stages.

Return `DELIVERED <report-path>` or `BLOCKED <report-path>`. On `DELIVERED`, the root session immediately starts another *Planning pass* with a new zero-context planner. Do not reuse either planner from the completed iteration.

## Termination and report

Continue until the host budget or execution ends, two independent planners find no qualifying improvement, a spawn or command fails irrecoverably, or an execution pass returns `BLOCKED`.

At a controlled stop, chat gives one line with the campaign branch, last committed `HEAD`, clean/dirty state reported by an agent, and `dev/tmp/improve/<campaign>/campaign.md`. A hard host cutoff needs no closing report. Resume by invoking `/improve-ai-tools` with the same campaign name.

## Boundaries

- Work only in the repository resolved by the planning pass and on `improve/<campaign>`; read-only access to installed instructions is allowed.
- Keep campaign state and writable runtime data inside the repository. Prefer `dev/tmp/improve/<campaign>/runtime/` for configurable caches, temporary files, and command output.
- Keep the campaign local: no fetch, push, pull request, cloud operation, external message, package publication, deployment, or other shared-state mutation.
- Preserve the base branch and history predating the campaign. Leave failed or interrupted work resumable and unchanged.
- Campaign metadata under `dev/tmp/` stays ignored and uncommitted.
