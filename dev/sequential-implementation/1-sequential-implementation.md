# Stage 1: Serial execution loop

## Objective

`skills/dev-ai-tools/SKILL.md` dispatches one code-writing subagent at a time. The wave /
concurrent-batch model is removed and replaced by an explicit serial rule; read-only work keeps
its concurrency.

## Files

- Modify: `skills/dev-ai-tools/SKILL.md` — the only file that describes execution waves

## Steps

1. In *Division of labor*, after the `**Limit**` paragraph, add one short paragraph stating the
   rule positively (rule 16), e.g.:
   `**Serial implementation.** One code-writing subagent runs at a time: dispatch the next stage, fix, or brief only after the current one reaches a terminal status (`F` or `E`). Read-only work — exploration, builds, tests, evidence collection — may run concurrently; it writes no repository code.`
2. *Branch per plan*, "One branch per base plan": `before running any of its waves` →
   `before running any of its stages`.
3. *Branch per plan*, "Rationale": `plans stay isolated and parallelizable, an unwanted plan` →
   `plans stay isolated, an unwanted plan` (branch isolation is the point; concurrency is gone).
4. *Plan intake*: `Intake is not repeated across waves or spawns.` →
   `Intake is not repeated across stages or spawns.`
5. *Subagent report channel*, **One live writer per file.**: delete the closing sentence
   `Parallel waves apply the same invariant across stages: concurrent batches each own a distinct stage file.`
   Keep the rest — ownership still opens with the Dispatch log row and closes with its Outcome,
   which is what a lost run and a returning ghost depend on.
6. Mode A step 5.3: `Build stage waves from the execution graph (skip `F` stages; defer `E`).` →
   ordering language, e.g. `Order the stages from the execution graph (skip `F` stages; defer `E`).`
7. Mode A step 5.4: `Run waves: sequential stages one-by-one; parallel-safe stages in concurrent non-overlapping implementer batches.`
   → `Run the stages one at a time in that order: dispatch a stage only after the previous one is terminal (`F` or `E`).`
8. Leave everything else untouched — status protocol, ledger, Lost runs, Mode B, Validation,
   frontmatter (its `description` is unaffected and stays within 500 characters).

## Tests

No automated test covers skill prose. Evidence for this stage:

- `grep -niE "wave|parallel|concurrent|batch" skills/dev-ai-tools/SKILL.md` — the only surviving
  hits are the read-only allowance added in step 1.
- `tools/lint.sh` exits 0 (skill layout, description cap, no `Stake`/`Continue?`).

## Acceptance criteria

- [ ] The skill states, once and positively, that code-writing dispatch is serial and read-only work may be concurrent
- [ ] No text authorizes concurrent implementer batches or waves anywhere in the file
- [ ] "One live writer per file" survives as the file-ownership rule, without its parallel-waves clause
- [ ] Mode A step 5 describes a strictly one-at-a-time loop keyed to terminal status
- [ ] `tools/lint.sh` passes

## Commit

Suggested message: `refactor(dev-ai-tools): dispatch one implementation at a time`

## Dependencies

- Requires stages: none
- Parallel-safe with: none — this plan makes execution serial

## Implementation log

- Edited `skills/dev-ai-tools/SKILL.md`: added the **Serial implementation** paragraph after the `**Limit**` paragraph in *Division of labor* (step 1); changed "before running any of its waves" → "before running any of its stages" in *Branch per plan* (step 2); changed "plans stay isolated and parallelizable" → "plans stay isolated" in *Branch per plan* Rationale (step 3); changed "Intake is not repeated across waves or spawns." → "...across stages or spawns." in *Plan intake* (step 4); deleted the closing sentence "Parallel waves apply the same invariant across stages: concurrent batches each own a distinct stage file." from **One live writer per file.** in *Subagent report channel*, keeping the rest of the paragraph (step 5); changed Mode A step 5.3 "Build stage waves from the execution graph..." → "Order the stages from the execution graph..." (step 6); changed Mode A step 5.4 "Run waves: sequential stages one-by-one; parallel-safe stages in concurrent non-overlapping implementer batches." → "Run the stages one at a time in that order: dispatch a stage only after the previous one is terminal (`F` or `E`)." (step 7).
- Evidence: `grep -niE "wave|parallel|concurrent|batch" skills/dev-ai-tools/SKILL.md` returns exactly one hit — the new **Serial implementation** paragraph's read-only allowance ("Read-only work ... may run concurrently").
- Evidence: `tools/lint.sh` exit code 0 — `345 ok, 1 skipped, 0 warnings` (the 1 skip is the version-bump check, which needs `--base <ref>` supplied by the lint workflow, unrelated to this change).
- No other file changed; `git diff --stat` shows only `skills/dev-ai-tools/SKILL.md`.

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | sonnet | a3df5b6a-5c49-4618-bafd-2e3896e3a992 | V → accepted |

Status: V
