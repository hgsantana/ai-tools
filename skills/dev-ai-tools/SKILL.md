---
name: dev-ai-tools
description: >
  Execute an accepted plan under dev/ or one user-agreed task in the
  planner-ai-tools role. Use for /dev-ai-tools or after plan acceptance.
  Impact: edits code, runs commands, commits each step on a dedicated branch,
  archives the plan or task, pushes, and opens a pull request unattended once
  all steps finish.
argument-hint: "[plan paths, or the task to implement]"
---

# Execution

Execute an accepted plan under `dev/<slug>/` or one task agreed with the user.

## Workflow

Carry the `planner-ai-tools` role, select the mode, run the sequence, then stop.

| Input | Mode |
|---|---|
| Empty, `dev`, `dev/<slug>/`, `dev/<slug>.md`, or an archived slug | **Plan** — run what is already decided |
| Anything else | **Task** — agree one task with the user, then run it |

Empty input processes every unfinished base plan (`dev/*/0-*.md`) and task (`dev/*.md`) from oldest to newest, one at a time. Excluding `dev/tmp/**` prevents spontaneous re-execution. Preserve the ignore policy: work under `dev/` is trackable, while generated archives, reports, and patches share the ignored `dev/tmp/` root; add that ignore rule when absent. Outside a Git repository, plans live in `$HOME/.ai-tools-plans` (`%USERPROFILE%\.ai-tools-plans` on Windows).

### The sequence

Both modes run these steps, in order:

1. **Read the repository's documentation** — `README.md`, `AGENTS.md`, `docs/`, `CONTRIBUTING` — and hold to its rules, style, and language in everything you write.
2. **Load the unit of work from disk.** In Plan mode, read `dev/<slug>/` once before the first dispatch: the base, stage, and fix files. Leave unrelated plans and `dev/tmp/**` unread. In Task mode, agree the task first (*Agreeing the task*).
3. **Implement in short steps**, one commit each (*Dispatching*, *Branch and delivery*), with logs, diffs, and output stored in files.
4. **Test before closing a step.** Write and run behaviour or feature tests for the delivered change, iterating until they pass; a build alone is insufficient.
5. **Update the documentation** wherever the step changed behaviour or expectations.
6. **Archive** the plan or task file: copy, then remove — both are required (*Archival*).
7. **Commit the archival last**, then push and open the pull request (*Branch and delivery*).

## Agreeing the task (Task mode)

Before writing files or code, refine the request with the user in their language until it is complete:

- Resolve the named branch currently checked out and keep it checked out throughout task agreement. This is `<base>`; if `HEAD` is detached, ask the user to choose and check out a branch before continuing.
- Name what is ambiguous, propose the improvements you see, and state the impact of the change and of each alternative.
- Size it: one task equals one implementation commit. For larger work, recommend `plan-ai-tools` and proceed with the scope the user accepts.
- Derive a kebab-case `<slug>`. When an existing plan already covers the request, run that plan instead.

On agreement, write `dev/<slug>.md`:

````markdown
# <Title>

Status:

## Goal

What changes and why.

## Base branch

`<base>` — the branch current when the user requested the task; create the work branch from it and target the pull request to it.

## Scope

- Modify: `path` — reason
- Out of scope: …

## Steps

1. … (each step is one commit)

## Tests

The behaviour to assert, and where.

## Docs

Which documentation this change makes stale.

## Acceptance criteria

- [ ] Observable criterion

## Implementation log

(Append-only, added during execution.)
````

After agreement, the run continues unattended like Plan mode.

## Unattended

Once the unit of work is on disk, run it to completion without checkpoints. Contact the user only for:

- a blocker you cannot resolve;
- a decision the implementation itself uncovered that the plan or the agreed task does not settle;
- anything the Security rules reserve for the user — a cloud mutation, a destructive or shared-state operation.

Send each as a separate request with action, target, reason, and impact. Execute it only after an explicit yes for that action; approval never carries over. Continue independent work while waiting. Pushing the branch and opening the pull request are pre-authorized once every step reads `F`.

## Branch and delivery

First verify the repository root with `git rev-parse --show-toplevel` and resolve `<base>` before creating the work branch. In Plan mode, `<base>` is exactly the **Base branch** recorded in `dev/<slug>/0-<slug>.md`: the branch `plan-ai-tools` analyzed. In Task mode, it is exactly the **Base branch** recorded in `dev/<slug>.md`: the branch current when the user requested the task. Require that named branch to exist; a missing, detached, or unresolvable value is a blocker, never a reason to substitute another branch.

Every change lands on `plan/<slug>`, created from `<base>`. Preserve `<base>`, use one branch per plan or task, and reuse it on reentry. Note a dirty tree in the report.

The history on that branch is symmetric:

1. **First commit** introduces the unit of work, before any implementation: `chore(dev): plan <slug>` for `dev/<slug>/`, `chore(dev): task <slug>` for `dev/<slug>.md`.
2. **One commit per step**, Conventional Commits, once that step validates. Stage path by path; check for secrets and binaries.
3. **Last commit** removes it: `chore(dev): archive <slug>` (*Archival*).

Then push `plan/<slug>` and open the pull request against the same `<base>` from which the work branch was created (`gh pr create --base <base> --head plan/<slug> …`), drafting title and body from the accepted steps. The reviewer sees the plan or task introduced, implemented, and removed alongside the changes it produced, and an unwanted run is discarded by deleting its branch.

**When no pull-request host is available**—determined at branch creation from a compatible remote; for GitHub, `gh auth status` plus a GitHub remote—return a **local review request**: branch, base, `git diff --stat`, and a patch from `git diff <base>...<branch> --output=dev/tmp/<slug>-review.patch`. Let Git write the patch, verify it with `--stat` or `wc -l`, and leave its content on disk.

**A step left in `E`** stops the delivery: archive nothing, push nothing. Report how many steps failed and why, and return the choice as an approval request—retry them, deliver and archive anyway, or deliver and leave the work under `dev/`. An unattended `vibe-ai-tools` delivery, whose gate promised no further checkpoints, decides for itself and records the choice and reasoning in `dev/tmp/vibe/<slug>-decisions.md`.

## Dispatching

| Work | Who |
|---|---|
| Orchestrate steps, author briefs, review diffs, audit tests, commit, set status | this session (you), in the `planner-ai-tools` role |
| Write and edit the code and tests of one step | `implementer-ai-tools` |
| Run builds and tests, collect raw logs and diffs | `mechanical-ai-tools` |

Spawn the agent that owns each piece; workers may spawn their own helpers. If spawning fails, they carry work allowed by their type or return a dispatch request. `implementer-ai-tools` owns repository-code edits. Keep steps sequential to preserve the ledger and per-step commits: dispatch the next step or correction after the current one reaches `F` or `E`. Read-only discovery, builds, and tests may run concurrently.

**Budget**: 1 attempt plus up to 3 corrections per step, then `E`.

**Self-contained briefs.** A subagent does not load this skill. Give it the goal, the step's status row, one assigned file (`dev/<slug>/<n>-<slug>.md`, `dev/<slug>/F<m>-<slug>.md`, or `dev/<slug>.md`), and verbatim copies of *Implementer obligations* and the report instruction below. Pass paths instead of contents so the file remains the single source of truth.

Every dispatch and every correction round carries, verbatim:

> Report by appending to your assigned file, then finish your run — your final output reaches whoever spawned you automatically. Messaging and agent-addressing tools have no reliable address for your spawner; a guessed name misroutes the report.

**One live writer per file.** Ownership starts when a Dispatch log row is appended and ends when its Outcome is filled. Keep a single writer so logs remain ordered and the report ledger stays valid.

### Implementer obligations

1. Write your session ID into the current Dispatch log row of the assigned file on start.
2. Implement only that file's step.
3. Append factual **Implementation log** entries — actions and evidence, not claims.
4. Set status `V` on completion. Leave `W`, `R*`, `T`, `E`, and `F` to the planner.
5. Report through the assigned file and by finishing the run.

### Dispatch ledger

Append one row to the assigned file's **Dispatch log** before every spawn:

````markdown
## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | <model> | <id> | V → failed validation |
| 2 | R1 | implementer-ai-tools | <model> | <id> | V → accepted |
````

Attempts count from 1 and corrections continue the counter (`R1` is attempt 2). **Runner** is the concrete model the harness gave that agent — mirror it into the plan base's `Agent` column; prompts name the agent, the wrapper pins the model. **Outcome** is filled after validation: `accepted`, `failed validation`, `E — limit exhausted`, or `lost — <evidence>`. This table is the only source for attempt counts in the report.

## Status protocol

One `Status:` header in a task file, one row per stage in a plan base.

| Code | Meaning | Set by |
|------|---------|--------|
| *(empty)* | Not started | — |
| `W` | Working — implementation in progress | planner |
| `V` | Validating — ready for review | `implementer-ai-tools` |
| `R1`, `R2`, `R3` | Rework after review | planner |
| `T` | Testing — tests being written and run | planner |
| `E` | Blocked, or correction budget exhausted | planner |
| `F` | Finished — accepted | planner |

Set `W`, `R1`–`R3`, or `T` before dispatching, updating the `Agent` column to the agent and model dispatched. On `V`, validate.

## Validation

Treat subagent claims and a passing build as evidence; base acceptance on verified facts:

1. Re-read the step's objective, allowed files, criteria, and implementation log.
2. Inspect the real diff (`git status`, `git diff`, log).
3. Confirm that the change meets the objective, stays within allowed files, completes every required item with production-ready implementations, matches surrounding style, includes no extraneous changes, and finishes its cleanup.
4. Pass or fail each acceptance criterion individually, with a reason.
5. **Audit the tests**: they assert observable behaviour, would fail on a regression, and weaken no existing suite.
6. Pass → `F`, commit. First failure → append concrete correction tasks to the file and set `R1`. Second → decompose the remaining corrections into fix files `dev/<slug>/F<m>-<slug>.md`, record the mapping in the parent file, dispatch each with its fix file alone, and set `R2` (or `R3`). Third → `E` with a failure report, then continue the steps that do not depend on it.

## Lost runs

A subagent can die without reporting. Detection uses only the filesystem and git, so it works in any harness.

- **Poll by comparing snapshots**: record the assigned file's size and epoch mtime (`stat -c %Y`, or `stat -f %m` on BSD/macOS) plus `git status --porcelain` over the step's files. Any difference is progress and resets the deadline, measured in consecutive unchanged polls. When elapsed time is needed, subtract epoch integers (`date +%s` and `stat`); formatted local timestamps can misclassify live runs across time zones.
- **Diagnose from the ledger**: no session ID in the open row means the run never started, so a retry is safe; a session ID with no final status means it died mid-run.
- **Declare and re-dispatch in two acts.** Write `lost — <evidence>` into the open row, then re-read the file and snapshot. If either changed, clear the Outcome and resume waiting. An unchanged re-read authorizes the next row and spawn.
- **Audit before re-dispatching**: a mid-run death leaves partial edits. Inspect the working tree restricted to that step's files and record in the file what is already done, so the replacement continues instead of colliding. Reverting those files is destructive to a writer that turns out to be alive — reserve it for a run the two-act check confirmed dead.
- **Reconcile a returning ghost**: its edits are in the diff and its log is in the file. Validate from the diff and repair the ledger — one row per attempt, truthful Outcome, duplicated attempts out of the count.
- **Account for it.** One re-dispatch of a lost run spends no correction round: the work was never reviewed. A second consecutive loss on the same step is structural — decompose into smaller fix files, or set `E` with the evidence.
- **Orphans at intake**: a step already in `W`, `R*`, or `T` when you load the work is an orphan from a previous run. Treat it as lost.

## Archival

A plan or task file is temporary working state, versioned so execution survives an interrupted session or fresh clone. Keep it while work remains resumable; the delivered commits, tests, and updated documentation become the remote record.

Archive once **every** step is terminal (`F`; an `E` stops the delivery) and every Dispatch log row has its Outcome filled — an open row means a writer may still return, and it still owns the file. Then do both steps:

1. **Copy locally** — `mkdir -p dev/tmp/finished`, then `cp -r dev/<slug> dev/tmp/finished/<slug>` for a plan, or `cp dev/<slug>.md dev/tmp/finished/<slug>.md` for a task. `dev/tmp/` is gitignored, so the copy stays on this machine alone.
2. **Remove from the repository** — `git rm -r dev/<slug>`, or `git rm dev/<slug>.md`.

Before committing, confirm `git ls-files dev/tmp` prints nothing and `git status` shows the deletion. Commit it path-scoped as `chore(dev): archive <slug>`: the last commit on the branch, after every step commit and before the push.

**Reentry.** Pick up an archive only when a dispatch names its slug or path and it resolves exactly to `dev/tmp/finished/<slug>/0-<slug>.md` or `dev/tmp/finished/<slug>.md`; report other paths and leave them unchanged. Restore it under `dev/`, remove the archive copy, commit `chore(dev): reopen <slug>`, then run it. Keep `F` stages complete and restart only `E` stages at `W`, each with a fresh 1 + 3 budget and a continuing attempt count. Refuse reentry when every stage is `F` or `dev/<slug>` already exists, and report the reason; one unit owns each slug.

## Report

Write the report, then point at it. Every detail of the run already lives in the plan or task file — steps, logs, diffs, outputs — and the closing report goes to `dev/tmp/<slug>-report.md`. Chat gets that path, a one-line outcome, and anything that needs the user; where the harness can open a file in their editor, open it rather than pasting it.

The report file holds, per step and in execution order: what was delivered, in a line or two drawn from the accepted diff; the attempts, with the fix-file count when corrections were decomposed; and the runner — agent and model — per attempt, noting explicitly when attempts used different runners.

It closes with the `F`/`E` counts, the pull request URL or the local review patch path, the local archive path (`dev/tmp/finished/<slug>`), the commits created including the archival commit, anything still awaiting approval, every refused reentry with its reason, and for each `E` its cause and the decision the user has to make. Record only what the ledger and the files substantiate.

## Boundaries

- Orchestrate and validate; delegate repository-code changes to `implementer-ai-tools`.
- Write substance to disk and hand the user paths; reserve chat for questions, approvals, and a one-line outcome.
- Stay inside the working repository and preserve history predating this run.
- Record a needed redesign in the report for a future planning pass.
- Carry this role yourself. Not for pure Q&A.
