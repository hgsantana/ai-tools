# Stage 2: Canonical plan layout in plan-ai-tools

## Objective

`skills/plan-ai-tools.md` is where the plan file layout is *defined*; every other
file cites it. Restate that definition for the new layout: a per-plan directory
with the ordinal first on every file, base included, and a single ignored root
for generated state.

## Files

- Modify: `skills/plan-ai-tools.md` — *Workflow* step 5, *Where plans live*, *Plan file format*, *Boundaries*

## Steps

Edit only the passages below. Leave the plan's *content* — the base file
sections, the stage file template, the status code table, the Agent column
note — untouched. This is a rename, not a redesign.

1. **Workflow step 5** (line 37). Replace the two paths:

   > 5. **Save**: write base `dev/<slug>/0-<slug>.md` and stage
   > `dev/<slug>/<n>-<slug>.md` files with empty Status/Agent cells,
   > incrementally as they are drafted rather than only at the end — a planner
   > that dies mid-run must leave its partial draft on disk for a successor to
   > resume (*Truth on disk*).

   Keep the rest of the sentence verbatim.

2. **Where plans live** (lines 42–45). The first bullet keeps its meaning; the
   second and third carry the substance of the change:

   - Bullet 1 (line 42): unchanged in meaning — `dev/` in the working
     repository holds every plan; outside a git repository write to
     `$HOME/.ai-tools-plans`. Add that the same per-plan directory layout
     applies there too.
   - Bullet 2 (line 43): replace entirely. New rule: in a git repository each
     plan is a versioned directory `dev/<slug>/` — keep it out of ignore rules
     and include it in path-scoped commits. Generated state is transient and
     lives under one ignored root, `dev/tmp/`; the whole ignore policy is the
     single rule `/dev/tmp/`.
   - Bullet 3 (line 44): replace the two paths. `dev/tmp/` (ad-hoc briefs and
     feedback for `dev-ai-tools`, plus `dev/tmp/finished/` and `dev/tmp/vibe/`)
     stays out of the plan queue. Plan only as `dev/<slug>/0-<slug>.md`.
   - Bullet 4 (line 45): unchanged — the "working state, not a historical
     record" paragraph mentions no path.

3. **Plan file format** — the code block (lines 61–66). Replace with:

   ```text
   dev/
     <slug>/
       0-<slug>.md       # base plan
       1-<slug>.md       # stage 1
       2-<slug>.md       # stage 2
       F1-<slug>.md      # fix file, added by `dev-ai-tools` during corrections
     wip/
       finished/<slug>/  # the whole plan directory, moved here by `dev-ai-tools` in one move, only once every stage is terminal (`F` or `E`)
   ```

   Note in the surrounding prose that the ordinal is first on every file, base
   included, so a listing of `dev/<slug>/` reads in order — digits sort before
   the `F` of a fix file.

4. **Base file heading** (line 69). `### Base file (`dev/<slug>/0-<slug>.md`)`.

5. **Stages list inside the base file template** (lines 92–93). The relative
   links become siblings inside the plan directory:

   ```markdown
   1. [Short title](./1-<slug>.md) — one-line summary
   2. [Short title](./2-<slug>.md) — one-line summary
   ```

6. **Stage file heading** (line 115). `### Stage file (`dev/<slug>/<n>-<slug>.md`)`.

7. **Boundaries** (line 162). Replace the archive path:

   > - Write only under `dev/`. `dev-ai-tools` owns the archive under `dev/tmp/finished/`.

8. Leave lines 3, 11 and 25 as they are. They say "under `dev/`", which stays
   true after this change, and line 3 is duplicated verbatim as the one-sentence
   description in `skills/plan-ai-tools/SKILL.md`. Editing one without the other
   would desync the pair for no gain.

## Tests

No automated test covers skill prose. Verification is mechanical:

```bash
cd "$HOME/.ai-tools"
grep -nE 'dev/<slug>\.md|dev/<slug>-|dev/finished|dev/vibe' skills/plan-ai-tools.md \
  && echo "STALE REFERENCE (bad)" || echo "clean (good)"
tools/lint.sh
```

`tools/lint.sh` must report no new finding — in particular the skill wrapper
body, skill base coverage, and size-cap checks.

## Acceptance criteria

- [ ] Every plan path in the file uses `dev/<slug>/<ordinal>-<slug>.md`, base `0-`
- [ ] The format code block shows the directory, all four file kinds, and the archive under `dev/tmp/finished/`
- [ ] *Where plans live* states the ignore policy as the single rule `/dev/tmp/`
- [ ] *Boundaries* points the archive at `dev/tmp/finished/`
- [ ] Relative links in the base file template resolve inside the plan directory
- [ ] No occurrence of `dev/<slug>.md`, `dev/<slug>-`, `dev/finished`, or `dev/vibe` remains
- [ ] Plan *content* (sections, status codes, dispatch ledger) is unchanged
- [ ] `tools/lint.sh` reports no new finding

## Commit

Suggested message: `docs(skills): number every plan file inside a per-plan directory`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 3, 4

## Implementation log

(Append-only log added by implementers and planner during execution.)

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
