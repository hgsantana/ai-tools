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

- [ ] Without `--base`, the check is skipped and the run can still exit `0`
- [ ] With `--base`, a shipped-content change without a version bump exits `2` and names the paths
- [ ] `MODELS.md`, `ROADMAP.md`, `plans/`, `tools/`, and `.github/` do not by themselves require a bump
- [ ] The version is read from the README, never from a second copy of the string

## Commit

Suggested message: `chore(tools): require a version bump when shipped content changes`

## Dependencies

- Requires stages: 4
- Parallel-safe with: none

## Implementation log
