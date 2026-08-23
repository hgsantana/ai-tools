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
