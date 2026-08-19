# Sandboxed script test suite

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |
| 8 | | |

## Goal

Prove the installation and script contract (rules 17–25) mechanically instead of by running the scripts against a real `$HOME`: a test suite that builds a disposable fake `HOME` — pre-populated harness layout, a local `origin` git remote, a foreign file on a destination path, and a locally modified copy — runs `install`, `remove`, `update`, `reinstall`, and `verify` against it, and asserts idempotency, skip-and-report, never-overwrite, symlink-to-copy fallback, destructive-flag refusal, and exit codes `0`/`1`/`2`. Shipped for both `scripts/shell` and `scripts/powershell`, wired into the story-1 workflow.

## Execution graph

1 before 2, 3, 4, and 5.
2, 3, and 4 are parallel-safe with each other (each adds its own case file; case discovery is by glob, so no shared file is edited).
5 after 1 and 2. 6 after 3, 4, and 5.
7 after 2, 3, 4, and 6. 8 after every other stage.

## Stages

1. [Sandbox harness and assertions (shell)](./sandboxed-script-tests-1.md) — `tools/test.sh` plus `tools/test/lib.sh`: fixture builder, sandboxed runner, assertions, case discovery, exit contract
2. [Install and verify contract (shell)](./sandboxed-script-tests-2.md) — rules 17–22 and 25 on `install.sh` and `verify.sh`
3. [Remove and reinstall contract (shell)](./sandboxed-script-tests-3.md) — unlink, keep user work, destructive flags, sweep, `reinstall.sh`
4. [Update contract (shell)](./sandboxed-script-tests-4.md) — reset guard, `--discard-local`, copy refresh versus locally modified copy
5. [PowerShell harness and install cases](./sandboxed-script-tests-5.md) — `tools/test.ps1`, `tools/test/lib.ps1`, mirror of stage 2
6. [PowerShell remove, reinstall, and update cases](./sandboxed-script-tests-6.md) — mirror of stages 3 and 4
7. [CI wiring and linter coverage](./sandboxed-script-tests-7.md) — jobs in the story-1 workflow, `shellcheck` and `tools/lint.sh` globs, `.gitattributes`
8. [Documentation and version bump](./sandboxed-script-tests-8.md) — README, ROADMAP entry removal, one version bump

## Notes

**Settled before planning (do not revisit)**

- **`scripts/cmd` is out of scope.** The CMD shims only delegate to PowerShell (rule 23); the delegation adds no contract of its own, and testing it needs a Windows CMD host driving a second process layer for zero additional coverage. The suite asserts nothing about `scripts/cmd/*.cmd`, and stage 8 states that exclusion in the README so the gap is deliberate and visible.
- **Delivery**: dedicated branch, one Conventional Commit per stage, one pull request. Stage 8 carries the single version bump for the whole branch — an earlier bump would let the linter's own version-bump check pass for the wrong reason (the same reasoning story 1 used).

**Test stack: hand-rolled runners in the repository's existing shape, not bats + Pester.**

Chosen: `tools/test.sh` and `tools/test.ps1`, each sourcing the matching `scripts/*/lib.*` for `ok`/`skip`/`warn`/`fatal`/`finish` and inheriting the `0`/`1`/`2` exit contract already specified by rule 25, exactly as `tools/lint.sh` does.

- *Why not bats*: it is not present on GitHub's `ubuntu-latest` image, so it means an `apt-get`, an npm install, or a vendored submodule in a repository whose entire tooling philosophy is "no dependency beyond `git`, `grep`, `awk`, `sed`, `wc`, `od`, `tr`" — and it would not be installed on a contributor's machine either, so the local and CI runs would diverge. What bats buys (TAP output, `setup`/`teardown`, tag filtering, parallelism) is worth little here: the cases are end-to-end process runs asserting a handful of stdout lines, an exit code, and filesystem state.
- *Why not Pester*: version roulette. Windows PowerShell 5.1 ships Pester 3.4 while the hosted images carry Pester 5, and the two are mutually incompatible in syntax; pinning a module install is more moving parts than the assertions justify. Running the suite under both 5.1 and pwsh — which is the point of testing the PowerShell side at all (rule 26 exists because 5.1 differs) — is simpler with plain scripts.
- *Cost accepted*: no ecosystem tooling, no test-report format, assertions written by hand. Roughly 60 lines of helpers per language. If the suite ever outgrows that, bats + Pester is the escape hatch and nothing in the case files blocks it.
- *Duplication*: shell and PowerShell each build their own fixture. This mirrors rule 24's existing arrangement (`lib.sh` canonical, `lib.ps1` mirrors) rather than inventing a shared fixture format, and stages 5–6 carry a per-case mapping so drift is reviewable.

**Sandbox safety is the suite's own first requirement.** These scripts delete links, rewrite `~/.grok/config.toml`, and `rm -rf` a clone under `--purge`. Every child run gets `HOME`, `USERPROFILE`, and `AI_TOOLS` inside a disposable directory, and the runner aborts with exit `1` — before any script executes — if either path is not under the sandbox root. A `HOME` that escaped the sandbox is a suite bug that would eat the maintainer's real installation.

**No network.** The fixture writes a `.gitconfig` into the fake `HOME` with an `insteadOf` rewrite from `https://github.com/hgsantana/ai-tools.git` to a local bare repository, plus `GIT_TERMINAL_PROMPT=0`. `ensure_clone`, `update_source`, and the fresh-clone path in `reinstall` therefore run for real, offline.

**The PowerShell side cannot be validated locally.** Neither `pwsh` nor Windows PowerShell exists in the planning environment, and the PowerShell scripts are Windows-only by construction (`Join-Path $HOME '.claude\agents'` produces one literal file name on Linux, so a Linux pwsh run would assert nothing). Stages 5 and 6 are validated from the pull request's `windows-latest` job, not from local evidence; their Implementation logs record the CI run, and the orchestrator accepts them on that basis.

**Symlink-to-copy fallback is provoked differently per platform.** Shell: a `PATH` shim whose `ln` always fails, which drives `safe_link` to return `2` and `link_or_copy` to copy — an honest end-to-end run. PowerShell: the hosted Windows runner usually *can* create symlinks, so the fallback is asserted at unit level by dot-sourcing `lib.ps1` and shadowing `New-Item` with a function that throws for `-ItemType SymbolicLink` (function lookup beats cmdlet lookup, which is what Pester's `Mock` does under the hood). The asymmetry is deliberate and documented in the case file.

**Workflow rename.** `.github/workflows/lint.yml` gains two jobs and is renamed to `ci.yml` (`name: ci`), since "lint" would no longer describe it; the existing `lint` job's steps are unchanged. This is reversible — keeping the file at `lint.yml` costs nothing else in the plan — but it changes the check name GitHub reports, so a branch protection rule pinned to `lint` would need updating. Rule 4 waives backward compatibility in alpha.

**Out of scope**: `scripts/cmd` (above); harness *discovery* against real installations (`has_extension`, `command -v`) beyond what a fake `HOME` can stage; testing `tools/lint.sh` itself; performance; markdown or PowerShell static analysis. Also out: touching `scripts/shell` or `scripts/powershell` behaviour — if a case exposes a genuine contract violation, the stage records it and the fix lands as its own commit rather than being folded into a test stage.
