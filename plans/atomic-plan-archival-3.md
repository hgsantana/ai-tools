# Stage 3: Version bump, coherence sweep, commit

## Objective

Bump the README version to `0.0.6-ALPHA`, prove repository-wide that no statement of the old per-file, mid-run archival rule survives anywhere, and land stages 1–3 as the single commit README rule 52 requires.

## Files

- Modify: `README.md` — the version header (rule 52: bumped in the same commit as the shipped-content change)
- Verify only (no edit): `agents/orchestrator-ai-tools.md`, `agents/planner-ai-tools.md`, `USER-AGENTS.md`, and every other tracked file

`README.md` gains no lifecycle text: by rules 2 and 14 it is the source of truth **about this repository** — its rules, processes, and installation — not a mirror of shipped agent behaviour, and it states no archival rule today. Its `What is inside` rows for the planner and orchestrator stay as they are.

## Steps

1. In `README.md`, replace `> **Version 0.0.5-ALPHA**` with `> **Version 0.0.6-ALPHA**` in the line immediately under the title, leaving the rest of that line unchanged. Confirm with `git grep -n "0\.0\.5"` that no other occurrence of the old version exists anywhere in the tree.
2. Run the coherence sweep and record its full output in the Implementation log:
   - `git grep -n -i "finished"` over the whole tracked tree;
   - `git grep -n "plans/finished"` over the whole tracked tree.
   Classify every hit as one of: (a) the ordinary English word in an unrelated sense — the scripts' and README's `2 finished with warnings` exit codes, the orchestrator's "a finished subagent's output", the `F` status rows "Finished — stage accepted", `agents/vibe-ai-tools.md`'s "the finished base plan", `skills/planner-ai-tools/SKILL.md`'s "On a finished plan" heading (these last two mean *authored*, not *archived* — leave them alone); or (b) a statement of the new lifecycle, consistent with stage 1's `## Plan archival`. Any hit that is neither is a leftover: fix it in its own artifact under the same one-statement-per-artifact rule, and record what was changed.
3. Confirm `.gitignore` still reads `/plans/*/` and needs no change: `plans/finished/<slug>/` is already covered.
4. Stage the change path by path (never `git add -A`): `README.md`, `USER-AGENTS.md`, `agents/orchestrator-ai-tools.md`, `agents/planner-ai-tools.md`, and this plan's root files `plans/atomic-plan-archival*.md`. Check the diff for secrets and binaries, then commit.

## Tests

No test suite; verification is command output, pasted into the Implementation log.

- `git grep -n "0\.0\.6-ALPHA" -- README.md` returns the version line; `git grep -n "0\.0\.5"` returns nothing.
- `wc -c USER-AGENTS.md` < 12,000 (README rule 3), re-checked here on the final tree.
- The two sweep greps above, with every hit classified (a) or (b).
- `git diff --stat` on the staged change lists exactly the four artifacts plus this plan's root files.
- `git status --short` is clean after the commit.

## Acceptance criteria

- [ ] `README.md` reads `Version 0.0.6-ALPHA`, and no `0.0.5` reference remains in the tree.
- [ ] The sweep output is in the Implementation log and every hit is classified; no statement of per-file or mid-run archival survives in any tracked file (story acceptance criterion 5).
- [ ] The four artifacts agree: the set stays in `plans/` until every stage is terminal, then moves whole to `plans/finished/<slug>/`; reentry only by explicit named dispatch, only with an `E`, refused and reported for an all-`F` set; the queue never scans the archive.
- [ ] `USER-AGENTS.md` is under 12,000 characters.
- [ ] `.gitignore` unchanged.
- [ ] One commit carries the four artifacts and the version bump together (rule 52); working tree clean afterwards.

## Commit

Suggested message:

```text
feat: archive plan sets atomically on completion (v0.0.6-ALPHA)

A plan's base, stage and fix files stay under plans/ for the whole
execution and move together to plans/finished/<slug>/ only when every
stage is terminal. An archived set with a failed stage reenters plans/
only on an explicit dispatch naming it; an all-finished set is final and
the attempt is refused. The queue never scans plans/finished/.
```

Add whatever commit trailer the running harness requires; add nothing else.

## Dependencies

- Requires stages: 1 and 2
- Parallel-safe with: none

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | fe332a05-e535-4d55-9744-c2c4ed36f88c | V → accepted (steps 1–3) |

Scope note (planner): step 4 (staging and the commit) is planner work under *Division of labor* and is executed by the orchestrator after validation, not by the dispatched implementer. The implementer runs steps 1–3 and collects the evidence.

## Implementation log

(Append-only log added by implementers and planner during execution.)

### Attempt 1 (implementer, sonnet)

**Step 1 — version bump.** Replaced `> **Version 0.0.5-ALPHA**` with `> **Version 0.0.6-ALPHA**` in `README.md` line 3, rest of line unchanged.

Command:
```
git grep -n "0\.0\.5"
```
Output: (empty — no occurrence remains anywhere in the tracked tree).

**Step 2 — coherence sweep.**

Command:
```
git grep -n -i "finished"
```
Output:
```
README.md:82:25. Scripts run to completion: per-item conflicts skip and report instead of aborting; destructive steps sit behind explicit flags (`--discard-local`, `--instructions`, `--purge`) and default to refusing; every mutating script supports `--dry-run`. Exit codes: `0` clean, `1` aborted on a precondition, `2` finished with warnings.
README.md:135:- **Exit codes** — `0` clean; `2` finished with `WARN` lines to review; `1` aborted on a precondition, nothing else touched.
USER-AGENTS.md:81:- Saved under `plans/` in the working repository. A plan's whole set — base plan, stage files, fix files — stays there for the entire execution and moves to `plans/finished/<slug>/` in a single move, only once every stage has finished or failed for good.
USER-AGENTS.md:82:- An archived set is never picked up on its own. One holding a stage that failed for good returns to `plans/` only when the orchestrator is dispatched on it by name; one whose stages all finished is final, and the attempt is refused.
USER-AGENTS.md:86:- In a git repository, root plan files (`plans/*.md`) are versioned: keep them out of ignore rules and include them in path-scoped commits. Every generated subdirectory under `plans/` is transient and must be ignored (`plans/*/`), including `finished/`, `dev/`, and `vibe/`.
agents/orchestrator-ai-tools.md:17:| An archived slug, or `plans/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
agents/orchestrator-ai-tools.md:64:Implementers must not open other stage files, base plans, or `plans/finished/**`. Keep parent stage files and unassigned fix files out of decomposed fix prompts.
agents/orchestrator-ai-tools.md:68:Applies *Truth on disk* (user-wide instructions). The assigned stage/fix/brief file is the only authoritative report channel. A subagent reports by (1) appending Implementation log entries and its final status line to that file, and (2) finishing its run — every harness returns a finished subagent's output to its spawner. Neither requires knowing an address, so this works in any harness.
agents/orchestrator-ai-tools.md:102:| `F` | Finished — stage accepted | **planner** |
agents/orchestrator-ai-tools.md:127:- **Archive** when every stage row of the base plan reads `F` or `E` — with or without failures — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and it must never find its file moved. Move the whole set in one operation into `plans/finished/<slug>/`; nothing of that plan is left under `plans/`.
agents/orchestrator-ai-tools.md:128:- The moved files are versioned while `plans/finished/` is ignored, so the move is a tracked deletion: commit it path-scoped as `chore(plans): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean.
agents/orchestrator-ai-tools.md:129:- **The queue never reads the archive.** `plans/finished/**` is never scanned, globbed, or listed as a source of work (Mode A step 2). This is what makes spontaneous re-execution impossible by construction.
agents/orchestrator-ai-tools.md:130:- **Reentry** happens only on a dispatch naming an archived plan by slug or path, and resolves to exactly `plans/finished/<slug>/<slug>.md`; anything else is not an archived set — report it and touch nothing. Read that base plan's stage table:
agents/orchestrator-ai-tools.md:138:2. Discover base plans: `plans/*.md` (excluding `*-<digits>.md` stage files, `*-F<digits>.md` fix files, `plans/finished/**`, and `plans/dev/**`). Never execute stages/fixes without their base.
agents/planner-ai-tools.md:28:  finished/<slug>/    # the whole set, moved here by the orchestrator in one move, only once every stage is terminal (`F` or `E`)
agents/planner-ai-tools.md:73:| `F` | Finished — stage accepted | **planner** |
agents/planner-ai-tools.md:124:- Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.
agents/vibe-ai-tools.md:48:- Dispatch the shipped `orchestrator-ai-tools` agent on the finished base plan (same named-agent fallback as Phase 4). It creates the plan's branch, implements, validates, and commits unattended.
scripts/powershell/install.ps1:11:# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/powershell/reinstall.ps1:14:# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/powershell/remove.ps1:14:# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/powershell/update.ps1:11:# Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/shell/install.sh:17:Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/shell/reinstall.sh:21:Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/shell/remove.sh:21:Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
scripts/shell/update.sh:18:Exit codes: 0 clean, 1 aborted on a precondition, 2 finished with warnings.
skills/planner-ai-tools/SKILL.md:24:## On a finished plan
```

Command:
```
git grep -n "plans/finished"
```
Output:
```
USER-AGENTS.md:81:- Saved under `plans/` in the working repository. A plan's whole set — base plan, stage files, fix files — stays there for the entire execution and moves to `plans/finished/<slug>/` in a single move, only once every stage has finished or failed for good.
agents/orchestrator-ai-tools.md:17:| An archived slug, or `plans/finished/<slug>/` | **A** | That set only, after reentry (*Plan archival*) |
agents/orchestrator-ai-tools.md:64:Implementers must not open other stage files, base plans, or `plans/finished/**`. Keep parent stage files and unassigned fix files out of decomposed fix prompts.
agents/orchestrator-ai-tools.md:127:- **Archive** when every stage row of the base plan reads `F` or `E` — with or without failures — and every Dispatch log row in the set has its Outcome filled: an open row means a writer may still return (*Lost runs*), and it must never find its file moved. Move the whole set in one operation into `plans/finished/<slug>/`; nothing of that plan is left under `plans/`.
agents/orchestrator-ai-tools.md:128:- The moved files are versioned while `plans/finished/` is ignored, so the move is a tracked deletion: commit it path-scoped as `chore(plans): archive <slug>`, after that plan's stage commits and before its PR or patch preparation, so the branch ends clean.
agents/orchestrator-ai-tools.md:129:- **The queue never reads the archive.** `plans/finished/**` is never scanned, globbed, or listed as a source of work (Mode A step 2). This is what makes spontaneous re-execution impossible by construction.
agents/orchestrator-ai-tools.md:130:- **Reentry** happens only on a dispatch naming an archived plan by slug or path, and resolves to exactly `plans/finished/<slug>/<slug>.md`; anything else is not an archived set — report it and touch nothing. Read that base plan's stage table:
agents/orchestrator-ai-tools.md:138:2. Discover base plans: `plans/*.md` (excluding `*-<digits>.md` stage files, `*-F<digits>.md` fix files, `plans/finished/**`, and `plans/dev/**`). Never execute stages/fixes without their base.
agents/planner-ai-tools.md:124:- Write only under `plans/`, never into `plans/finished/` — the archive is the orchestrator's.
```

**Classification of every hit (both greps combined, deduplicated):**

(a) ordinary English word in an unrelated sense — leave alone:
- `README.md:82`, `README.md:135` — scripts' exit-code "2 finished with warnings" / "finished with WARN lines".
- `scripts/powershell/install.ps1:11`, `reinstall.ps1:14`, `remove.ps1:14`, `update.ps1:11`, `scripts/shell/install.sh:17`, `reinstall.sh:21`, `remove.sh:21`, `update.sh:18` — same exit-code phrase in each maintenance script.
- `agents/orchestrator-ai-tools.md:68` — "a finished subagent's output" (a subagent process ending, not archival).
- `agents/orchestrator-ai-tools.md:102` and `agents/planner-ai-tools.md:73` — `F` status row "Finished — stage accepted" (a stage's own terminal status, not the archive move).
- `agents/vibe-ai-tools.md:48` — "the finished base plan" (means *authored*, i.e. the plan the planner produced, not *archived*).
- `skills/planner-ai-tools/SKILL.md:24` — "## On a finished plan" heading (same *authored* sense as above).

(b) statement of the new lifecycle, consistent with `agents/orchestrator-ai-tools.md`'s `## Plan archival` (the canonical statement, verified stage 1's edit is unchanged since it is the section itself):
- `USER-AGENTS.md:81` — whole-set, single-move-on-completion statement — consistent.
- `USER-AGENTS.md:82` — reentry-by-name / all-`F`-refusal statement — consistent.
- `USER-AGENTS.md:86` — `plans/*/` ignore rule naming `finished/`, `dev/`, `vibe/` — consistent.
- `agents/orchestrator-ai-tools.md:17` — routing table row for an archived slug/path — consistent.
- `agents/orchestrator-ai-tools.md:64` — implementer isolation from `plans/finished/**` — consistent.
- `agents/orchestrator-ai-tools.md:127-130` — the `## Plan archival` section itself (archive condition, tracked-deletion commit, never-scan invariant, reentry resolution) — canonical, source of the rule.
- `agents/orchestrator-ai-tools.md:138` — Mode A step 2's exclusion of `plans/finished/**` from base-plan discovery — consistent.
- `agents/planner-ai-tools.md:28` — plan-layout comment: whole set moved by the orchestrator in one move, only once every stage is terminal — consistent.
- `agents/planner-ai-tools.md:124` — planner never writes into `plans/finished/` — consistent.

**No leftover found.** Every (b) hit agrees with the atomic, whole-set model in `## Plan archival` (agents/orchestrator-ai-tools.md:123-133); none describes a per-file or mid-run move. No edit made to `agents/orchestrator-ai-tools.md`, `agents/planner-ai-tools.md`, or `USER-AGENTS.md` — the sweep found no genuine leftover in any of them.

**Step 3 — `.gitignore` check.**

Command:
```
grep -n "plans" .gitignore
```
Output:
```
2:/plans/*/
```
`.gitignore` already reads `/plans/*/`; this covers `plans/finished/<slug>/`. No change made.

**Applicable Tests (steps 1-3 scope only; step 4 staging/commit deferred to orchestrator):**

```
$ git grep -n "0\.0\.6-ALPHA" -- README.md
README.md:3:> **Version 0.0.6-ALPHA** — under active development. Usable for testing; no guarantees, and no backward compatibility between alpha versions (rule 4).

$ git grep -n "0\.0\.5"
(no output)

$ wc -c USER-AGENTS.md
11273 USER-AGENTS.md
```
11273 < 12000: pass. Both sweep greps re-run and reproduced above with full classification.

Status: V

## Validation (planner)

Diff inspected: `README.md` changes exactly one character run on line 3 (`0.0.5-ALPHA` → `0.0.6-ALPHA`), rest of the line and the whole file otherwise untouched. `git status --short` shows only the four artifacts modified plus the untracked `plans/` — `.gitignore`, `scripts/**`, `skills/**`, and `agents/<harness>/**` are unchanged.

Acceptance criteria, each passed:

1. `README.md` reads `Version 0.0.6-ALPHA`; `git grep -n "0\.0\.5"` returns nothing (re-run independently by the planner).
2. The sweep output is in the Implementation log with every hit classified; no statement of per-file or mid-run archival survives. The planner re-checked the (a) classifications: the eight script exit-code lines, the two README exit-code lines, "a finished subagent's output", the two `F` status rows, `agents/vibe-ai-tools.md:48` and `skills/planner-ai-tools/SKILL.md:24` all use "finished" in the unrelated or *authored* sense and are correctly left alone.
3. The four artifacts agree on the whole-set move, the terminal trigger, named-dispatch reentry, the refusals, and the never-scan invariant.
4. `wc -c USER-AGENTS.md` = 11273 < 12,000.
5. `.gitignore` unchanged, still `/plans/*/`.
6. Step 4 executed by the planner below — one commit carrying the four artifacts and the version bump together (README rule 4 / line 52).

Sweep scope note: `git grep` searches tracked files only, so the plan files under `plans/` (untracked at sweep time) were outside it. They are this plan's own records, not shipped artifacts, and state the new lifecycle by construction.

## Step 4 (planner) — staging and commit

Staged path by path, never `git add -A`: `README.md`, `USER-AGENTS.md`, `agents/orchestrator-ai-tools.md`, `agents/planner-ai-tools.md`, and this plan's root files `plans/atomic-plan-archival*.md`. Diff checked for secrets and binaries: text-only Markdown, no credentials, no binary blobs.
