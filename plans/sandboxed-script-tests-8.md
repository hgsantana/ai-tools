# Stage 8: Documentation and version bump

## Objective

Document the suite where the README already documents development tooling, retire the roadmap story, and carry the single version bump for the whole branch (rule 4).

## Files

- Modify: `README.md` — extend *Development checks*, name the CI workflow by its new path, bump the version line
- Modify: `ROADMAP.md` — remove story 2 and its table row (a story leaves the file when it ships)

## Steps

1. **README, *Development checks*.** The section today describes `tools/lint.sh` and closes with the CI paragraph. Add the suite alongside it, in the same register and at the same length — extreme conciseness, rule 14:
   - What it is: `tools/test.sh` and `tools/test.ps1`, development checks and not installation processes (outside rules 23–25), which run the five scripts against a disposable fake `HOME` and assert the installation and script contract (rules 17–25).
   - How to run them, in the same two-line code block style already used for the linter, including `--case <name>` and `--keep` / `-Runner`.
   - What the fixture stages: a pre-populated harness layout for all seven harnesses, a local `origin` so no run reaches the network, a foreign file on a destination, a locally modified copy, an unmanaged Grok block, a stale link from an older layout.
   - What is asserted, as a short list keyed to the rules: symlink first with copy fallback (17), never overwrite a user file (18), never remove what ai-tools did not create (19), idempotency and skip-and-report (20), `$HOME/AGENTS.md` untouched (22), destructive flags defaulting to refuse and `--dry-run` changing nothing (25), exit codes `0`/`1`/`2` (25).
   - **The two exclusions, stated plainly**: `scripts/cmd` is not covered — the shims only delegate to PowerShell and carry no contract of their own; and the PowerShell suite runs on Windows only, because those scripts build Windows paths by construction. Both are deliberate, in the same spirit as the linter's documented absence of a PowerShell mirror.
   - Exit codes: `0` clean, `1` aborted on a precondition, `2` finished with failures — the same contract as everything else here.
2. **CI paragraph.** Update the existing sentence that names `.github/workflows/lint.yml` to the renamed `.github/workflows/ci.yml`, and say what its three jobs run and on which runners. Check for any other reference to the old path elsewhere in the README (search `lint.yml`).
3. **Linter check list.** The bullet list in *Development checks* names the linter's check families; update the encodings/endings and size-cap bullets to reflect the widened scope from stage 7 (BOM, executable bits, and line endings now cover `tools/` as well).
4. **`ROADMAP.md`.** Delete the `### 2. Sandboxed script test suite` entry and its row in the status table. If the *Quality net* heading is left with no story under it, remove the heading too. Do not renumber the remaining stories — the numbers are identifiers, and the file's own preamble says the order is a suggestion, not a commitment.
5. **Version bump.** Bump the `> **Version 0.0.23-ALPHA**` line at the top of `README.md` — once, in this stage, for the whole branch. `tools/` is not shipped content under the linter's version-bump rule (it diffs `agents`, `skills`, `scripts`, `USER-AGENTS.md`), so this bump is required by rule 4's "any change to shipped content or process" rather than by the linter; make it anyway, and note in the Implementation log that the linter's check would not have demanded it.
6. **No behaviour change here.** This stage edits documentation only. If it turns out that a README statement no longer matches the code, fix the README — the code was validated by stages 2–7.

## Tests

- `tools/lint.sh --base <branch base>` → exit `0`, including the version-bump check.
- `tools/test.sh` → exit `0` (unchanged by this stage).
- Re-read the two edited sections end to end: no rule number cited that does not exist, no path cited that does not exist, no duplicate statement of something the rules already say.

## Acceptance criteria

- [ ] *Development checks* documents both suites, how to run them, what the fixture stages, and what is asserted
- [ ] The `scripts/cmd` exclusion and the Windows-only PowerShell run are stated explicitly
- [ ] Every reference to `.github/workflows/lint.yml` is updated to `ci.yml`
- [ ] Story 2 is gone from `ROADMAP.md`, table row included
- [ ] The README version line is bumped exactly once on the branch
- [ ] `tools/lint.sh --base <base>` exits `0`

## Commit

Suggested message: `docs: document the script test suites and bump the version`

## Dependencies

- Requires stages: 1, 2, 3, 4, 5, 6, 7
- Parallel-safe with: none

## Implementation log

(Append-only.)
