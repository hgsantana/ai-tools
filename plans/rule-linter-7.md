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
