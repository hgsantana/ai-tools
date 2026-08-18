# Rule linter

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

## Goal

Ship `tools/lint.sh`, a dependency-free development check that enforces the README's mechanically verifiable rules against the tree, plus a GitHub Actions workflow running it and `shellcheck` on every push and pull request. Two size caps are tightened along the way — `USER-AGENTS.md` to 8,000 characters and every agent wrapper to 1,000 — which requires shortening the canonical wrapper body first, since 39 of 42 wrappers exceed the new cap today.

## Execution graph

1 before 2; 2 before 3; 3 before 4; 4 before 5 — stages 1 and 3–5 all write `tools/lint.sh`, and stage 2 rewrites the very text stage 3 reconstructs, so this line is strictly sequential.
6 after 1 (parallel-safe with 3, 4, and 5 — it touches only `.github/`).
7 after every other stage.

## Stages

1. [Skeleton, CLI contract, naming and coverage](./rule-linter-1.md) — creates `tools/lint.sh` sourcing `lib.sh`; checks rules 5 and 13 and skill frontmatter
2. [Tighten the caps and shorten the canonical wrapper body](./rule-linter-2.md) — rules 3 and 6 in the README, plus all 42 wrapper bodies
3. [Wrapper body and model parity](./rule-linter-3.md) — reconstructs the shortened body and compares model tokens against `MODELS.md` (rules 6, 11, 12)
4. [File format checks](./rule-linter-4.md) — the two caps, BOM, ASCII, EOL, executable bits (rules 3, 6, 26)
5. [Version bump check](./rule-linter-5.md) — `--base <ref>`: shipped content changed implies the README version changed (rule 4)
6. [CI workflow](./rule-linter-6.md) — `.github/workflows/lint.yml` running the linter and `shellcheck`
7. [Documentation](./rule-linter-7.md) — README section, ROADMAP entry, single version bump

## Notes

**Decisions taken with the user before planning** (do not revisit):

- **Shell only.** No PowerShell mirror: a mirror exercised only by a maintainer on Windows drifts in silence, which is the exact failure the linter exists to catch. Windows contributors run it under Git Bash, which the installation already presupposes.
- **`tools/lint.sh`, not `scripts/`.** `scripts/` stays exactly the five installation processes, so the linter never inherits the mirror obligation of rules 23–25. It sources `scripts/shell/lib.sh` by relative path.
- **`shellcheck` runs in CI**, over `scripts/shell/` and `tools/`. It is not required locally.
- **`USER-AGENTS.md` drops to 8,000 characters**, self-imposed and tighter than any harness constraint, to force concision. It sits at 6,592 today, so nothing has to be rewritten.
- **Wrappers cap at 1,000 characters**, which is unreachable against today's canonical body — hence stage 2. The chosen route is shortening the body (stating the Windows path convention once instead of in each of the three pointers, ~250 characters), not raising the cap and not cutting descriptions, since descriptions are exactly what a harness loads to decide whether to route to the agent.

**Reuse over reimplementation** (rule 23): `lib.sh` already provides `model_for()` (`MODELS.md` cell lookup by row and category), `ok/skip/warn/info/fatal`, and `finish()` (exit `0` clean, `2` with warnings). The linter sources it with `AI_TOOLS` pointing at the repository root — the variable is already honoured (`AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"`) — and adds no duplicate parser.

**Baseline**, measured during planning: the tree passes every check except the two new caps, which stage 2 exists to satisfy. Wrappers run 991–1,140 characters (39 of 42 over 1,000); `USER-AGENTS.md` is 6,592 characters of the new 8,000; BOM, ASCII, EOL, and mode checks all pass; all 42 wrapper bodies are already byte-identical modulo harness key, agent name, and TOML escaping. Any other finding on the first run is a linter bug, not a repository violation.

**One version bump for the whole branch**, in stage 7. Stage 2 changes shipped content but does not bump: the branch ships as one pull request, and a second bump would let stage 5's own check pass for the wrong reason.

**Out of scope**: splitting skills into wrapper plus base — that became its own roadmap story, gated on verifying how each of the seven harnesses actually loads a skill, because in Claude Code the body is already loaded lazily and the token-saving premise does not hold there. Also out: `shellcheck` findings inside the existing scripts (fix them in their own commit if any appear), any test framework or fixture harness (roadmap story 2), markdown style linting, and PowerShell static analysis.

**Commit strategy**: one Conventional Commit per stage; stage 7 carries the version bump, so the set lands as one pull request whose diff is self-consistent.
