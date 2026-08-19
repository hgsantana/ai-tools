# Stage 6: PowerShell remove, reinstall, and update cases

## Objective

Mirror stages 3 and 4 on the PowerShell side, completing the contract coverage for `remove.ps1`, `reinstall.ps1`, and `update.ps1`.

## Files

- Create: `tools/test/remove.ps1` — remove and reinstall cases; UTF-8 with BOM, LF
- Create: `tools/test/update.ps1` — update cases; UTF-8 with BOM, LF
- Modify: `tools/test/lib.ps1` — add `T-OriginCommit`, mirroring `t_origin_commit` from stage 4

## Steps

1. **One-to-one mapping.** Every `case_*` function added by stages 3 and 4 gets a counterpart here, and each file opens with the mapping table (shell case name → PowerShell case name). A shell case with no counterpart must be listed with the reason.
2. **Remove cases** (`tools/test/remove.ps1`): unlink what install linked; idempotent second run; unmodified copy removed and modified copy kept (`SKIP: copy was modified locally, user work kept:`); foreign file never removed; symlink to something else never removed; `$HOME\AGENTS.md` byte-identical after plain, `-Instructions`, and `-Purge -Yes` runs; `-Instructions` gate including the shared `GEMINI.md` scope rule; Grok managed block removed while an unmanaged one is left alone; stale-link sweep and `-NoSweep`; `-Purge` refusing without confirmation (`T-RunStdin` feeding `no`) and deleting with `-Yes`; `-DryRun` changing nothing; removal with the clone deleted; precondition failures exiting `1`.
3. **Reinstall cases** (same file): clean run reaching the same end state as a fresh install; stale link cleared; locally modified copy kept; fresh-clone path through the fixture's `insteadOf` rewrite; uncommitted change without `-DiscardLocal` → exit `1` with nothing removed or installed; `-NoInstructions`; `-DryRun`.
4. **Update cases** (`tools/test/update.ps1`): reset guard on a dirty tree and on a commit ahead of `origin/master`, both exit `1`; `-DiscardLocal` performing the reset; the reset staying inside the clone; newly shipped content linked; stale copy refreshed; locally modified copy kept; up-to-date copy reported; `-NoReset`; `-DryRun`; missing clone → exit `1`; fetch failure → exit `1`; precondition failures → exit `1`.
5. **Windows-specific care.** `Test-Path` on a broken symlink returns `$false` — the removal cases must use `Get-Item -Force` (as `lib.ps1` itself does) when asserting a dangling link is gone. Assert path separators as produced by `Join-Path`, never hand-built strings, so the assertions do not encode a separator the code does not use.
6. **Any behavioural divergence found between the two implementations** — a message, an exit code, or a decision that differs from the canonical shell side — is recorded in the Implementation log and reported as a finding, not silently accommodated by a laxer assertion. Rule 24 makes the shell side canonical; a real divergence is a bug fixed in its own commit.

## Tests

This stage is test code and cannot be run locally (no PowerShell in the implementation environment).

- Local: BOM and LF verification per file; syntax check if any parser is reachable.
- CI (stage 7): the `windows-latest` job under both `pwsh` and `powershell.exe` is the acceptance evidence.

## Acceptance criteria

- [ ] Every stage 3 and stage 4 case has a counterpart, and each file states the mapping
- [ ] Divergences from the shell side are reported, not absorbed into weaker assertions
- [ ] Exit codes `0`, `1`, and `2` are each asserted at least once
- [ ] Files are UTF-8 with BOM and LF endings (rule 26)
- [ ] The full PowerShell suite passes under both hosts in the pull request's CI run

## Commit

Suggested message: `test(powershell): cover the remove, reinstall and update contract`

## Dependencies

- Requires stages: 3, 4, 5
- Parallel-safe with: none

## Implementation log

(Append-only.)
