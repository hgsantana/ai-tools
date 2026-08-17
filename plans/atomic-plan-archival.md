# Atomic plan archival

## Status

| Stage | Status | Agent |
|------:|:------:|-------|
| 1 | F | implementer — sonnet |
| 2 | F | implementer — sonnet |
| 3 | F | implementer — sonnet |

## Goal

Replace the per-file, mid-run plan archival with an atomic one: a plan's whole set (base plan, stage files, fix files) is created under `plans/` and stays there until every stage is terminal (`F` or `E`), then moves in one operation to `plans/finished/<slug>/`. Add deterministic, clock-free reentry: an archived set holding at least one `E` can return to `plans/` only on an explicit dispatch naming it; an all-`F` set is final and the attempt is refused and reported. Source story: `plans/vibe/story-atomic-plan-archival.md`.

## Execution graph

1 and 2 are parallel-safe (disjoint files). 3 after 1 and 2.

## Stages

1. [Orchestrator lifecycle](./atomic-plan-archival-1.md) — rewrite archival, reentry, queue, intake and branch rules in `agents/orchestrator-ai-tools.md`
2. [Planner format and user-wide Plans rule](./atomic-plan-archival-2.md) — canonical layout in `agents/planner-ai-tools.md` and the `Plans` section of `USER-AGENTS.md`
3. [Version bump, coherence sweep, commit](./atomic-plan-archival-3.md) — README `0.0.6-ALPHA`, repository-wide leftover sweep, 12,000-character cap check, single commit

## Notes

### Where each statement lives (one per artifact, no drift)

| Artifact | The single statement it carries |
|---|---|
| `agents/orchestrator-ai-tools.md` | The behaviour: a new `## Plan archival` section (unit, trigger, archive commit, never-scan-the-archive, reentry, refusal), plus the removal of every per-stage move and the cross-references that point at it |
| `agents/planner-ai-tools.md` | The canonical on-disk layout: the `Plan file format` tree, whose `finished/<slug>/` comment states the trigger; plus the boundary that the planner never writes into the archive |
| `USER-AGENTS.md` | The user-wide `Plans` facts, in plain words and no status codes: the set travels whole, archives once, and is reachable again only by an explicit named dispatch when it failed |
| `README.md` | Nothing about the lifecycle — by README rules 2 and 14 it is the source of truth **about this repository** (its rules, processes, installation), not a mirror of shipped agent behaviour, and it states no archival rule today. Its change is the rule-52 version bump, plus the sweep proving it contradicts nothing |

Fix files (`<slug>-F<m>.md`) are added to the planner's canonical tree in stage 2: they are part of the archived unit, so the layout that names the unit must name them.

### Design decisions

All five open questions this plan raised were answered by `vibe-ai-tools` and confirm the design exactly as written below — README bump only, archive/reopen commits, fresh reentry budget, branch reuse, fix files in the canonical tree — as do the two determinism calls (exact reentry path, collision refusal). Reasoning is recorded in `plans/vibe/decisions-atomic-plan-archival.md` (D1–D6); it is deliberately not copied here. Nothing is open: the plan is ready to execute.

- **Terminal** is `F` or `E`. The archive trigger is "execution is over", with or without failure (story decision, option B).
- **Clock-free, consistent with *Lost runs* and one-live-writer**: the trigger reads only the base plan's stage table and the Dispatch log Outcome cells — no timestamps, no elapsed time, no polling. Archival additionally requires every Dispatch log row in the set to have its Outcome filled, so a returning ghost can never find its file moved out from under it.
- **Archival is a tracked change.** Root plan files are versioned and `plans/*/` is ignored (`.gitignore`: `/plans/*/`), so the move is a tracked deletion. It is committed path-scoped (`chore(plans): archive <slug>`) after the stage commits and before PR or patch preparation, otherwise the plan branch ends dirty and the review carries the deletion as noise. Reentry mirrors it (`chore(plans): reopen <slug>`).
- **Reentry reuses the plan's existing `plan/<slug>` branch**, which carries the accepted `F` work. Cutting a fresh branch from the default branch would discard it and contradict "stages already `F` are not re-run".
- **Reentered `E` stages get a fresh 1 + 3 correction budget** (the attempt counter in the Dispatch log continues, so history is preserved). Without it a reentered stage would be `E` again with no attempt, making reentry inert.
- **Collision is refused**: reentry when `plans/<slug>.md` already exists never merges two sets under one slug.
- No migration of the sets already flat under `plans/finished/` (README rule 4). Reentry therefore resolves exactly `plans/finished/<slug>/<slug>.md`; legacy flat files are not archived sets.

### Out of scope

Stage execution, status meanings, the 3-correction limit, lost-run detection and the one-live-writer rule; `plans/dev/` and `plans/vibe/`; per-harness wrappers under `agents/<harness>/` and everything under `scripts/`; `.gitignore` (`/plans/*/` already covers `plans/finished/<slug>/`); `skills/**` (no skill states the lifecycle — `skills/planner-ai-tools/SKILL.md` "On a finished plan" and `agents/vibe-ai-tools.md` "the finished base plan" both mean *authored*, not *archived*, and must stay untouched).

### Commit strategy

One commit for the whole plan, created in stage 3: README rule 52 requires the version bump in the same commit as the shipped-content change, and a single bump cannot serve three commits. Stages 1 and 2 define no commit boundary.

### Risk

The orchestrator executing this plan runs on the base file loaded at its spawn, so this very run still archives under the old per-file rule. That is expected, not a defect; the new rule governs the next run.
