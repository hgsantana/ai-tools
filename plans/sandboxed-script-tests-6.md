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

### Attempt 1 (implementer/sonnet)

**Edits made** (exactly the three declared in this stage's Files list, all under `tools/test/`):
- Created `tools/test/remove.ps1` (14 remove cases + 7 reinstall cases, 21 `Case-*` functions)
- Created `tools/test/update.ps1` (13 `Case-*` functions)
- Appended `T-OriginCommit` to `tools/test/lib.ps1` (append-only; every pre-existing line verified untouched — diff shows only an addition at end of file)

`tools/test.ps1`, `scripts/**`, `.github/**`, `README.md`, `ROADMAP.md`, and `.gitattributes` were not opened for writing, per the stage's scope.

**Case-file mapping tables** (also stated in each file's own header comment):

`remove.sh` → `remove.ps1` (14/14 mapped, none dropped):
| shell case | PowerShell case |
|---|---|
| `case_remove_unlinks_what_install_linked` | `Case-RemoveUnlinksWhatInstallLinked` |
| `case_remove_idempotent` | `Case-RemoveIdempotent` |
| `case_remove_modified_copy_kept` | `Case-RemoveModifiedCopyKept` |
| `case_remove_foreign_file_kept` | `Case-RemoveForeignFileKept` |
| `case_remove_external_symlink_kept` | `Case-RemoveExternalSymlinkKept` |
| `case_remove_agents_md_untouched` | `Case-RemoveAgentsMdUntouched` |
| `case_remove_instructions_gate` | `Case-RemoveInstructionsGate` |
| `case_remove_gemini_antigravity_shared_instructions` | `Case-RemoveGeminiAntigravitySharedInstructions` |
| `case_remove_grok_block` | `Case-RemoveGrokBlock` |
| `case_remove_stale_link_sweep` | `Case-RemoveStaleLinkSweep` |
| `case_remove_purge_refuses_without_confirmation` | `Case-RemovePurgeRefusesWithoutConfirmation` |
| `case_remove_dry_run_changes_nothing` | `Case-RemoveDryRunChangesNothing` |
| `case_remove_without_a_clone` | `Case-RemoveWithoutAClone` |
| `case_remove_precondition_failures` | `Case-RemovePreconditionFailures` |

`reinstall.sh` → `remove.ps1` (7/7 mapped, none dropped):
| shell case | PowerShell case |
|---|---|
| `case_reinstall_clean_matches_fresh_install` | `Case-ReinstallCleanMatchesFreshInstall` |
| `case_reinstall_stale_link_removed` | `Case-ReinstallStaleLinkRemoved` |
| `case_reinstall_modified_copy_kept` | `Case-ReinstallModifiedCopyKept` |
| `case_reinstall_fresh_clone_offline` | `Case-ReinstallFreshCloneOffline` |
| `case_reinstall_uncommitted_no_discard` | `Case-ReinstallUncommittedNoDiscard` |
| `case_reinstall_no_instructions` | `Case-ReinstallNoInstructions` |
| `case_reinstall_dry_run_changes_nothing` | `Case-ReinstallDryRunChangesNothing` |

`update.sh` → `update.ps1` (13/13 mapped, none dropped):
| shell case | PowerShell case |
|---|---|
| `case_update_reset_guard_dirty` | `Case-UpdateResetGuardDirty` |
| `case_update_reset_guard_ahead` | `Case-UpdateResetGuardAhead` |
| `case_update_discard_local` | `Case-UpdateDiscardLocal` |
| `case_update_reset_confined` | `Case-UpdateResetConfined` |
| `case_update_new_content_linked` | `Case-UpdateNewContentLinked` |
| `case_update_stale_copy_refreshed` | `Case-UpdateStaleCopyRefreshed` |
| `case_update_modified_copy_kept` | `Case-UpdateModifiedCopyKept` |
| `case_update_up_to_date_copy` | `Case-UpdateUpToDateCopy` |
| `case_update_no_reset` | `Case-UpdateNoReset` |
| `case_update_dry_run` | `Case-UpdateDryRun` |
| `case_update_missing_clone` | `Case-UpdateMissingClone` |
| `case_update_fetch_failure` | `Case-UpdateFetchFailure` |
| `case_update_preconditions` | `Case-UpdatePreconditions` |

No shell case was dropped; every one has a counterpart with matching intent, verified against `scripts/powershell/*.ps1` message strings and control flow (not transcribed from the shell side).

**Test-harness adaptation, not a behavioural divergence — the missing `T-RunNoSymlink`:** `tools/test/lib.sh` gives the shell suite `t_run_no_symlink` (a PATH-shimmed `ln` that always fails), used to force `install.sh` to install everything as copies so copy-preservation code paths get exercised. `tools/test/lib.ps1` has no equivalent, and this stage's Files list allows appending only `T-OriginCommit` to it — no new runner helper was in scope to add. Windows also has no PATH-shimmable equivalent for `New-Item -ItemType SymbolicLink` (it's a cmdlet, not an external command), and a same-process function shadow (the technique `tools/test/install.ps1`'s `Case-InstallNoSymlinkFallback` uses) cannot cross into a spawned child process the way `T-Run` spawns one.
- For `Case-RemoveModifiedCopyKept` / `Case-ReinstallModifiedCopyKept`: no workaround was needed. `T-Fixture -ModifiedCopy` (already shipped) stages the destination file directly *before* install ever runs, so `Safe-Link` finds it occupied and skips it regardless of whether symlinks succeed elsewhere in the run.
- For `Case-UpdateStaleCopyRefreshed` and `Case-UpdateUpToDateCopy`: the destination under test is pre-staged with a plain `Copy-Item` copy before `install.ps1` runs normally (installing every other wrapper as a real symlink). `Safe-Link` finds that one destination occupied and leaves it exactly as staged. The net effect on the destination is identical to the shell fixture's (a plain copy, never a link) — what differs is that this setup never forces the *unrelated* instructions symlink to fail, so `Refresh-Copies`/`Verify-Install` reach exit `0` for these two cases in the PowerShell suite where the shell suite (via its system-wide `ln` shim) incidentally reaches exit `2` for an unrelated reason (documented in `tools/test/update.sh`'s own header). I traced this by reading `Refresh-Copies`, `Install-Agents`, and `Verify-Install` in `scripts/powershell/lib.ps1` end to end for each case's exact file states; both exit codes (`0` for stale-copy-refreshed / up-to-date, `2` for modified-copy-kept, the last one matching the shell side because a real `Verify-Install` warning is present there regardless of the shim) are documented inline in `update.ps1` with the reasoning, per this stage's step 6 instruction to assert the observed, contract-consistent code rather than copy the shell number blindly.
- No divergence in `scripts/powershell/*.ps1` behaviour itself was found — this is purely a test-fixture-construction difference, called out here because the plan asked for it to be recorded rather than silently absorbed.

**`--external-symlink` / `-ExternalSymlink` collision (mirrors `remove.sh`'s own header note):** `tools/test/lib.ps1`'s `T-Fixture -ExternalSymlink` stages its target under the sandbox root, whose name (`ai-tools-test.<hex>`) itself contains the substring `ai-tools`. `Test-AiToolsTarget`'s first, coarse check (`$target -like '*ai-tools*'`) would misidentify that fixture's own external file as an ai-tools destination. `Case-RemoveExternalSymlinkKept` therefore stages its own external symlink by hand (`$env:TEMP\t-remove-external-<guid>`, a path outside the sandbox naming scheme), exactly mirroring `remove.sh`'s documented workaround for the same collision — this is a fixture-naming collision, not a `scripts/powershell` defect, and `tools/test/lib.ps1` is out of scope for this stage beyond the one sanctioned append.

**Windows-specific care (step 5):** `T-AssertAbsent` in `tools/test/lib.ps1` (stage 5, unmodified) already uses `Get-Item -Force -ErrorAction SilentlyContinue` rather than `Test-Path`, so it correctly reports a broken symlink as present-but-dangling rather than silently treating it as absent; every stale-link-removal assertion in the new files (`Case-RemoveStaleLinkSweep`, `Case-ReinstallStaleLinkRemoved`) relies on this existing helper rather than a hand-rolled `Test-Path` check. Every destination path built in both new files uses `Join-Path`; no hand-written backslash-joined path literal was written (verified by grep — see below).

**BOM/LF verification** (`od -An -tx1 -N3` for the first three bytes; `grep -c $'\r'` for embedded CR bytes; expected `ef bb bf` and `0` respectively):
```
=== tools/test/remove.ps1 ===
first 3 bytes:  ef bb bf
CR count: 0
=== tools/test/update.ps1 ===
first 3 bytes:  ef bb bf
CR count: 0
=== tools/test/lib.ps1 ===
first 3 bytes:  ef bb bf
CR count: 0
```
`remove.ps1` and `update.ps1` did not get a BOM from the file-write tool by default; it was added as a explicit post-write byte-prepend step and reverified. `lib.ps1`'s pre-existing BOM was left untouched by the append (confirmed: the edit only appended bytes at EOF, no bytes before the appended block were touched).

**Local verification performed — and its real boundary:** No `pwsh` is installed in this Linux environment, confirming the stage's premise that the actual `windows-latest` CI job (stage 7) is the only place these scripts can genuinely execute end to end against a real `$HOME`. However, Windows PowerShell 5.1 (`powershell.exe`, build 26100) turned out to be reachable through WSL's `/mnt/c` interop path, which allowed two additional real, honest verification steps beyond BOM/LF and reading:
1. `[System.Management.Automation.Language.Parser]::ParseFile` against all three files: zero syntax errors in any of them.
2. Dot-sourcing `scripts/powershell/lib.ps1`, `tools/test/lib.ps1`, `tools/test/install.ps1`, `tools/test/remove.ps1`, and `tools/test/update.ps1` together, in the same order `tools/test.ps1` uses (alphabetical), completed with no definition-time errors, and yielded exactly the expected function counts: install.ps1 22, remove.ps1 +21 (14 remove + 7 reinstall), update.ps1 +13 (36 new here), `T-OriginCommit` present — no name typo, no accidental duplicate/shadowed case function.

This is genuine, but it is **not** a functional run: `Get-Command git` returned nothing on that Windows PowerShell's `PATH`, so `T-BuildOrigin`/`T-Fixture` cannot execute there (they require `git`), and no script under test, no fixture, and no assertion was actually invoked or evaluated. No case ran, no assertion (`Ok`/`Warn`) fired, no exit code was observed for any case in this file. I did not execute the suite, and I am not claiming to have. Every exit code and message string asserted above was derived by reading `scripts/powershell/lib.ps1`, `remove.ps1`, `reinstall.ps1`, and `update.ps1` line by line, cross-referenced against the exact strings those files emit (never transcribed from the shell side) — the same standard the stage brief set. Full execution evidence for this stage remains the pull request's `windows-latest` CI job under stage 7.

Status: V

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | 3b6488c4-9b6b-48b5-9e1d-dddabc81c766 | V -> accepted (5.1 parse clean; execution evidence deferred to the windows-latest CI job) |

### Planner validation (attempt 1)

Accepted on the basis the base plan sets for the PowerShell stages: no local execution is possible, so acceptance rests on review plus the pull request's `windows-latest` job (stage 7). Checked independently by the orchestrator:

- `tools/test/remove.ps1`, `tools/test/update.ps1` and `tools/test/lib.ps1` all start with `ef bb bf` and contain zero CR bytes (rule 26).
- The `lib.ps1` edit is a pure append: `git diff` reports 47 insertions and 0 deletions.
- Independent syntax parse under **Windows PowerShell 5.1 (5.1.26100.9168)**, reached through WSL interop, using `[System.Management.Automation.Language.Parser]::ParseFile` over `tools/test.ps1`, `tools/test/lib.ps1`, `tools/test/install.ps1`, `tools/test/remove.ps1`, `tools/test/update.ps1` and `scripts/powershell/lib.ps1` — **zero parse errors in all six**. This is a parse, not a run: git is not on that host's PATH, so no fixture was built and no script under test was executed.
- Case counts: 21 `Case-*` in `remove.ps1` (14 remove + 7 reinstall, matching `remove.sh` and `reinstall.sh`) and 13 in `update.ps1` (matching `update.sh`).
- The absence of a `T-RunNoSymlink` counterpart is a harness gap, not a divergence in `scripts/powershell/**`: the stage stages copy-shaped destinations directly instead, and the symlink-to-copy fallback itself is covered at unit level by stage 5's `Case-InstallNoSymlinkFallback`, which is what this plan specified for the PowerShell side. Recorded as-is.

Execution evidence remains outstanding until the `windows-latest` job runs.

### Acceptance evidence — CI

The pull request branch's workflow run <https://github.com/hgsantana/ai-tools/actions/runs/32220935621> is green on all three jobs, including **`test-powershell` on `windows-latest`**, which runs `tools/test.ps1` under `pwsh` and again under `powershell.exe`. That job is the acceptance evidence the base plan reserves for the PowerShell stages; it is now in hand, and this stage's deferred evidence is satisfied.
