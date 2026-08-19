# Stage 5: PowerShell harness and install cases

## Objective

Mirror stage 1 and stage 2 on the PowerShell side: a sandbox harness (`tools/test.ps1`, `tools/test/lib.ps1`) plus the install and verify cases, running under both `pwsh` 7 and Windows PowerShell 5.1 on Windows.

## Files

- Create: `tools/test.ps1` — suite entry point; UTF-8 **with BOM** (rule 26), LF endings
- Create: `tools/test/lib.ps1` — fixture builder, sandbox runner, assertions; UTF-8 with BOM, LF
- Create: `tools/test/install.ps1` — install and verify cases; UTF-8 with BOM, LF

## Steps

1. **Standing.** `tools/test.ps1` mirrors `tools/test.sh`, which stays canonical (rule 24): the case list, the fixture shape, and the assertion vocabulary follow it. Dot-source `scripts/powershell/lib.ps1` with `$env:AI_TOOLS` set to the repository root, and report only through `Ok`/`Skip`/`Warn`/`Info`/`Fatal` and `Finish`, inheriting `0` / `1` / `2`. Helper names are `T-` prefixed (`T-Fixture`, `T-Run`, `T-AssertExit`, …) so nothing shadows `lib.ps1`.
2. **Windows only.** The PowerShell scripts build paths as `Join-Path $HOME '.claude\agents'`, which yields one literal file name on a non-Windows host. `tools/test.ps1` therefore aborts with exit `1` and a clear message when `$IsWindows` is false (5.1 has no `$IsWindows`; treat its absence as Windows). Record this in the file header — it is why stage 7 schedules the job on `windows-latest` only.
3. **`$HOME` control — verify before building anything.** `T-Fixture` sets `USERPROFILE`, `HOMEDRIVE`, `HOMEPATH`, and `HOME` for the child process and then *proves* the override took: run `pwsh -NoProfile -Command '$HOME'` (and the same under `powershell.exe`) with those variables set and assert the output is the sandbox path. If it is not, fall back to invoking the script under test as `pwsh -NoProfile -Command "& { $HOME = '<sandbox>'; & '<script>' <args> }"` instead of `-File`, and record which form was needed. Never proceed with a `$HOME` that resolves outside the sandbox: that is a `Fatal`, exit `1`, before any script runs — same guard as stage 1, same reason.
4. **`T-Fixture`** mirrors `t_fixture` exactly: a temp root under `$env:TEMP`; a fake `HOME` with all seven harness config directories pre-created; a bare `origin.git` built from the working tree (exclude `.git` and `plans/`) with one commit on `master`; `home\.ai-tools` cloned from it; a `.gitconfig` in the fake home carrying `user.name`/`user.email` and the `insteadOf` rewrite from the public URL to the local bare repo. Same opt-in conflicts: foreign file on a destination, locally modified copy, unmanaged `[subagents.models]`, stale link, symlink pointing elsewhere.
5. **`T-Run`** invokes `& $Runner -NoProfile -File <script> <args>` with the sandbox environment, captures combined output and `$LASTEXITCODE`. `$Runner` comes from a `-Runner` parameter on `tools/test.ps1` (default: the current host) so the same suite runs under `pwsh` and `powershell.exe`. `T-RunStdin` feeds a string for `Purge-Clone`'s `Read-Host`.
6. **Assertions**: `T-AssertExit`, `T-AssertLine` / `T-AssertNoLine` (literal match), `T-AssertSymlink`, `T-AssertRegularFile`, `T-AssertAbsent`, `T-AssertContent`, `T-Snapshot` / `T-AssertUnchanged` (relative path list plus `Get-FileHash`). Reuse `Test-SameContent` from `lib.ps1` where it fits rather than reimplementing a comparison.
7. **Install and verify cases** (`tools/test/install.ps1`) — one function per case in `tools/test/install.sh` and `tools/test/verify.sh`, same names modulo casing, so the mapping is reviewable: fresh install links; idempotent re-run; foreign file skipped and byte-identical; symlink pointing elsewhere skipped; `$HOME\AGENTS.md` created only when missing and never edited; `-DryRun` changes nothing; Grok block written, refreshed, and skipped when unmanaged or when `MODELS.md` has no `grok` row; shared `GEMINI.md` for `gemini,antigravity`; `-NoInstructions`; unknown harness / missing value / unknown flag exit `1`; `verify.ps1` clean, absent-agent, differing-agent, and no-clone cases, mutating nothing.
8. **Symlink-to-copy fallback is a unit case**, not an end-to-end one. Hosted Windows runners can usually create symlinks, so instead: dot-source `scripts/powershell/lib.ps1` into the test session, define a `New-Item` function that throws when `-ItemType SymbolicLink` is requested and otherwise forwards to `Microsoft.PowerShell.Management\New-Item`, then call `LinkOrCopy` directly and assert `ok: copied (will not track updates):` and a regular file at the destination. Restore by removing the function afterwards. Document in the case file why this differs from the shell side's `ln` shim, and assert `Install-Instructions` warns rather than copies when `Safe-Link` returns `2`.
9. **Parameter-name mapping.** Cases use the PowerShell spellings (`-Harnesses`, `-NoInstructions`, `-DryRun`, `-DiscardLocal`, `-NoReset`, `-Instructions`, `-NoSweep`, `-Purge`, `-Yes`). Assert at least once that a shell flag spelling (`--dry-run`) is rejected, so the two CLIs are not silently interchangeable.

## Tests

This stage is test code, and it cannot be run in the planning or implementation environment (no PowerShell available).

- Local: syntax-check every new file if any PowerShell parser is reachable; otherwise confirm BOM (`od -An -tx1 -N3` → `ef bb bf`) and LF endings, and record that execution evidence comes from CI.
- CI (stage 7): the `windows-latest` job runs `tools/test.ps1` under `pwsh` and under `powershell.exe`; the pull request run is the acceptance evidence for this stage.
- Record in the Implementation log which `$HOME` override form each host required (step 3).

## Acceptance criteria

- [ ] `tools/test.ps1` exists, aborts with exit `1` on a non-Windows host, and discovers cases by glob
- [ ] Every case in stage 2 has a named counterpart here, and the case file lists the mapping
- [ ] The sandbox guard proves `$HOME` resolves inside the fixture before any script runs
- [ ] The copy fallback is covered at unit level, with its rationale in the file
- [ ] Files are UTF-8 with BOM and LF endings (rule 26)
- [ ] The suite passes under both `pwsh` and Windows PowerShell 5.1 in the pull request's CI run

## Commit

Suggested message: `test(powershell): add the sandbox harness and install cases`

## Dependencies

- Requires stages: 1, 2
- Parallel-safe with: 3, 4

## Implementation log

(Append-only.)
