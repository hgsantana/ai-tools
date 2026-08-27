---
name: dev-ai-tools
description: >
  Execute an accepted plan under dev/, or one task agreed with the user, then
  stop — carried in this session under the planner-ai-tools role. Use for
  /dev-ai-tools or after the user accepts a plan. Impact: edits code, runs
  commands, commits each step on a dedicated branch, archives the plan or
  task, pushes, and opens a pull request unattended once every step finishes.
argument-hint: "[plan paths, or the task to implement]"
---

# Execution

Executing an accepted plan under `dev/<slug>/`, or one task agreed with the user, then stopping.

## Workflow

You carry the `planner-ai-tools` role in this session. Pick the mode, run the sequence, then stop.

| Input | Mode |
|---|---|
| Empty, `dev`, `dev/<slug>/`, `dev/<slug>.md`, or an archived slug | **Plan** — run what is already decided |
| Anything else | **Task** — agree one task with the user, then run it |

Empty input takes every unfinished unit of work under `dev/` — base plans `dev/*/0-*.md` and task files `dev/*.md` — oldest first, one at a time. `dev/tmp/**` stays out of that queue, which is what makes spontaneous re-execution impossible. Keep the ignore policy intact: work under `dev/` stays trackable, and `dev/tmp/` — the single root for generated state, holding `finished/`, reports, and patches — stays ignored; add the ignore rule when the repository lacks it. Outside a git repository, work under `dev/` lives in `$HOME/.ai-tools-plans` (Windows: `%USERPROFILE%\.ai-tools-plans`).

### The sequence

Both modes run these steps, in order:

1. **Read the repository's documentation** — `README.md`, `AGENTS.md`, `docs/`, `CONTRIBUTING` — and hold to its rules, style, and language in everything you write.
2. **Fix the unit of work on disk.** Plan mode: load the whole plan directory `dev/<slug>/` once, before the first dispatch — the base file and every stage and fix file — leaving unrelated plans and `dev/tmp/**` unread. Task mode: agree the task first (*Agreeing the task*).
3. **Implement in short steps**, one commit each (*Dispatching*, *Branch and delivery*), keeping every log, diff, and output in files rather than in chat.
4. **Test before closing a step.** Behaviour and feature tests over what that step delivers, written and run, iterating the code until they pass. A passing build alone leaves a step open.
5. **Update the documentation** wherever the step changed behaviour or expectations.
6. **Archive** the plan or task file: copy, then remove — both are required (*Archival*).
7. **Commit the archival last**, then push and open the pull request (*Branch and delivery*).

## Agreeing the task (Task mode)

Before writing or changing anything, iterate with the user, in their language, until the request has no gaps:

- Name what is ambiguous, propose the improvements you see, and state the impact of the change and of each alternative.
- Size it: one task is one commit's worth of work. When it needs more, say so and recommend `plan-ai-tools`; run only what the user then agrees to.
- Derive a kebab-case `<slug>`. When an existing plan already covers the request, run that plan instead.

On agreement, write `dev/<slug>.md`:

````markdown
# <Title>

Status:

## Goal

What changes and why.

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

The questions stop there: from that point the run is unattended, exactly like Plan mode.

## Unattended

Once the unit of work is on disk, run it to the end without checkpoints. Interrupt the user only for:

- a blocker you cannot resolve;
- a decision the implementation itself uncovered that the plan or the agreed task does not settle;
- anything the Security rules reserve for the user — a cloud mutation, a destructive or shared-state operation.

Each travels as its own request — action, target, reason, impact — and runs only on an explicit yes for that action; approval never carries over. Work that does not depend on the answer continues meanwhile. Pushing the branch and opening the pull request once every step reads `F` are pre-authorized.

## Branch and delivery

Every change lands on `plan/<slug>`, cut from the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to `main`/`master`, or to the current branch when there is no remote). The default branch stays untouched, and one branch serves one plan or task; a reentered plan reuses its own. Verify the repository root first (`git rev-parse --show-toplevel`) and note a dirty tree in the report.

The history on that branch is symmetric:

1. **First commit** introduces the unit of work, before any implementation: `chore(dev): plan <slug>` for `dev/<slug>/`, `chore(dev): task <slug>` for `dev/<slug>.md`.
2. **One commit per step**, Conventional Commits, once that step validates. Stage path by path; check for secrets and binaries.
3. **Last commit** removes it: `chore(dev): archive <slug>` (*Archival*).

Then push `plan/<slug>` and open the pull request against the default branch (`gh pr create --base <default> --head plan/<slug> …`), drafting title and body from the accepted steps. The reviewer sees the plan or task introduced, implemented, and removed alongside the changes it produced, and an unwanted run is discarded by deleting its branch.

**Without a pull-request host** — determined at branch creation (a remote whose host supports pull requests; for GitHub, `gh auth status` plus a GitHub remote) — return a **local review request** instead: branch, base, `git diff --stat`, and a patch git writes itself, `git diff <default>...<branch> --output=dev/tmp/<slug>-review.patch`. Verify it with `--stat` or `wc -l` only, produce it with no file-writing tool, and leave its content on disk.

**A step left in `E`** stops the delivery: archive nothing, push nothing. Report how many steps failed and why, and return the choice as an approval request — retry them, deliver and archive anyway, or deliver and leave the work under `dev/`. An unattended `vibe-ai-tools` delivery, whose gate already promised no further checkpoints, decides for itself and records the choice and its reasoning in its decisions file.

## Dispatching

| Work | Who |
|---|---|
| Orchestrate steps, author briefs, review diffs, audit tests, commit, set status | this session (you), in the `planner-ai-tools` role |
| Write and edit the code and tests of one step | `implementer-ai-tools` |
| Run builds and tests, collect raw logs and diffs | `mechanical-ai-tools` |

You are the only spawner: a worker returns work it cannot carry as a dispatch request, for you to dispatch next. Only `implementer-ai-tools` writes repository code. One code-writing subagent runs at a time — dispatch the next step or correction once the current one is terminal (`F` or `E`); read-only discovery, builds, and tests may run in parallel.

**Budget**: 1 attempt plus up to 3 corrections per step, then `E`.

**Self-contained briefs.** A subagent does not load this skill. Give it only what it needs: the goal and the step's status row, the single assigned file (`dev/<slug>/<n>-<slug>.md`, a fix file `dev/<slug>/F<m>-<slug>.md`, or `dev/<slug>.md`), and, verbatim, *Implementer obligations* plus the report instruction below. Pass paths, never contents — relaying content creates a second, diverging copy of the truth, and on conflict the file wins.

Every dispatch and every correction round carries, verbatim:

> Report by appending to your assigned file, then finish your run — your final output reaches whoever spawned you automatically. Messaging and agent-addressing tools have no reliable address for your spawner; a guessed name misroutes the report.

**One live writer per file.** A file belongs to one running subagent at a time: ownership opens when its Dispatch log row is appended and closes when that row's Outcome is filled. Two writers on one file interleave their logs and corrupt the ledger the report is built from.

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

A subagent's claims and a passing build are evidence, not acceptance. Judge from verified facts:

1. Re-read the step's objective, allowed files, criteria, and implementation log.
2. Inspect the real diff (`git status`, `git diff`, log).
3. Check that the change meets the objective, stays inside the allowed files, implements every required item with no stubs, matches the surrounding style, adds nothing extraneous, and leaves no cleanup for later steps.
4. Pass or fail each acceptance criterion individually, with a reason.
5. **Audit the tests**: they assert observable behaviour, would fail on a regression, and weaken no existing suite.
6. Pass → `F`, commit. First failure → append concrete correction tasks to the file and set `R1`. Second → decompose the remaining corrections into fix files `dev/<slug>/F<m>-<slug>.md`, record the mapping in the parent file, dispatch each with its fix file alone, and set `R2` (or `R3`). Third → `E` with a failure report, then continue the steps that do not depend on it.

## Lost runs

A subagent can die without reporting. Detection uses only the filesystem and git, so it works in any harness.

- **Poll by comparing snapshots, not clocks**: the assigned file's size and mtime in epoch seconds (`stat -c %Y`, or `stat -f %m` on BSD/macOS) plus `git status --porcelain` over the step's files. A poll that differs is progress and resets the deadline, which is counted in consecutive unchanged polls. When elapsed time is genuinely needed, subtract epoch integers (`date +%s` against `stat`) — formatted timestamps print in local time, so on a UTC−3 host they declare every live run lost.
- **Diagnose from the ledger**: no session ID in the open row means the run never started, so a retry is safe; a session ID with no final status means it died mid-run.
- **Declare and re-dispatch in two acts.** Write `lost — <evidence>` into the open row, then re-read the file and re-take the snapshot. Anything changed since means the run is alive: clear the Outcome and resume waiting. Only a clean re-read authorises the next row and the next spawn.
- **Audit before re-dispatching**: a mid-run death leaves partial edits. Inspect the working tree restricted to that step's files and record in the file what is already done, so the replacement continues instead of colliding. Reverting those files is destructive to a writer that turns out to be alive — reserve it for a run the two-act check confirmed dead.
- **Reconcile a returning ghost**: its edits are in the diff and its log is in the file. Validate from the diff and repair the ledger — one row per attempt, truthful Outcome, duplicated attempts out of the count.
- **Account for it.** One re-dispatch of a lost run spends no correction round: the work was never reviewed. A second consecutive loss on the same step is structural — decompose into smaller fix files, or set `E` with the evidence.
- **Orphans at intake**: a step already in `W`, `R*`, or `T` when you load the work is an orphan from a previous run. Treat it as lost.

## Archival

A plan or task file is working state, not a record: it is versioned so an execution survives a lost session or a fresh clone, and it earns its place in the repository only while something is still left to resume. What survives on the remote is what the work produced — the commits, the tests, and the documentation it updated.

Archive once **every** step is terminal (`F`; an `E` stops the delivery) and every Dispatch log row has its Outcome filled — an open row means a writer may still return, and it still owns the file. Then do both steps:

1. **Copy locally** — `mkdir -p dev/tmp/finished`, then `cp -r dev/<slug> dev/tmp/finished/<slug>` for a plan, or `cp dev/<slug>.md dev/tmp/finished/<slug>.md` for a task. `dev/tmp/` is gitignored, so the copy stays on this machine alone.
2. **Remove from the repository** — `git rm -r dev/<slug>`, or `git rm dev/<slug>.md`.

Before committing, confirm `git ls-files dev/tmp` prints nothing and `git status` shows the deletion. Commit it path-scoped as `chore(dev): archive <slug>`: the last commit on the branch, after every step commit and before the push.

**Reentry.** An archived unit is picked up only when a dispatch names it by slug or path, and resolves to exactly `dev/tmp/finished/<slug>/0-<slug>.md` or `dev/tmp/finished/<slug>.md`; anything else is not an archived unit — report it and leave it. Copy it back under `dev/`, remove it from `dev/tmp/finished/`, commit the restore as `chore(dev): reopen <slug>`, then run it. `F` steps keep their status; only `E` steps run, each re-entering at `W` with a fresh 1 + 3 budget and its Dispatch log continuing the attempt counter. Refuse — and report why — when every step already reads `F`, or when `dev/<slug>` already exists: one unit per slug.

## Report

Write the report, then point at it. Every detail of the run already lives in the plan or task file — steps, logs, diffs, outputs — and the closing report goes to `dev/tmp/<slug>-report.md`. Chat gets that path, a one-line outcome, and anything that needs the user; where the harness can open a file in their editor, open it rather than pasting it.

The report file holds, per step and in execution order: what was delivered, in a line or two drawn from the accepted diff; the attempts, with the fix-file count when corrections were decomposed; and the runner — agent and model — per attempt, noting explicitly when attempts used different runners.

It closes with the `F`/`E` counts, the pull request URL or the local review patch path, the local archive path (`dev/tmp/finished/<slug>`), the commits created including the archival commit, anything still awaiting approval, every refused reentry with its reason, and for each `E` its cause and the decision the user has to make. Record only what the ledger and the files substantiate.

## Boundaries

- Orchestrate and validate; never write repository code yourself.
- Write substance to disk and hand the user paths; chat carries questions, approvals, and one line of outcome.
- Stay inside the working repository, and leave history predating this run intact.
- Record a needed redesign in the report rather than redesigning mid-run.
- Carry this role yourself. Not for pure Q&A.
