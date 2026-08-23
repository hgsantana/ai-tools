# Stage 3: State the rule once

## Objective

Serial implementation becomes a shipped rule, not only a skill behaviour: the README states it
as a repository rule, `USER-AGENTS.md` states it for every harness session, and the planner base
states it as a role rule. The README version is bumped for the shipped-content change.

## Files

- Modify: `README.md` — rule 8 gains the serial-dispatch sentence; version line bumped
- Modify: `USER-AGENTS.md` — one line under *The three agents*, next to spawn depth
- Modify: `agents/planner-ai-tools.md` — *Delegation* gains the one-writer-at-a-time rule

## Steps

1. `README.md` rule 8: append one sentence after the spawn-depth text, in the rule's voice —
   implementation dispatch is serial (one code-writing agent at a time), read-only discovery,
   builds, and tests may run concurrently. Do not add a new numbered rule: rules 9–28 are cited
   by number across the README, `tools/lint.sh`, and shipped artifacts (decision D3).
2. `README.md` line 3: `> **Version 0.0.29-ALPHA**` → `> **Version 0.0.30-ALPHA**`, everything
   else on that line unchanged. This satisfies `tools/lint.sh --base <ref>`
   (`check_version_bump`), which the CI lint job runs on the pull request (decision D1).
3. `USER-AGENTS.md`, section *The three agents*, immediately after the `**Spawn depth is one.**`
   paragraph: add one sentence — one code-writing agent runs at a time; read-only work
   (exploration, builds, tests) may run in parallel. Keep it to roughly one line: the file is
   7,512 characters and rule 3 caps it at 8,000. Verify with `wc -c USER-AGENTS.md`.
4. `agents/planner-ai-tools.md`, *Delegation*: add the same rule as a planner type rule — dispatch
   one code-writing assignment at a time, read-only discovery may be parallel. Step 3 of *Role*
   (parallel read-only exploration) stays exactly as it is.
5. Wording across the three files must agree with `skills/dev-ai-tools/SKILL.md` (stage 1) —
   same rule, no contradicting phrasing.

## Tests

Repository checks, run from the repository root:

- `tools/lint.sh` — exits 0. Relevant checks: instructions cap (rule 3), skill layout, no
  mentions of deleted files.
- `tools/test.sh` — the shell test suite exits 0 (nothing here touches `scripts/`, so this is a
  regression guard).
- `git stash`-free verification of the version check:
  `tools/lint.sh --base origin/master` reports `version bumped for shipped content change`.
- Story acceptance grep: `grep -rniE "parallel|concurrent" --include=*.md . | grep -v '^./dev/'`
  returns only read-only discovery and validation contexts plus the explicit serial statements.

## Acceptance criteria

- [ ] README rule 8 states serial code-writing dispatch and the read-only exception; no rule renumbering
- [ ] README version line reads `0.0.30-ALPHA`
- [ ] `USER-AGENTS.md` states the rule and is still at most 8,000 characters
- [ ] `agents/planner-ai-tools.md` *Delegation* states it; *Role* step 3 unchanged
- [ ] `tools/lint.sh` and `tools/test.sh` exit 0
- [ ] `tools/lint.sh --base origin/master` reports the version bump as satisfied

## Commit

Suggested message: `feat: make implementation dispatch serial across the toolkit`

## Dependencies

- Requires stages: 2
- Parallel-safe with: none — this plan makes execution serial

## Implementation log

- Step 1: `README.md` rule 8 — inserted "Dispatch of code-writing work is serial — one such agent runs at a time; read-only discovery, builds, and tests may run concurrently." after the spawn-depth sentences ("...the design assumes the shallowest.") and before "The **planner** role orchestrates...". No new numbered rule added; rule 8 kept its number.
- Step 2: `README.md` line 3 — `> **Version 0.0.29-ALPHA**` → `> **Version 0.0.30-ALPHA**`, rest of the line unchanged.
- Step 3: `USER-AGENTS.md`, *The three agents* — appended "One code-writing agent runs at a time; read-only work (exploration, builds, tests) may run in parallel." to the end of the `**Spawn depth is one.**` paragraph. `wc -c USER-AGENTS.md` → 7616 (cap 8,000); `tools/lint.sh`'s own count (trailing-newline-insensitive) reports 7580/8000.
- Step 4: `agents/planner-ai-tools.md`, *Delegation* — appended "Dispatch one code-writing assignment at a time; read-only discovery may run in parallel." to the end of the paragraph. *Role* step 3 (parallel read-only exploration) left untouched — verified by re-reading the file after the edit.
- Step 5: wording cross-checked against `skills/dev-ai-tools/SKILL.md`'s **Serial implementation** paragraph (not edited, per assignment) — same rule (one code-writing agent/subagent at a time; read-only work may run concurrently/in parallel), no contradicting phrasing.

### Test evidence

- `tools/lint.sh` (no `--base`): exit 0. `done: 345 ok, 1 skipped, 0 warnings`. The 1 skip is the version-bump check itself ("needs --base <ref>"), expected without that flag.
- `tools/test.sh`: exit 0. `done: 244 ok, 0 skipped, 0 warnings`.
- `tools/lint.sh --base origin/master`: exit 2, `WARN: shipped content changed without a README version bump (still 0.0.29-ALPHA, was 0.0.29-ALPHA): skills/dev-ai-tools/SKILL.md skills/plan-ai-tools/SKILL.md`. This check reads `git diff` between the base ref and HEAD, and `git show HEAD:README.md` — committed state only, not the working tree — per `check_version_bump()` in `tools/lint.sh`. My edits (including the version bump to `0.0.30-ALPHA`) are on disk but, per the implementer obligations, uncommitted. Once the planner commits this stage's changes, `HEAD:README.md` will read `0.0.30-ALPHA` and this check will report `ok: version bumped for shipped content change: 0.0.29-ALPHA -> 0.0.30-ALPHA`. Flagging this as an open item for the planner rather than a failure of the working tree's content.
- Story acceptance grep: `grep -rniE "parallel|concurrent" --include=*.md . | grep -v '^./dev/'` — outside `dev/`, hits are: `USER-AGENTS.md:52` and `README.md:57` (the new serial-dispatch sentences plus the pre-existing spawn-depth text), `agents/planner-ai-tools.md:11,20` (Role step 3 read-only exploration, unchanged; the new Delegation sentence), `skills/dev-ai-tools/SKILL.md:58` (pre-existing Serial implementation paragraph, not edited here), `skills/plan-ai-tools/SKILL.md:28` (pre-existing read-only exploration step, not edited here). All are either read-only-discovery contexts or explicit serial statements — no contradicting "parallel implementation" language.

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | sonnet | a3df5b6a-5c49-4618-bafd-2e3896e3a992 | V → accepted |

Status: V
