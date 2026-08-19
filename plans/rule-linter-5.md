# Stage 5: Version bump check

## Objective

Catch the rule that has no other witness: shipped content changed, but the version at the top of the README did not (rule 4).

## Files

- Modify: `tools/lint.sh` — add `--base <ref>` and the bump check

## Steps

1. Add `--base <ref>` (no default). Without it the check is **skipped**, reported through `skip` — a local run against a dirty tree has no meaningful base, and a skipped check must never fail the run.
2. With it: `git diff --name-only <ref>...HEAD`. If any path under `agents/`, `skills/`, `scripts/`, or `USER-AGENTS.md` changed, then the version line in `README.md` must differ between `<ref>` and `HEAD`.
3. Read the version with a single anchored pattern from the README's first lines, and report the value found. `ROADMAP.md`, `plans/`, `.github/`, `tools/`, and `MODELS.md` are **not** shipped content for this check — `MODELS.md` is explicitly user-editable and reset by an update.
4. Fail with a message naming which shipped paths changed, so the fix is obvious without re-running `git diff` by hand.
5. Document in `--help` that this check is the CI's, and that it needs a base ref.

## Tests

Evidence in the Implementation log, from a throwaway clone: a commit touching only `README.md` prose passes; a commit touching `agents/` without a version change fails with exit `2`; a commit touching both passes; a run without `--base` reports the check as skipped and does not fail.

## Acceptance criteria

- [x] Without `--base`, the check is skipped and the run can still exit `0`
- [x] With `--base`, a shipped-content change without a version bump exits `2` and names the paths
- [x] `MODELS.md`, `ROADMAP.md`, `plans/`, `tools/`, and `.github/` do not by themselves require a bump
- [x] The version is read from the README, never from a second copy of the string

## Commit

Suggested message: `chore(tools): require a version bump when shipped content changes`

## Dependencies

- Requires stages: 4
- Parallel-safe with: none

## Implementation log

Added `--base <ref>` to the flag loop and a `check_version_bump` function (with
`readme_version`, reading the version from README.md's leading
`> **Version X**` line via `git show <ref>:README.md`). Wired it into the Run
section as the last check, and documented it in `--help`. Tested against a
throwaway clone of `/home/wsl/.ai-tools` (built under the scratchpad, base
commit `16dfcebd46bca09acf0bb2d3d4665be73f3e672f`, with `tools/lint.sh`
copied in from this branch); all commits and test runs were made only in
that clone, never in this repository.

1. Commit touching only `README.md` prose (adding a comment line), run
   `tools/lint.sh --base 16dfcebd46bca09acf0bb2d3d4665be73f3e672f`:
   `ok: no shipped content changed since 16dfcebd46bca09acf0bb2d3d4665be73f3e672f: version bump not required`,
   exit `0`.
2. Commit touching `agents/maintainer-ai-tools.md` only (no version change),
   same `--base`:
   `WARN: shipped content changed without a README version bump (still 0.0.22-ALPHA, was 0.0.22-ALPHA): agents/maintainer-ai-tools.md`,
   exit `2`.
3. Commit touching both `agents/maintainer-ai-tools.md` and bumping the
   README version line (`0.0.22-ALPHA` -> `0.0.23-ALPHA`), same `--base`:
   `ok: version bumped for shipped content change: 0.0.22-ALPHA -> 0.0.23-ALPHA`,
   exit `0`.
4. Same clone, no `--base` flag, run `tools/lint.sh`:
   `SKIP: version bump check needs --base <ref> (the lint workflow supplies it)`,
   exit `0` (`done: 498 ok, 1 skipped, 0 warnings`).

Extra sanity check (not required by the acceptance criteria but verified):
a commit touching only `MODELS.md` and `ROADMAP.md` reported
`ok: no shipped content changed since <base>: version bump not required`,
exit `0` — confirming those paths, plus `plans/`, `.github/`, and `tools/`
by the pathspec used, do not by themselves require a bump.

Also verified: `tools/lint.sh --help` documents `--base <ref>` and marks the
check CI-only; `tools/lint.sh --bogus` and `tools/lint.sh --base` (missing
value) both exit `1` via `fatal`; a full run against this repository at HEAD
(no `--base`) still reports `498 ok, 1 skipped, 0 warnings`, exit `0`.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | a10d79b3a94df47a0 | V -> accepted |
