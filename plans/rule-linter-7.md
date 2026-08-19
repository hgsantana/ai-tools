# Stage 7: Documentation

## Objective

Make the linter part of the README, which is this repository's single source of truth (rule 1), and close the roadmap entry.

## Files

- Modify: `README.md` — document the linter and bump the version
- Modify: `ROADMAP.md` — mark story 1 as shipped

## Steps

1. Add a short **Development checks** subsection near [Scripts](#scripts). State: what `tools/lint.sh` verifies (one line per check family, referencing the rule numbers), how to run it, its exit codes, that CI runs it with `shellcheck` on every push and pull request, and how to add a check when a rule becomes mechanically verifiable.
2. State explicitly that `tools/lint.sh` is a **development check, not an installation process**: it is deliberately outside the contract of rules 23–25 and therefore ships **without** a PowerShell mirror. Record the reason in one clause — a mirror only a Windows maintainer exercises drifts in silence, which is the failure the linter exists to catch — and point Windows contributors at Git Bash. Without this sentence the missing `.ps1` reads as an oversight, and someone will eventually "fix" it.
3. Note that `scripts/` remains exactly the five installation processes, and that `tools/` holds development tooling.
4. Make sure the two caps introduced in stage 2 read as rules, not as linter settings: the README states them (rules 3 and 6) and the linter merely enforces them. If the same number appears in both places, the README is the one a reader must be able to trust.
5. Bump the version at the top of the README, in this same commit (rule 4), and keep the wording consistent with the existing line.
6. In `ROADMAP.md`, delete story 1's section and its table row, per the roadmap's own rule that a shipped story leaves the file. Renumbering the remaining stories is **not** required — leave the existing numbers and anchors intact so nothing else in the file has to move.

## Tests

Documentation only. Evidence: `tools/lint.sh` still exits `0` after the README edit (the cap check reads `USER-AGENTS.md`, untouched here, but the run confirms nothing regressed), and every relative link added to the README resolves to an existing path.

## Acceptance criteria

- [ ] The README documents every check family, the invocation, and the exit codes
- [ ] The shell-only decision and its reason are stated where a reader would otherwise see a missing mirror
- [ ] The version is bumped in this commit — once for the whole branch, and only here
- [ ] The 8,000 and 1,000 caps are documented as rules, with the linter presented as their enforcement
- [ ] Story 1 is removed from `ROADMAP.md`, table row included, with no other entry disturbed
- [ ] The linter passes on the final tree

## Commit

Suggested message: `docs: document the rule linter and bump the version`

## Dependencies

- Requires stages: 1, 2, 3, 4, 5, 6
- Parallel-safe with: none

## Implementation log

- Added `## Development checks` subsection to `README.md`, placed between `## Scripts` and `## Safety rules`. Documents each check family with its rule number(s), the invocation, exit codes, CI wiring (`.github/workflows/lint.yml` runs `tools/lint.sh --base <event base>` then `shellcheck`), the shell-only decision (no PowerShell mirror, reason stated, Git Bash pointed to for Windows contributors), the `scripts/` vs `tools/` split, and the instruction to add a check + rule number in the same commit a rule becomes mechanically verifiable. Presents the 8,000/1,000 caps as README-stated rules (3, 6) with the linter as enforcement only, per step 4.
- Bumped README version line (line 3) from `0.0.22-ALPHA` to `0.0.23-ALPHA`, wording otherwise unchanged.
- `ROADMAP.md`: removed story 1's table row (`| 1 | [Rule linter]... | doing |`) and its `### 1. Rule linter` section body under `## Quality net`. No other row/anchor renumbered, per the plan's instruction not to renumber.
- Relative link added to README: `[`tools/lint.sh`](tools/lint.sh)` — resolves; file exists at `/home/wsl/.ai-tools/tools/lint.sh` (mode 100755). `.github/workflows/lint.yml` is referenced in backticks (not a markdown link) and also exists at `/home/wsl/.ai-tools/.github/workflows/lint.yml`.

### Test evidence

- `./tools/lint.sh` (no flags), run after all edits: exit `0`. Tail: `done: 498 ok, 1 skipped, 0 warnings` (the one skip is the version-bump check, which needs `--base`).
- `./tools/lint.sh --base master`, run after all edits: **exit `2`**, not `0`. The version-bump check (`check_version_bump` in `tools/lint.sh`) compares `git show <base>:README.md` against `git show HEAD:README.md` — committed content only, via `git diff --name-only base...HEAD` for the changed-paths list. Since this stage's instructions forbid committing, the working-tree version bump (now `0.0.23-ALPHA`) is invisible to that check: `HEAD:README.md` still reads `0.0.22-ALPHA`, so it reports "still 0.0.22-ALPHA, was 0.0.22-ALPHA" and warns, because `agents/**` wrapper files already differ between `master` and `HEAD` (from stages 1–6's committed work). This is expected to resolve to exit `0` once this stage's edit is committed — the check inherently needs a commit to observe a version bump, and committing is out of this stage's scope per the Dispatch instructions ("Do not commit").
- Command run: `./tools/lint.sh --base master > /tmp/lintout.txt 2>&1; echo "EXIT=$?"` → `EXIT=2`.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | V | implementer | sonnet | afcc8e97d5ca8afc5 | V -> accepted |
