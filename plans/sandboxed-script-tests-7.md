# Stage 7: CI wiring and linter coverage

## Objective

Run both suites in the workflow story 1 already ships — not a parallel one — and extend the existing repository checks so the new files are held to the same standards as everything else they sit next to.

## Files

- Modify → rename: `.github/workflows/lint.yml` → `.github/workflows/ci.yml` — the workflow now runs three jobs, so `name: lint` no longer describes it (use `git mv`; keep the existing `lint` job's steps byte-identical)
- Modify: `tools/lint.sh` — widen three existing checks to the new files
- Modify: `.gitattributes` — pin `tools/` line endings

## Steps

1. **Workflow.** In `ci.yml`, `name: ci`, same `on: [push, pull_request]` and `permissions: contents: read`. Three jobs:
   - `lint` (`ubuntu-latest`) — exactly today's steps: checkout with `fetch-depth: 0`, the rule linter with `--base` on pull requests only, then `shellcheck`. Only the `shellcheck` argument list changes (step 3).
   - `test-shell` (`ubuntu-latest`) — checkout, then `tools/test.sh`. `fetch-depth: 0` is required: the fixture builds a bare `origin` from the working tree and the suite commits inside the sandbox, so git must be fully functional; also configure nothing globally — the fixture supplies its own `.gitconfig`.
   - `test-powershell` (`windows-latest`) — checkout, then two steps: `pwsh -NoProfile -File tools/test.ps1` and `powershell -NoProfile -File tools/test.ps1`, so both hosts of rule 26 are exercised. Do not add a Linux pwsh run: the PowerShell scripts build Windows paths and assert nothing meaningful there (stage 5, step 2).
   - Jobs are independent; do not chain them with `needs`, so a shell failure still reports the PowerShell result.
2. **Exit-code handling.** The suites exit `2` on findings and `1` on a precondition; both must fail the job, which is the default for a non-zero exit. Do not add `continue-on-error` anywhere.
3. **`shellcheck` argument list.** Extend to the new sourced files: `shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh`. `tools/test/lib.sh` is sourced, never executed, so it carries a `# shellcheck shell=bash` header like `scripts/shell/lib.sh`. The repository is shellcheck-clean today and must stay so — a finding in a new file is fixed in that file, never silenced with a blanket disable; a targeted `# shellcheck disable=` needs a one-line reason comment, matching the existing style in `lib.sh`.
4. **`tools/lint.sh` — PowerShell BOM check.** `check_powershell_bom` iterates `scripts/powershell/*.ps1` only. Rule 26's reason (Windows PowerShell 5.1 reads a BOM-less file as ANSI and one em dash breaks the script) applies to any `.ps1` this repository asks 5.1 to run, which now includes `tools/test.ps1` and `tools/test/*.ps1`. Widen the loop to cover them.
5. **`tools/lint.sh` — executable bits.** `check_executable_bits` names `tools/lint.sh` explicitly; add `tools/test.sh` (the case files and `lib.sh` are sourced, not executed, and stay non-executable).
6. **`tools/lint.sh` — line endings.** `check_line_endings` reads `git ls-files --eol` for `scripts/*` only. Add `tools/` to the path list, and add `tools/** text eol=lf` to `.gitattributes` so the declared attribute exists for it to check. No CRLF path is involved — there are no `.cmd` files under `tools/`.
7. **Keep the linter's usage text in step with the code**: its `--help` output lists every check, so update the BOM, executable-bit, and line-ending entries to name their new scope. The README list is stage 8's job.
8. **First green run is the evidence.** Push the branch and record the run URL and per-job results in the Implementation log. A `windows-latest` failure here is a genuine finding from stages 5–6, not a CI-wiring defect: report it against that stage rather than weakening this one.

## Tests

- `tools/lint.sh` on the tree → exit `0`, with the new files reported by the widened checks (`ok:` lines naming `tools/test.sh`, `tools/test.ps1`, `tools/test/*.ps1`).
- `tools/test.sh` locally → exit `0`.
- Negative evidence for each widened check, in a throwaway copy of the tree only (never the working tree): strip the BOM from `tools/test.ps1` → `WARN`, exit `2`; clear the executable bit on `tools/test.sh` → `WARN`, exit `2`.
- Workflow syntax: the first push is the check; if a YAML linter is available locally, run it first.

## Acceptance criteria

- [ ] One workflow file, three jobs; the existing `lint` job's steps are unchanged apart from the `shellcheck` argument list
- [ ] Shell suite runs on `ubuntu-latest`; PowerShell suite runs on `windows-latest` under both `pwsh` and `powershell.exe`
- [ ] No second workflow file was created, and no job is `continue-on-error`
- [ ] `shellcheck` covers `tools/test/*.sh` and the repository stays shellcheck-clean
- [ ] `tools/lint.sh` checks BOM, executable bits, and line endings for the new files, and its `--help` says so
- [ ] All three jobs green on the branch, with the run recorded in the Implementation log

## Commit

Suggested message: `ci: run the script test suites on Linux and Windows`

## Dependencies

- Requires stages: 2, 3, 4, 6
- Parallel-safe with: none

## Implementation log

(Append-only.)

- Renamed `.github/workflows/lint.yml` → `.github/workflows/ci.yml` with `git mv`; `name: ci`; kept the existing `lint` job's steps byte-identical apart from the `shellcheck` argument list, which is now `shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh`. Added `test-shell` (`ubuntu-latest`, checkout `fetch-depth: 0` then `tools/test.sh`) and `test-powershell` (`windows-latest`, checkout `fetch-depth: 0` then `pwsh -NoProfile -File tools/test.ps1` and `powershell -NoProfile -File tools/test.ps1`). No `needs`, no `continue-on-error`.
- `shellcheck` is not installed in this sandbox, so step 3's command could not be run here. Verified instead that every path the new argument list globs exists (`scripts/shell/*.sh`, `tools/*.sh`, `tools/test/*.sh`) and that `tools/test/lib.sh` carries a `# shellcheck shell=bash` header (matching `scripts/shell/lib.sh`'s). CI's `lint` job is the actual execution evidence.
- Widened `tools/lint.sh`: `check_powershell_bom` now also globs `tools/test.ps1` and `tools/test/*.ps1`; `check_executable_bits` now also names `tools/test.sh`; `check_line_endings` now also reads `tools/` via `git ls-files --eol`. Updated the `--help` usage text for all three entries. Added `tools/** text eol=lf` to `.gitattributes`.
- `bash tools/lint.sh` on the working tree: `done: 531 ok, 1 skipped, 0 warnings`, exit `0`. New `ok:` lines confirmed for the widened checks, e.g.:
  - `ok: PowerShell BOM present: /home/wsl/.ai-tools/tools/test.ps1` (and `tools/test/{install,lib,remove,update}.ps1`)
  - `ok: line endings correct: tools/test.sh (lf)` / `tools/test.ps1 (lf)` / `tools/test/lib.ps1 (lf)` (and the other `tools/test/*` files)
  - `ok: executable bit set: /home/wsl/.ai-tools/tools/test.sh`
  - The lone `SKIP:` is the pre-existing version-bump check (needs `--base`, which only CI supplies) — unrelated to this stage.
- `bash tools/test.sh` locally: `done: 252 ok, 0 skipped, 0 warnings`, exit `0`.
- `git check-attr eol -- tools/test.sh tools/test.ps1 tools/test/lib.ps1 tools/test/install.sh` → all four report `eol: lf`.
- Negative evidence, performed only in a throwaway copy of the tree under `/tmp` (never the working tree), then deleted:
  - Stripped the BOM from `tools/test.ps1` (`ef bb bf` removed) → `bash tools/lint.sh` reported `WARN: PowerShell file missing BOM (ef bb bf): .../tools/test.ps1`, `done: 530 ok, 1 skipped, 1 warnings`, exit `2`.
  - Restored the BOM, then cleared the executable bit on `tools/test.sh` (`chmod -x` plus `git add` so the index mode actually changed to `100644`) → `bash tools/lint.sh` reported `WARN: executable bit missing (mode: 100644): .../tools/test.sh`, `done: 530 ok, 1 skipped, 1 warnings`, exit `2`.
- Workflow YAML syntax: no `yamllint`/`actionlint` available locally; `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))"` parsed cleanly (`YAML OK`). The first push and CI run remain the real syntax/behaviour check.
- **Not pushed** — pushing is reserved to the orchestrator, which holds the user's approval for it. The orchestrator must push this branch, capture the first green Actions run URL, and record per-job results (`lint`, `test-shell`, `test-powershell`) here before this stage's acceptance criterion "All three jobs green on the branch" can be checked off. A `windows-latest` failure in `test-powershell`, if it occurs, is a finding against stages 5–6 (the PowerShell suite itself), not a defect in this stage's CI wiring.
- Files touched: exactly the three declared — `.github/workflows/lint.yml` → `.github/workflows/ci.yml` (renamed + edited), `tools/lint.sh`, `.gitattributes`. Nothing else in the working tree was modified by this stage.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | 3b6488c4-9b6b-48b5-9e1d-dddabc81c766 | V -> accepted (CI run URL filled in by the orchestrator after the push) |

Status: V

## Correction round 1 (planner)

The branch was pushed and the workflow ran: <https://github.com/hgsantana/ai-tools/actions/runs/32220342141>.

| Job | Runner | Result |
|---|---|---|
| `test-shell` | `ubuntu-latest` | **success** |
| `test-powershell` | `windows-latest` (`pwsh` + `powershell.exe`) | **success** |
| `lint` | `ubuntu-latest` | **failure** — `shellcheck` step, exit 1 |

The wiring itself is correct; both suites pass on both platforms. The failure is this stage's acceptance criterion "`shellcheck` covers `tools/test/*.sh` and the repository stays shellcheck-clean", which the new files do not currently satisfy. `shellcheck` was unavailable when this stage was implemented; it is available now at `/tmp/shellcheck` (v0.10.0), so the findings can be reproduced and fixed locally.

Reproduce with exactly the CI command:

```
/tmp/shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh
```

Findings to clear, each in the file it occurs in:

1. `tools/test.sh` lines 34–38 — **SC2317** ("command appears to be unreachable") across `t_source_case_files`'s body, and **SC1090** ("can't follow non-constant source") on `. "$f"` at lines 37 and 63. Both are inherent to glob-based case discovery: the case files are found at run time, so their paths cannot be constant, and shellcheck's reachability analysis cannot see that the function is called.
2. `tools/test/install.sh` line 235 — **SC2016** on the single-quoted `sed` script `'/^| `grok`/d'`. The single quotes are deliberate: nothing in that expression should expand.
3. `tools/test/lib.sh` line 59 — **SC2153** ("`AI_TOOLS` may not be assigned. Did you mean `ai_tools`?"). `AI_TOOLS` is exported by `tools/test.sh` before this file is sourced; the local variable `ai_tools` in the runner helpers is what confuses the check.

Rules for the fix, from this stage's step 3:

- Fix each finding **in the file where it occurs** — do not silence anything from the workflow, and do not add a blanket `disable` at file level where a targeted one at the site will do.
- Every `# shellcheck disable=<code>` needs a **one-line reason comment** next to it, matching the existing style in `scripts/shell/lib.sh` — grep that file for its existing directives and follow it.
- Prefer an actual code fix over a directive where one exists and does not complicate the code (for example, a `# shellcheck source=/dev/null` directive is the idiomatic answer to SC1090).
- **Do not change any test's behaviour.** After the fix, `bash tools/test.sh` must still report `252 ok, 0 skipped, 0 warnings`, exit `0`.

Evidence to append: the full `shellcheck` command above exiting `0` with no output, and the `tools/test.sh` and `tools/lint.sh` runs.

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 2 | R1 | implementer | sonnet | agent addaa3f2e86942ee4 | V -> accepted (shellcheck exit 0, suite 252 ok, lint exit 0) |

### Correction round 1 — implementation

Fixes applied, one per finding:

1. `tools/test.sh` — the flagged `t_source_case_files` (lines 34–38) was a stale duplicate definition, entirely shadowed by the real one defined later in the file (formerly lines 56–75) before ever being called; its body was genuinely dead code. Removed it outright (real code fix), which also eliminates the SC1090 site at line 37 along with it. Added a targeted `# shellcheck source=/dev/null # case file path is discovered at run time, not constant` directive at the remaining SC1090 site (the `. "$f"` in the surviving `t_source_case_files`).
2. `tools/test/install.sh` line 235 — added `# shellcheck disable=SC2016 # single quotes are deliberate, nothing here should expand` directly above the `sed` call.
3. `tools/test/lib.sh` line 59 — added `# shellcheck disable=SC2153 # AI_TOOLS is exported by tools/test.sh, not a typo for the local ai_tools` directly above the `tar` pipeline.

No test behaviour, assertion, or message was changed.

Evidence — shellcheck (from repository root, exact CI command):

```
$ /tmp/shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh
$ echo $?
0
```
(no output)

Evidence — `bash tools/test.sh`:

```
...
done: 252 ok, 0 skipped, 0 warnings
$ echo $?
0
```

Evidence — `bash tools/lint.sh`:

```
...
SKIP: version bump check needs --base <ref> (the lint workflow supplies it)
done: 531 ok, 1 skipped, 0 warnings
$ echo $?
0
```

Status: V
