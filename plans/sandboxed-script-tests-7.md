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
