---
name: improve-ai-tools
description: >
  Repeatedly plan, implement, test, judge, and locally commit one independent
  repository improvement at a time through fresh agents. Use for
  /improve-ai-tools when an autonomous campaign should consume the available
  budget. Impact: creates or resumes a local campaign branch, repeatedly edits
  or removes repository files, runs commands and tests, and makes local commits
  until budget exhaustion or a blocker. It never pushes or writes outside the
  repository.
argument-hint: "[campaign name and optional priorities or exclusions]"
---

# Continuous Improvement

Run an autonomous, local campaign whose completed unit is one tested, independently useful commit.

## Workflow

Carry the planner category only as a dispatcher. The root session announces spawns, supplies paths, routes status envelopes, and relays adjudicated decisions. It does not explore, plan, edit, run commands, test, inspect diffs, judge, stage, or commit. Every dispatch uses a fresh agent instance; if spawning fails, stop rather than carrying its work.

The `USER-AGENTS.md` routing question is the campaign's sole gate. Once the user chooses `/improve-ai-tools`, all in-scope local branch creation, versioned edits and removals, commands, tests, and commits are authorized through campaign termination. Ask the user no campaign question after that gate; use *Adjudication* instead.

Pass briefs by path to minimize root-session context. Each brief tells the agent to read this complete Workflow from `$HOME/.ai-tools/skills/improve-ai-tools/SKILL.md` (Windows: `%USERPROFILE%\.ai-tools\skills\improve-ai-tools\SKILL.md`), then names the campaign state path and assigned role; only intake also carries the user request. Agents write substance to disk and return only `IMPROVE <STATUS> <path>`.

### 1. Intake

Announce and spawn `mechanical-ai-tools` with the complete Workflow and user request to initialize or resume the campaign.

1. Resolve the repository root and derive a kebab-case `<campaign>` from the explicit name or objective.
2. Set the branch to `improve/<campaign>`. Resolve its base without network access: existing `develop`, then an existing cached `origin/develop`, then `main`, then cached `origin/main`; no match is `BLOCKED`.
3. For a new campaign, require a clean worktree, create and check out the local branch, then create `dev/tmp/improve/<campaign>/`. For an existing branch, check it out only from a clean worktree; when already on it, preserve its partial work.
4. Write the request, priorities, exclusions, base, branch, repository root, current `HEAD`, and status to `dev/tmp/improve/<campaign>/campaign.md`. Use `current.md` for the active iteration and `iterations/` for finished reports.
5. Confirm the Git metadata, campaign state, runtime files, and every other intentional write resolve inside the repository. Configure command caches, temporary files, and outputs under `dev/tmp/improve/<campaign>/runtime/` whenever they are writable. A command whose writes cannot be confined is `BLOCKED`.

Branch creation is the only write before the campaign branch is checked out. Every later writer verifies the repository root and exact campaign branch before writing. Intake returns `SETUP`, `RESUME`, or `BLOCKED`.

On `RESUME`, spawn a fresh `planner-ai-tools` adjudicator to inspect `campaign.md`, `current.md`, `HEAD`, and the worktree. It returns the next role and preserves partial work; unexplained changes are `BLOCKED`.

### 2. Plan one commit

Announce and spawn a fresh `planner-ai-tools`. Give it the Workflow and `campaign.md`; give it `current.md` only when resuming. It explores the current campaign `HEAD`, reads repository instructions, and writes one microplan to `current.md` with:

- one independently useful objective small enough for one commit;
- exact allowed files and exclusions;
- observable acceptance criteria and required tests;
- documentation made stale by the change;
- one Conventional Commit message.

Prefer evidenced correctness, reliability, tests, maintainability, and stale documentation over cosmetic churn. The plan may change several files but must neither depend on a future commit nor bundle unrelated improvements.

Return `PLAN`, `NONE`, `QUESTION`, or `BLOCKED`. Two consecutive `NONE` results from independent fresh planners end the campaign; do not give the second planner the first planner's conclusion.

### 3. Implement

On `PLAN`, announce and spawn a fresh `implementer-ai-tools` with the Workflow, `campaign.md`, and `current.md`. It verifies the boundary, implements only the microplan, adds or updates behavior tests and documentation, appends factual work to `current.md`, and leaves all changes uncommitted. Return `IMPLEMENTED`, `QUESTION`, or `BLOCKED`.

### 4. Test

On `IMPLEMENTED`, announce and spawn a fresh `mechanical-ai-tools` with the Workflow and state paths. It runs exactly the required tests in the confined runtime, records commands, exit codes, and raw-log paths in `current.md`, changes no product or test file, and returns `TESTED`, `QUESTION`, or `BLOCKED`.

### 5. Judge

On `TESTED`, announce and spawn a fresh `planner-ai-tools` as judge with the Workflow and state paths. It alone inspects the microplan, real diff, test evidence, repository rules, and acceptance criteria. It writes a reasoned verdict to `current.md` and returns:

- `ACCEPT` when the change is complete, scoped, tested, safe, and independently functional;
- `REWORK` with exact corrections;
- `QUESTION` when a decision is missing;
- `BLOCKED` when no safe in-scope completion exists.

On `REWORK`, dispatch a fresh implementer, tester, and judge against the same uncommitted iteration. Allow the initial implementation plus three correction rounds. Exhaustion is `BLOCKED` and leaves the worktree untouched and dirty.

### 6. Commit and repeat

On `ACCEPT`, announce and spawn a fresh `mechanical-ai-tools` delivery agent. It verifies the root and branch, stages only judge-approved paths, audits the staged diff for scope, secrets, and unintended binaries, creates exactly one commit with the planned message, and verifies that `HEAD` advanced and the worktree is clean outside ignored campaign state. It moves `current.md` to the next ordinal under `iterations/`, updates `campaign.md`, and returns `COMMITTED <report-path>` or `BLOCKED <report-path>`.

On `COMMITTED`, immediately start *Plan one commit* with a new planner. Do not reserve a closing budget or stop voluntarily at a commit boundary. A host cutoff may leave the current iteration dirty; every earlier campaign commit remains usable.

## Adjudication

For every `QUESTION` or request for clarification or approval, announce and spawn a fresh `planner-ai-tools` adjudicator with the complete question, Workflow, request, and state paths. It decides from repository rules, campaign scope, and evidence, writes the decision under `dev/tmp/improve/<campaign>/decisions/`, and returns `DECIDED <path>` or `BLOCKED <path>`. Relay the decision path to a fresh instance of the interrupted role.

The adjudicator may authorize only the already gated local scope. A need for remote mutation, cloud access, an external write, an unversioned destructive action, or work outside the campaign branch has no in-scope approval and is `BLOCKED`.

## Termination and report

Continue until the host budget or execution ends, two independent planners find no qualifying improvement, a spawn or command fails irrecoverably, correction budget is exhausted, or adjudication returns `BLOCKED`.

At a controlled stop, chat gives one line with the branch, last committed `HEAD`, dirty/clean state reported by an agent, and `dev/tmp/improve/<campaign>/campaign.md`. A hard host cutoff needs no closing report. Resume by invoking `/improve-ai-tools` with the same campaign name.

## Boundaries

- Work only in the repository resolved at intake and on `improve/<campaign>`; read-only access to installed instructions is allowed.
- Keep all campaign state and writable runtime data inside that repository.
- Keep the campaign local: no fetch, push, pull request, cloud operation, external message, package publication, or deployment.
- Preserve the base branch and prior commits. Leave failed or interrupted work dirty; do not reset, clean, stash, amend, squash, or revert it automatically.
- One accepted iteration equals one functional commit. Campaign metadata under `dev/tmp/` stays ignored and uncommitted.
