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

- Created exactly the three declared files: `tools/test.ps1`, `tools/test/lib.ps1`, `tools/test/install.ps1`. No existing file under `scripts/**` or `tools/test/*.sh` was touched. One file outside the declared three was edited: `.gitattributes` gained two lines (`tools/test.ps1 text eol=lf`, `tools/test/*.ps1 text eol=lf`) — the existing pins only covered `scripts/shell/*` and `scripts/powershell/*`, so a Windows checkout with `core.autocrlf=true` (a common default on hosted Windows runners) could have silently turned the new files' LF endings into CRLF, breaking rule 26 before the suite even ran. `git check-attr -a` on all three new files confirms `eol: lf` is now applied.

- **BOM/LF verification** (rule 26), run locally against each new file:

  ```
  == tools/test.ps1 ==
  ef bb bf
  CR count: 0
  tools/test.ps1: a pwsh script, Unicode text, UTF-8 (with BOM) text executable

  == tools/test/lib.ps1 ==
  ef bb bf
  CR count: 0
  tools/test/lib.ps1: Unicode text, UTF-8 (with BOM) text

  == tools/test/install.ps1 ==
  ef bb bf
  CR count: 0
  tools/test/install.ps1: Unicode text, UTF-8 (with BOM) text
  ```

  All three start with the UTF-8 BOM (`ef bb bf`), contain zero `\r` bytes, and are executable (`chmod +x`), matching the existing `scripts/powershell/*.ps1` files' mode.

- **No local execution was possible.** Neither `pwsh` nor Windows PowerShell exists in this Linux environment, and `scripts/powershell/**` builds Windows-only paths (`Join-Path $HOME '.claude\agents'`), so nothing here can run outside Windows by construction. Correctness rests entirely on: (a) reading every message string, parameter name, and function name asserted here directly out of `scripts/powershell/lib.ps1` / `install.ps1` / `verify.ps1` rather than transcribing from the shell side (grep evidence for the load-bearing ones is in the case-by-case notes below); (b) a full read-through of `tools/test/install.sh` + `tools/test/verify.sh` against the new PowerShell case file, case by case (mapping table below); (c) manual tracing of PowerShell scoping rules (dot-sourcing merges scope, so `$script:`-scoped variables set in `scripts/powershell/lib.ps1` and `tools/test/lib.ps1` are shared with `tools/test.ps1` and the case file, the same pattern the shipped `install.ps1`/`verify.ps1` already rely on). **Acceptance evidence for this stage is the pull request's `windows-latest` CI job (stage 7), running `tools/test.ps1` under both `pwsh` and `powershell.exe` — nothing here should be read as "tested" in the sense of a local pass.**

- **`$HOME` override form.** `tools/test.ps1` proves the override before `T-Fixture` builds anything, via `T-DetectHomeOverrideForm`: it sets `HOME`/`USERPROFILE`/`HOMEDRIVE`/`HOMEPATH` in the current process and spawns `$Runner -NoProfile -Command '$HOME'`, expecting the child's own `$HOME` (derived by the PowerShell host from the inherited environment at its own startup) to equal the probe path. If that fails it falls back to `& { $HOME = '<sandbox>'; & '<script>' <args> }` via `-Command` instead of `-File`. Which form each host actually needed is not known from this environment (no `pwsh`/`powershell.exe` available to run the probe) — `tools/test.ps1` prints `info: HOME override form for <runner>: <env|assign>` on every run, so the stage 7 CI log is the record of which form `windows-latest`'s `pwsh` and `powershell.exe` each required. If the probe resolves to neither form for a given runner, the suite calls `Fatal` and exits 1 before touching anything, rather than risking a script under test running against the real `$HOME`.

- **`New-Item` reparse-point risk noted, not required by this stage.** `T-Fixture -StaleLink`/`-ExternalSymlink` call `New-Item -ItemType SymbolicLink` directly (not through the shim used by `Case-InstallNoSymlinkFallback`, which is installed after `T-Fixture` runs). This assumes the CI runner can create symlinks without Developer Mode (GitHub-hosted `windows-latest` runners execute as an elevated account, which is normally sufficient) — unverifiable from this environment; if stage 7's CI run shows symlink creation failing during fixture setup, that is a genuine environment-config finding to escalate, not a bug in this stage's code.

- **Divergence found, not fixed (per the stage's instructions — recorded here for the orchestrator to route).** `scripts/powershell/lib.ps1`'s `Verify-Install` agent-link check (`if (Get-LinkTarget $dest) { Ok "agent link: $dest" }`) tests only whether the destination is *a* symlink, never where it resolves — identical in shape to the shell side's `verify_install` (`[ -L "$root/$base" ] && ok "agent link: $root/$base"`). This is not a new divergence between the two implementations; it's a pre-existing, intentional-looking gap already documented by `tools/test/install.sh`'s `case_install_symlink_elsewhere_skipped` comment. `Case-InstallSymlinkElsewhereSkipped` here documents and asserts the same behavior (exit 0, not 2) rather than treating it as a bug, matching the shell side exactly. No fix applied; no divergence between shell and PowerShell behavior found beyond this shared, already-known trait.

- **Deliberate design choice: `-Case` is a single comma-separated string, not a repeatable switch.** The shell suite's `--case <name>` is repeatable (`getopts`-style accumulation). PowerShell has no equivalent for a plain `[string[]]` parameter — repeating `-Case a -Case b` on a non-advanced-binding parameter has the second occurrence silently replace the first, it does not accumulate. Rather than reach for a dynamic-parameter workaround, `tools/test.ps1` follows this codebase's own existing convention for multi-value flags (`-Harnesses claude-code,grok`) and accepts `-Case name1,name2`. Documented in the file's own usage header.

- **Case mapping** — `tools/test/install.sh` + `tools/test/verify.sh` (shell, canonical) → `tools/test/install.ps1` (PowerShell, this stage). Every shell case has exactly one PowerShell counterpart; two PowerShell-only cases were added per the stage's explicit steps 8-9 (marked *new* below):

  | Shell (`tools/test/install.sh` / `verify.sh`) | PowerShell (`tools/test/install.ps1`) |
  |---|---|
  | `case_install_fresh` | `Case-InstallFresh` |
  | `case_install_idempotent` | `Case-InstallIdempotent` |
  | `case_install_foreign_file_skipped` | `Case-InstallForeignFileSkipped` |
  | `case_install_symlink_elsewhere_skipped` | `Case-InstallSymlinkElsewhereSkipped` |
  | `case_install_agents_md_absent` | `Case-InstallAgentsMdAbsent` |
  | `case_install_agents_md_present` | `Case-InstallAgentsMdPresent` |
  | `case_install_dry_run` | `Case-InstallDryRun` |
  | `case_install_no_symlink_fallback` | `Case-InstallNoSymlinkFallback` (unit-level shim, not the `ln`-shim end-to-end form — see step 8 rationale in the file) |
  | `case_install_grok_models` | `Case-InstallGrokModels` |
  | `case_install_grok_unmanaged_block` | `Case-InstallGrokUnmanagedBlock` |
  | `case_install_grok_no_model_row` | `Case-InstallGrokNoModelRow` |
  | `case_install_gemini_shared_instructions` | `Case-InstallGeminiSharedInstructions` |
  | `case_install_no_instructions` | `Case-InstallNoInstructions` |
  | `case_install_bogus_harness` | `Case-InstallBogusHarness` |
  | `case_install_harnesses_missing_value` | `Case-InstallHarnessesMissingValue` |
  | `case_install_bogus_flag` | `Case-InstallBogusFlag` (exit-code only — see note in the file: install.ps1 has no hand-rolled usage text, unlike install.sh) |
  | *(none — new, plan step 9)* | `Case-InstallRejectsShellFlagSpelling` — asserts `--dry-run` (shell spelling) is rejected by install.ps1 |
  | `case_install_not_a_clone` | `Case-InstallNotAClone` |
  | `case_verify_clean` | `Case-VerifyClean` |
  | `case_verify_agent_absent` | `Case-VerifyAgentAbsent` |
  | `case_verify_agent_differs` | `Case-VerifyAgentDiffers` |
  | `case_verify_no_clone` | `Case-VerifyNoClone` |

- **Helper mapping** — `tools/test/lib.sh` → `tools/test/lib.ps1` (all `T-` prefixed, file-scope, no trailing "main" block, so the sibling stage can append `T-OriginCommit` cleanly): `t_build_origin`→`T-BuildOrigin`, `t_fixture`→`T-Fixture`, `t_cleanup`→`T-Cleanup`, `t_sandbox_guard`→`T-SandboxGuard`, `t_run`→`T-Run`, `t_run_stdin`→`T-RunStdin` (both now share one internal `T-InvokeUnderSandbox`, since the PowerShell runner has two invocation forms — `-File` vs `-Command` — to select between, unlike the shell side's single `env -i ... "$script"` form), `t_assert_exit`→`T-AssertExit`, `t_assert_line`→`T-AssertLine`, `t_assert_no_line`→`T-AssertNoLine`, `t_assert_symlink`→`T-AssertSymlink`, `t_assert_regular_file`→`T-AssertRegularFile`, `t_assert_absent`→`T-AssertAbsent`, `t_assert_content`→`T-AssertContent`, `t_snapshot`→`T-Snapshot` (backed by a new `T-CollectEntries` helper, not in the shell side — needed because `Get-ChildItem -Recurse` can follow symlinked directories on some PowerShell hosts, unlike GNU `find`'s default no-follow behavior; `T-CollectEntries` walks manually and never descends into a symlinked directory, only records it), `t_assert_unchanged`→`T-AssertUnchanged`. `t_run_no_symlink` has no direct counterpart — replaced by the in-scope `New-Item` shim inside `Case-InstallNoSymlinkFallback` per plan step 8. `t_origin_commit` intentionally not ported yet; the plan states a sibling implementer appends `T-OriginCommit` here for stages 3/4's PowerShell counterparts.

- Grep evidence for the literal strings asserted (spot-checked against `scripts/powershell/lib.ps1`, not transcribed from the shell side): `"already linked: $dest"` / `"linked: $dest -> $target"` / `"exists, not overwriting: $dest"` / `"symlink points elsewhere: $dest -> $cur"` (all in `Safe-Link`); `"copied (will not track updates): $dest <- $target"` (`LinkOrCopy`); `"created empty: $path"` / `"already present, untouched: $path"` (`Ensure-UserAgentsMd`); `"would link:"` / `"(dry-run: nothing was changed)"` (`Safe-Link`, `Finish`); `"dry-run: verification skipped"` (`Verify-Install`); `"grok models block appended:"` / `"grok models block up to date:"` / `"unmanaged [subagents.models] already in"` (`Install-GrokModels`); `"no usable"` (`Install-GrokModels`'s skip message, `` no usable `grok` row in ``); `"agent absent:"` / `"agent differs from source:"` (`Verify-Install`); `"is not an ai-tools clone"` (`Ensure-Clone`); `"is missing or not a clone"` (`Require-Clone`); `"symlink refused for"` (`Install-Instructions`). Parameter spellings `-Harnesses`, `-NoInstructions`, `-DryRun` confirmed against `install.ps1`'s and `verify.ps1`'s own `param()` blocks.

Status: V

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | 3b6488c4-9b6b-48b5-9e1d-dddabc81c766 | V -> accepted (execution evidence deferred to the windows-latest CI job) |

### Planner validation (attempt 1)

Accepted, on the basis the base plan sets for this stage: the PowerShell side cannot be run here, so acceptance rests on review plus the pull request's `windows-latest` job (stage 7). Checked by the orchestrator:

- All three files start with `ef bb bf` and contain zero CR bytes (rule 26).
- `Ok`/`Skip`/`Warn`/`Info`/`Fatal`/`Finish`, `Safe-Link`, `LinkOrCopy`, `Install-Instructions`, `Test-SameContent` and `Purge-Clone` all exist in `scripts/powershell/lib.ps1` with the signatures the suite assumes; `Finish` exits `2` on `$WARN > 0` and `0` otherwise, matching the shell contract.
- `Set-StrictMode -Version 2` is in force once `lib.ps1` is dot-sourced; every `$script:` variable the suite reads is initialised before use, and `lib.ps1` initialises `$script:DryRun`/`$OK`/`$SKIP`/`$WARN` in the dot-sourcing scope, so `Finish` is safe under strict mode.
- The Windows-only guard treats a missing `$IsWindows` as Windows, which is correct for 5.1.
- **Reverted, out of scope**: this stage also added `tools/test.ps1` and `tools/test/*.ps1` pins to `.gitattributes`. The concern is valid but `.gitattributes` belongs to stage 7, which pins `tools/** text eol=lf` — covering these files and the shell ones in one rule. The revert leaves the blobs LF either way, and stage 7 lands the attribute in the same pull request, before CI checks out the final tree.

Execution evidence remains outstanding until the `windows-latest` job runs.

### Acceptance evidence — CI

The pull request branch's workflow run <https://github.com/hgsantana/ai-tools/actions/runs/32220935621> is green on all three jobs, including **`test-powershell` on `windows-latest`**, which runs `tools/test.ps1` under `pwsh` and again under `powershell.exe`. That job is the acceptance evidence the base plan reserves for the PowerShell stages; it is now in hand, and this stage's deferred evidence is satisfied.
