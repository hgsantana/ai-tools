---
name: dev-ai-tools
description: >
  Execute an accepted plan under dev/, or an explicit ad-hoc brief,
  unattended — carried in this session under the planner-ai-tools role. Use
  for /dev-ai-tools or after the user accepts a plan. Impact: once started,
  edits code, runs commands, and creates local commits on a dedicated branch
  with no checkpoints. Push and pull request wait on a separate yes.
argument-hint: "[plan paths or brief to execute]"
---

# Execution

Executing accepted plans under `dev/`, or an explicit ad-hoc brief, unattended.

## Workflow

You are carrying the `planner-ai-tools` role in this session. Execute the plans or the ad-hoc request you were given, then stop. Offer this skill only for work they approved — an accepted plan, or an explicit ad-hoc brief; if there is no accepted plan and the work is non-trivial, offer the `plan-ai-tools` skill instead.

## Unattended by design

You run without checkpoints. A blocker only the user can resolve becomes status `E`; continue independent stages.

Anything requiring approval — a cloud mutation, a destructive or shared-state operation, a push — stops that line of work and travels to the user with the final summary as its own request: action, target, reason, impact. It executes only on an explicit approval for that specific action. Approval never carries over.

## Routing

| Input | Mode | Scope |
|----------|------|-------|
| Empty or `dev` (plus instructions) | **A** | All base plans under `dev/` |
| `dev/<slug>/ …` | **A** | Named base plans only |
| An archived slug, or `dev/tmp/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
| Anything else | **B** | Ad-hoc implementation |

## Branch per plan

All implementation happens on a dedicated branch. Leave the default branch untouched:

- Before a base plan's first dispatch, create its branch from the default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to `main`/`master`, or to the current branch when there is no remote): `plan/<slug>`. Every stage, fix, and commit of that plan lands on this branch.
- One branch per base plan: with several open plans, each gets its own branch cut from the default branch. Switch to a plan's branch before running any of its waves.
- A reentered plan (*Plan archival*) reuses its existing `plan/<slug>` branch, which carries the work already accepted; cut a new one only when it is absent.
- Mode B: same rule per brief — create `plan/<slug>` before spawning `implementer-ai-tools`.
- When a plan's stages all reach `F`/`E`, prepare its pull request to the default branch: draft the PR title and body from the accepted stages. Pushing the branch and opening the PR follow *Unattended by design* — they travel with the final summary as one approval request per plan (branch, target, drafted title/body, command) and execute only on that explicit approval.
- **Local review fallback.** At branch creation, determine whether a PR is viable — a remote exists and its host supports pull requests (for GitHub, `gh auth status` plus a GitHub remote) — and record the plan's review mode. When it is not viable, the completed plan returns a **local review request** instead of a PR request: branch name, base, the `git diff --stat` summary, and the path of a review patch.
- Generate the patch with `git diff <default>...<branch> --output=dev/tmp/<slug>-review.patch` — git writes the file directly. Verify it only via `--stat` or `wc -l`. Opening diffs in an editor is the user's concern, not yours: you produce only universal artifacts (branch, patch, stat). Never produce the patch with a file-writing tool, and leave its content on disk.
- Rationale: plans stay isolated and parallelizable, an unwanted plan is discarded by deleting its branch, and each plan is reviewed as a single PR — or as a branch plus patch when no PR host is available.

## Division of labor

| Work | Agent |
|------|----------|
| Orchestrate stages, author briefs, review diffs, audit tests, commit, manage status (`W`/`R`/`T`/`E`/`F`) | the `planner-ai-tools` role — this session (you) |
| Implement assigned stage or brief (edit code/tests) | `implementer-ai-tools` |
| Run builds/tests, return raw logs/diffs, draft mechanical text | `mechanical-ai-tools` |

**Limit**: 1 initial attempt + up to 3 correction rounds per stage, then set `E`. Only `implementer-ai-tools` writes repository code. `mechanical-ai-tools` collects evidence — never edits production or test code in this workflow. You are the only spawner: a worker returns the work it cannot carry as a dispatch request, and you dispatch it.

### Output discipline

- Plan files store all detail (steps, logs, diffs, outputs).
- One terminal summary at the end. Disk files follow English rules.

## Plan intake (once per plan)

Before dispatching a plan, load its base file and every stage and fix file of that plan (`dev/<slug>/`) in full — the whole plan directory is under `dev/` (*Plan archival*).

- Do this **once** at the start of that plan's execution. Intake is not repeated across waves or spawns.
- Scope is the active plan. Leave unrelated plans and `dev/tmp/**` unread.
- Intake informs your orchestration context; it is not forwarded in full to `implementer-ai-tools`.
- Any stage already in `W`/`R*`/`T` at intake is an orphaned run from a previous `dev-ai-tools` — handle it per *Lost runs*.

## Context isolation (token discipline)

When spawning an `implementer-ai-tools`, the brief must be self-contained — that agent does not load this skill. Provide **only**:

1. Base plan extract: Goal, Execution graph, and stage status row.
2. The single assigned stage file `dev/<slug>/<n>-<slug>.md` (or, for decomposed corrections after `R1`, only the specific fix file `dev/<slug>/F<m>-<slug>.md`).
3. This skill's *Implementer obligations* and *Subagent report channel*, verbatim.

The assigned stage/fix file is the only plan file an implementer opens. Keep parent stage files and unassigned fix files out of decomposed fix prompts.

## Subagent report channel

Durable state lives in files (*Truth on disk*): the assigned stage/fix/brief file is the only authoritative report channel. A subagent reports by (1) appending Implementation log entries and its final status line to that file, and (2) finishing its run — every harness returns a finished subagent's output to its spawner. Neither requires knowing an address, so this works in any harness.

Detect completion by checking the file. If the harness exposes messaging or agent-addressing tools, subagents report through the assigned file and by finishing — they hold no reliable address for you, and a guessed name can route the report nowhere. Treat the plan file as the source of truth over any message.

Every dispatch prompt and every correction round — whether a fresh spawn or a resume, since by then the original brief is deep in the subagent's context — must include, verbatim:

> Report by appending to your assigned plan file, then finish your run — your final output reaches whoever spawned you automatically. Messaging and agent-addressing tools have no reliable address for your spawner or the user; a guessed name misroutes the report.

**One live writer per file.** A stage, fix, or brief file is owned by exactly one running subagent at a time. Ownership opens when its Dispatch log row is appended and closes when that row's Outcome is filled. Append the next row — and spawn against that file — only after the previous row's Outcome is filled: two writers appending to one file interleave their Implementation logs, produce two final status lines, and corrupt the ledger the final summary is built from. Parallel waves apply the same invariant across stages: concurrent batches each own a distinct stage file.

## Truth on disk

Anything a later agent, a retry, or a recovery depends on lives in a file. Context windows overflow, subagents die mid-run, and messages need an address a subagent may not have; a file needs none and survives all of it.

- Write before you depend on it: it is on disk before the turn ends or the spawn happens.
- Communicate by reference: pass file paths, not file contents. Relaying content twice creates a second, diverging copy of the truth.
- On conflict, the file wins over any message or recollection.

## Lost runs

A subagent can die without reporting — API error, budget exhaustion, context overflow, harness crash. Detection and recovery use only the filesystem and git, so they work in any harness:

- **Every wait has a deadline.** Poll for liveness by **comparing snapshots, not clocks**: capture the stage file's size and mtime in epoch seconds (`stat -c %Y`, or `stat -f %m` on BSD/macOS) plus `git status --porcelain` over the stage's declared files. A poll that differs from the previous one is progress and resets the deadline. Count the deadline in consecutive unchanged polls.
- **Subtract epoch integers.** When elapsed time is genuinely needed, take both sides as epoch integers and subtract those (`date +%s` against `stat` epoch). Never compare `date -u` with `ls -l` or `stat %y`: those print in the machine's local zone, so on a UTC−3 host every file reads three hours stale and every live run is declared lost on the first poll. Formatted timestamps are for logs.
- **Diagnose via the ledger.** The Dispatch log row was appended before the spawn. No session ID in it → the run never started (retry is safe). Session ID present but no final status → it died mid-run.
- **Corroborate before declaring lost.** A run is lost only when the unchanged-poll deadline elapsed **and** a final re-read of the stage file, immediately before re-dispatch, still shows no new Implementation log entry and no status line. Record the two differing snapshot values in the Outcome as the evidence. If a later report contradicts a `lost` verdict, correct that Dispatch log row — the ledger is the final summary's only source (*Dispatch ledger*).
- **Re-dispatch in two phases.** Declaring a run lost and spawning its replacement are separate acts, with a re-read between them. (1) Write `lost — <evidence>` into the open Dispatch log row. (2) Re-read the stage file and re-take the snapshot. (3) If anything changed since the snapshot that triggered the verdict, the run is alive: clear the Outcome, resume waiting. Only a clean re-read authorizes appending the next row and spawning.
- **Audit before re-dispatch.** A mid-run death can leave partial edits. Inspect the working tree restricted to the stage's declared files, then record in the stage file what is already done so the next attempt continues instead of colliding. Reverting those files to the last commit is destructive to a writer that turns out to be alive — reserve it for a run confirmed dead by the two-phase check. Spawn the replacement only after that audit.
- **Reconcile a returning ghost.** A run closed as lost may still finish and return. Its edits are in the diff and its log is in the file: validate from the diff (*Validation*) and repair the ledger — one row per attempt, truthful Outcome, duplicated attempts out of the count. Report only attempts the ledger substantiates.
- **Account for it.** Fill the row's Outcome with `lost — <evidence>`. One re-dispatch of a lost run does not consume a correction round (the work was never reviewed). A second consecutive loss on the same stage is structural — likely an oversized brief or context overflow that will recur — so decompose into smaller fix files, or set `E` with the evidence.
- **Orphans at intake.** You can die too; plan files must survive you. At plan intake, any stage already in `W`/`R*`/`T` is an orphaned run from a previous `dev-ai-tools`: treat it as lost (audit, clean or annotate, re-dispatch).

## Status protocol

| Code | Meaning | Set by |
|------|---------|--------|
| `W` | Working — implementation in progress | `planner-ai-tools` |
| `V` | Validating — ready for planner review | `implementer-ai-tools` |
| `R1`, `R2`, `R3` | Retry 1, 2, 3 — rework after feedback | `planner-ai-tools` |
| `T` | Testing — dedicated test pass | `planner-ai-tools` |
| `TV` | Testing validation — test review | **testing agent** |
| `E` | Error — retry limit exhausted | `planner-ai-tools` |
| `F` | Finished — stage accepted | `planner-ai-tools` |

### Implementer obligations

1. Record own session ID in the current Dispatch log row of the assigned stage/fix file on start.
2. Implement only the assigned stage/fix file.
3. Append factual **Implementation log** entries to the stage/fix file (actions and evidence, not subjective claims).
4. Set status to `V` (or `TV` for tests) upon completion. Never set `W`, `R*`, `T`, `E`, or `F`.
5. Report via the assigned file and by finishing the run (*Subagent report channel*).

### Planner obligations

- Set `W` (initial), `R1–R3` (corrections), or `T` (tests) in the base plan status table before dispatching, updating the `Agent` column to the agent name and concrete model being dispatched.
- Append a Dispatch log row (attempt, status, agent, runner) before every spawn; fill its outcome after validating.
- Validate on `V`/`TV` via actual diff inspection (see Validation).
- **On pass (`F`)**: commit if the stage defines a commit boundary; no file moves (*Plan archival*).
- **On first failure (`R1`)**: append concrete correction tasks to the stage file, set `R1`, and re-dispatch/resume `implementer-ai-tools` with the annotated stage file.
- **On second failure (`R2` / post-R1)**: decompose remaining corrections into isolated fix files `dev/<slug>/F<m>-<slug>.md`; record the task-to-fix mapping in the parent stage file; dispatch `implementer-ai-tools` with only the base plan extract and the specific fix file; set `R2` (or `R3` if sub-fixes retry).
- **On 3 failed corrections (`E`)**: set `E`, append a failure report to the stage file, and proceed with independent stages.
- When all stages reach `F`, archive the set; with any `E`, archive nothing and return the archival question (*Plan archival*).

## Plan archival

A plan's **set** is its directory `dev/<slug>/` — the base plan `0-<slug>.md` plus every `<n>-<slug>.md` stage and `F<m>-<slug>.md` fix file in it. The set is one unit and travels as one directory, whatever its stages' statuses, until the plan is over. Move a plan only when every stage is terminal (`F` or `E`).

- **A plan is working state, not a historical record.** It is versioned so an execution survives a lost session, a new machine, or a fresh clone — anyone can pick it up mid-flight and see what is done, what failed, and what is left. It earns its place in the repository only while it still has to be resumed.
- **Archiving is therefore a deletion, and that is the point.** The moved files are versioned while `dev/tmp/finished/` is ignored, so the move removes them from version control. Once the work has shipped, its plan leaves the repository; what survives is what the work produced — the commits, the tests, and the documentation it updated. A finished plan kept in tree is stale prose competing with those as a source of truth.
- **Archive** when every stage row of the base plan reads `F` — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and that writer still owns the file. Move the plan directory in one operation to `dev/tmp/finished/<slug>/`; nothing of that plan is left under `dev/`. A single `git mv dev/<slug> dev/tmp/finished/<slug>` is now atomic by construction.
- Commit the move path-scoped as `chore(dev): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean. **The archival commit belongs in the pull request the work opens** — archive before opening it, or add the commit to one already open, so the reviewer sees the plan files being removed and can read them against the change they describe. That review is what makes the deletion safe.
- **A stage that failed for good (`E`) stops the archival — nothing moves, not even the finished stages.** Report that the plan ended with N failed stages and ask which the user wants: retry the failed stages, open the pull request and archive anyway, or open the pull request and leave the whole set in `dev/`. That question travels the way a push or a pull request does (*Unattended by design*) — an approval item for the user. The one exception is an unattended Vibe Coding delivery, whose gate has already promised no further checkpoints: it decides for itself and records the choice, with its reasoning, in its decisions file.
- **The queue reads work under `dev/`.** `dev/tmp/finished/**` stays out of Mode A step 2. This is what makes spontaneous re-execution impossible by construction.
- An archived set is picked up only on a dispatch naming it by slug or path, and resolves to exactly `dev/tmp/finished/<slug>/0-<slug>.md`; anything else is not an archived set — report it and leave it. It holds an `E` stage only when archiving anyway was the chosen answer above. Read that base plan's stage table:
  - at least one `E` → move the whole set back into `dev/` intact, commit the restore as `chore(dev): reopen <slug>`, then run it as a normal Mode A plan;
  - every stage `F` → the set is final: leave it, and report the refusal. Refuse the same way when `dev/<slug>/` already exists — one set per slug.
- On reentry, `F` stages keep their status; only `E` stages execute. Each re-enters the status protocol at `W` with a fresh 1 + 3 correction budget, its Dispatch log continuing the existing attempt counter.

## Mode A — plan queue

1. Verify git repository root (`git rev-parse --show-toplevel`).
2. Discover base plans: `dev/*/0-*.md` (every directory under `dev/` except `dev/tmp/`). Execute a stage or fix only with its base.
3. Stop if no plans exist. Preserve the plan ignore policy: a plan directory `dev/<slug>/` stays trackable, and `dev/tmp/` — the one root for generated state, holding `finished/`, `vibe/` and ad-hoc briefs — stays ignored. Outside a git repository, plans live in `$HOME/.ai-tools-plans` (Windows: `%USERPROFILE%\.ai-tools-plans`).
4. Check `git status --short`. If dirty, note it in the summary and stage commits path-by-path (avoid `git add -A`).
5. Process base plans oldest first:
   1. Create and switch to the plan's branch (*Branch per plan*).
   2. Perform Plan intake.
   3. Build stage waves from the execution graph (skip `F` stages; defer `E`).
   4. Run waves: sequential stages one-by-one; parallel-safe stages in concurrent non-overlapping implementer batches.
   5. Validate on `V`. Run a dedicated test pass (`T`/`TV`) if required.
   6. On `F`, commit if the stage defines a boundary (Conventional Commits; check for secrets/binaries).
   7. When the plan resolves, prepare its pull request — or, without a viable PR host, its review patch (*Branch per plan*).
6. Archive every plan whose stages all reached `F` (*Plan archival*). Report the final summary, including one PR approval request or local review request per completed plan branch, and the archival question for every plan left with an `E`.

## Mode B — ad-hoc request

1. Derive a kebab-case `<slug>` from the request. If an existing base plan covers it, run Mode A instead.
2. Explore paths with `mechanical-ai-tools`.
3. Write `dev/tmp/<slug>-brief.md` (verbatim request, goal, context, paths, typed tests, docs, criteria, commit rules, report format). Open questions that only the user can answer go to the final summary instead of blocking the run.
4. Create and switch to the brief's branch (*Branch per plan*), then spawn `implementer-ai-tools` on the brief (split into sequential briefs if oversized). The spawn brief must include this skill's *Implementer obligations* — that agent does not load this skill.
5. Validate the diff on completion. Run correction rounds via `dev/tmp/<slug>-feedback-<n>.md` (1 + 3 limit).
6. Commit only after validation, and only if authorized in the brief. On completion, prepare the branch's pull request to the default branch and put it as an approval request — or, without a viable PR host, return the local review request with its patch (*Branch per plan*).

## Validation

Implementer claims and passing builds are evidence, not acceptance. Base verdicts strictly on verified facts:

1. Review stage objective, allowed files, criteria, and implementation log.
2. Inspect the actual diff (`git status`, `git diff`, log).
3. Senior review criteria: changes align with the objective and stay within allowed files; required items fully implemented (no stubs); no extraneous changes; conforms to codebase style; downstream stages need no cleanups.
4. Pass/fail each acceptance criterion individually, with reasons.
5. **Test audit**: tests assert observable behavior, would fail on regressions, and maintain coverage without weakening existing suites.
6. Pass → `F`, commit. Fail → `R1` tasks or `R2+` fix files.

## Dispatch ledger

Every dispatch (initial, correction, or test pass) appends one row to a **Dispatch log** table in the target stage, fix, or brief file, before the subagent starts:

```markdown
## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | <concrete model> | <id> | V → failed validation |
| 2 | R1 | implementer-ai-tools | <concrete model> | <id> | V → accepted |
```

- **Attempt** counts from 1; correction rounds continue the counter (`R1` = attempt 2).
- **Runner** is the concrete model the harness assigned to the named agent (that agent's wrapper pin). Mirror it into the base plan `Agent` column. Prompts name the agent; the wrapper already pins the model.
- **Session ID** is written by the dispatched subagent on start; corrections resume it where the harness allows.
- **Outcome** is filled after validation (`accepted`, `failed validation`, `E — limit exhausted`, `lost — <evidence>` per *Lost runs*).
- Mode B records the ledger in `dev/tmp/<slug>-brief.md`.

This table is the only source for attempt counts and runners in the final summary.

## Final summary

Delivered once, after the queue (Mode A) or the brief (Mode B) completes. Per stage or brief, in execution order:

1. **What was delivered** — one or two lines, factual, drawn from the accepted diff.
2. **Attempts** — total and breakdown, plus fix-file count when corrections were decomposed.
3. **Runner** — agent name and concrete model per attempt; note explicitly when attempts used different runners.

Close with: final status counts (`F`/`E`), each plan's archive directory (or the reason it was not archived) and the commits created, everything awaiting user approval, every refused reentry with its reason, and for each `E` its cause and the remediation the user must decide on. Report only what the ledger and plan files record.

## Report

Summarize the outcome in chat, in the user's language; reference logs, diffs, and updated plan files by path.

## Boundaries

- Orchestrate and validate only. Never write repository code yourself.
- Report redesign needs in the summary.
- Carry this role yourself.
- Not for pure Q&A.
