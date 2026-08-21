# Stage 4: Vibe records, roadmap, scripts, and version bump

## Objective

Move the vibe workflow's own writes under `dev/tmp/vibe/`, update the one
ROADMAP entry that names the old path, point the two CSV-writing tools at
`dev/tmp/`, and bump the README version — required by README rule 4 for any
change under `skills/`.

This is the only stage that touches executable code, so `shellcheck` and
`tools/test.sh` are load-bearing acceptance here, not background regression
checks.

## Files

- Modify: `skills/vibe-ai-tools.md` — *Vibe Coding mode*, *Story*, *Writes*, *Boundaries*
- Modify: `ROADMAP.md` — the decision-record entry
- Modify: `tools/harness-models.sh` — `OUT_DIR` and the usage header
- Modify: `tools/aa-metrics.sh` — `OUT_DIR` and the usage header
- Modify: `README.md` — version line, and the line naming where those tools write

## Steps

1. **`skills/vibe-ai-tools.md`**, four paths, no wording changes beyond them:

   - Line 33: `dev/vibe/decisions-<slug>.md` → `dev/tmp/vibe/decisions-<slug>.md`
   - Line 37: `dev/vibe/story-<slug>.md` → `dev/tmp/vibe/story-<slug>.md`
   - Line 49 (*Writes*): "Your own writes stay under `dev/tmp/vibe/` (story,
     decisions) and `dev/<slug>/` (the plan directory)."
   - Line 55 (*Boundaries*): "Writes under `dev/tmp/vibe/` (and re-reads of
     those files) are the sole gitignored exception."

   Leave line 3 alone: it names no path under `dev/`, and it is duplicated
   verbatim as the one-sentence description in `skills/vibe-ai-tools/SKILL.md`.

2. **`ROADMAP.md`**:

   - Line 7: unchanged. "a plan exists under `dev/`" stays true.
   - Line 44: `dev/vibe/` → `dev/tmp/vibe/`. Change nothing else in that entry —
     the proposal it describes is unaffected and stays open.

3. **`tools/harness-models.sh`** — two occurrences, no logic change:

   - Line 18 (usage header): `Writes dev/wip/harness-models.csv.` →
     `Writes dev/tmp/harness-models.csv.`
   - Line 26: `OUT_DIR="$AI_TOOLS/dev/wip"` → `OUT_DIR="$AI_TOOLS/dev/tmp"`

4. **`tools/aa-metrics.sh`** — the same two, no logic change:

   - Line 16 (usage header): `Writes dev/wip/aa-metrics.csv.` →
     `Writes dev/tmp/aa-metrics.csv.`
   - Line 25: `OUT_DIR="$AI_TOOLS/dev/wip"` → `OUT_DIR="$AI_TOOLS/dev/tmp"`

   Both scripts create `OUT_DIR` themselves; neither needs a new `mkdir`.
   Confirm that by reading the surrounding lines rather than assuming it.

5. **`README.md`**, two edits and nothing else:

   - Line 3: bump `0.0.28-ALPHA` to `0.0.29-ALPHA`. Rule 4 requires it because
     content under `skills/` changed, and `tools/lint.sh --base <ref>` enforces
     it on pull requests.
   - Line 88: `they write CSVs under \`dev/wip/\`` → `` `dev/tmp/` ``, matching
     steps 3 and 4.

   The README states no rule about plan file layout, so nothing else changes.

6. Do not touch `USER-AGENTS.md`. Its two `dev/` mentions are the skill
   descriptions ("a multi-file plan under `dev/`"), which stay true and are size-
   and parity-checked by the linter.

## Tests

No automated test covers this prose. Verification is mechanical:

```bash
cd "$HOME/.ai-tools"
grep -rn 'dev/vibe\|dev/finished\|dev/wip' --include='*.md' --include='*.sh' . \
  | grep -v '^./dev/' && echo "STALE REFERENCE (bad)" || echo "clean (good)"
grep -n 'Version 0.0.29-ALPHA' README.md || echo "VERSION NOT BUMPED (bad)"
tools/lint.sh
shellcheck -x -P scripts/shell -P tools/test scripts/shell/*.sh tools/*.sh tools/test/*.sh
tools/test.sh
```

The full repository sweep runs here because this is the last stage to touch a
documentation file: after it, no path outside `dev/` may name the old layout.
`shellcheck` and `tools/test.sh` run here because this stage edits two scripts —
CI runs both on every push, so a failure here is a red build.

## Acceptance criteria

- [ ] All four vibe paths point under `dev/tmp/vibe/`; *Writes* names `dev/<slug>/`
- [ ] `ROADMAP.md` line 44 names `dev/tmp/vibe/`; the rest of the entry is unchanged
- [ ] Both `tools/*.sh` writers set `OUT_DIR="$AI_TOOLS/dev/tmp"` and say so in their usage headers
- [ ] Neither script changed in any way other than that path
- [ ] README version reads `0.0.29-ALPHA`; README line 88 names `dev/tmp/`; nothing else in the README changed
- [ ] `USER-AGENTS.md` is unchanged
- [ ] No file outside `dev/` mentions `dev/vibe`, `dev/finished` or `dev/wip`
- [ ] `tools/lint.sh` reports no new finding
- [ ] `shellcheck` passes on the CI command line
- [ ] `tools/test.sh` passes

## Commit

Suggested message: `docs: move generated plan state under dev/tmp`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 3

## Implementation log

(Append-only log added by implementers and planner during execution.)

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
