# One directory per plan, ordinal first on every file

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer-ai-tools · sonnet |
| 2 | | |
| 3 | | |
| 4 | | |

## Goal

Move plan files from loose, suffix-numbered files at the root of `dev/` into a
per-plan directory whose every file carries its ordinal first — base included:
`dev/<slug>/0-<slug>.md`, `1-<slug>.md`, `2-<slug>.md`, `F1-<slug>.md`. Move all
generated plan state under a single `dev/tmp/` root (`dev/tmp/finished/`,
`dev/tmp/vibe/`), so `.gitignore` collapses to the one line `/dev/tmp/` and
`dev/` reads as "one versioned directory per plan".

## Execution graph

- Stage 1 before 2, 3 and 4.
- Stages 2, 3 and 4 are parallel-safe with each other (disjoint file sets).

Stage 1 must land first: it rewrites `.gitignore`, and until it does, a plan
directory under `dev/` is ignored and cannot be tracked or committed.

## Stages

1. [Ignore rule and on-disk layout](./1-dev-plan-directory-layout.md) — rewrite `.gitignore` to `/dev/tmp/` and migrate existing ignored state under `dev/tmp/`
2. [Canonical plan layout](./2-dev-plan-directory-layout.md) — restate the layout in `skills/plan-ai-tools.md`, which defines it
3. [Discovery, archival and Mode B](./3-dev-plan-directory-layout.md) — update every consumer of the layout in `skills/dev-ai-tools.md`
4. [Vibe records, scripts and version bump](./4-dev-plan-directory-layout.md) — `skills/vibe-ai-tools.md`, `ROADMAP.md`, the two `tools/*.sh` writers, README

## Notes

**Naming rule, applied everywhere.** For a plan with slug `<slug>`:

| File | Path |
|---|---|
| Base plan | `dev/<slug>/0-<slug>.md` |
| Stage *n* | `dev/<slug>/<n>-<slug>.md` |
| Fix file *m* | `dev/<slug>/F<m>-<slug>.md` |
| Archived set | `dev/tmp/finished/<slug>/` (same filenames inside) |
| Vibe story | `dev/tmp/vibe/story-<slug>.md` |
| Vibe decisions | `dev/tmp/vibe/decisions-<slug>.md` |
| Mode B brief | `dev/tmp/<slug>-brief.md` |
| Review patch | `dev/tmp/<slug>-review.patch` |
| Research scratch | `dev/tmp/` (moved from `dev/wip/`) |

Ordinals are **not** zero-padded, matching the demand.

**Commit strategy.** One Conventional Commit per stage, path-scoped — never
`git add -A`, because `dev/tmp/**` is ignored and the plan directory is added
deliberately.

**Two shell scripts change.** `tools/harness-models.sh` and
`tools/aa-metrics.sh` write their CSVs to `$AI_TOOLS/dev/wip` and must follow the
rename to `dev/tmp` (stage 4). `shellcheck` and `tools/test.sh` are therefore
load-bearing here, not just regression checks. `tools/test/lib.sh` needs no
change: it already excludes `./dev` wholesale from its fixture tar.

**Out of scope.** A lint check for plan layout; any change to plan *content*
(sections, status codes, dispatch ledger); the ROADMAP proposal for a versioned
`docs/decisions/` record. See `dev/tmp/vibe/decisions-dev-plan-directory-layout.md`.

**Breaking change.** README rule 4 (pre-release, no backward compatibility)
applies: no migration notes ship. Other clones fix an older layout via
Reinstallation. Stage 1 migrates this machine only, in ignored paths.
