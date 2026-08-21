# Stage 1: Ignore rule and on-disk layout

## Objective

Make `dev/` mean "one versioned directory per plan" and `dev/tmp/` mean "every
generated, ignored artefact". Rewrite `.gitignore` to a single rule, and migrate
this machine's existing ignored state into the new shape.

This stage must land before stages 2–4: until `.gitignore` changes, the plan
directory `dev/dev-plan-directory-layout/` is ignored and cannot be committed.

## Files

- Modify: `.gitignore` — replace `/dev/*/` with `/dev/tmp/`
- Move (untracked, ignored, no diff): `dev/wip/` contents → `dev/tmp/`
- Move (untracked, ignored, no diff): `dev/finished/` → `dev/tmp/finished/`
- Move (untracked, ignored, no diff): `dev/vibe/` → `dev/tmp/vibe/` (already done by the planner for this run's own records)
- Rename (untracked, ignored, no diff): plan files inside each archived set

## Steps

1. Rewrite `.gitignore` in full to exactly these two lines:

   ```gitignore
   # Plans are versioned per directory under dev/; generated state is not.
   /dev/tmp/
   ```

   The trailing slash keeps it a directory-only rule. Do not add any other
   pattern — a single literal path is the point of the change.

2. Move the existing research scratch out of `dev/wip/` and into `dev/tmp/`,
   then retire `dev/wip/`. `dev/tmp/vibe/` already exists — the planner moved
   this run's story and decisions there.

   ```bash
   cd "$HOME/.ai-tools"
   mkdir -p dev/tmp
   if [ -d dev/wip ]; then
     for e in dev/wip/* dev/wip/.[!.]*; do
       [ -e "$e" ] || continue
       mv "$e" dev/tmp/
     done
     rmdir dev/wip
   fi
   ```

   Expected to move: `csv/`, `mkt/`, `harness-models/`, `harness-models.csv`,
   `livebench-model-map.csv`, `metrics.md`, `models.md`, `models-aa.md`,
   `models-reasoning.md`, `agy-slug-tie-break-fix-brief.md`.

3. Migrate the archived sets into `dev/tmp/finished/`.

   ```bash
   cd "$HOME/.ai-tools"
   mkdir -p dev/tmp/finished
   for d in dev/finished/*/; do
     [ -d "$d" ] || continue
     mv "$d" dev/tmp/finished/
   done
   rmdir dev/finished 2>/dev/null
   ```

4. Rename the files inside each archived set to the new convention. The base
   file `<slug>.md` becomes `0-<slug>.md`; each stage `<slug>-<n>.md` becomes
   `<n>-<slug>.md`; any fix file `<slug>-F<m>.md` becomes `F<m>-<slug>.md`.

   ```bash
   cd "$HOME/.ai-tools/dev/tmp/finished"
   for dir in */; do
     slug="${dir%/}"
     for f in "$slug"/*.md; do
       base=$(basename "$f" .md)
       case "$base" in
         "$slug")        mv "$f" "$slug/0-$slug.md" ;;
         "$slug"-F*)     mv "$f" "$slug/F${base#"$slug"-F}-$slug.md" ;;
         "$slug"-*)      mv "$f" "$slug/${base#"$slug"-}-$slug.md" ;;
       esac
     done
   done
   ```

   Expected result — three sets, already on disk:

   - `dev/tmp/finished/agy-slug-tie-break/` → `0-…md`, `1-…md`
   - `dev/tmp/finished/devcontainer-setup-harness-clis/` → `0-…md`, `1-…md`, `2-…md`
   - `dev/tmp/finished/repeatable-model-map-refresh/` → `0-…md` … `5-…md`

5. Migrate the remaining vibe records from the old directory, if any are still
   there, then remove it:

   ```bash
   cd "$HOME/.ai-tools"
   [ -d dev/vibe ] && mv dev/vibe/*.md dev/tmp/vibe/ 2>/dev/null
   rmdir dev/vibe 2>/dev/null
   ```

6. Verify the ignore rule behaves as intended:

   ```bash
   cd "$HOME/.ai-tools"
   git check-ignore -v dev/tmp/finished || echo "NOT IGNORED (bad)"
   git check-ignore -v dev/dev-plan-directory-layout/0-dev-plan-directory-layout.md \
     && echo "PLAN IGNORED (bad)" || echo "plan trackable (good)"
   git status --short
   ```

7. Confirm nothing is left behind: `dev/wip/`, `dev/finished/` and `dev/vibe/`
   must all be gone, and no file may have been deleted — every move is a
   rename, never a copy-and-remove.

## Tests

No unit or integration tests: `.gitignore` is not executable code and the moves
touch only ignored paths.

Behavioural verification is step 6 — `git check-ignore` asserting both
directions of the new rule — plus, once files exist under both:

```bash
git status --porcelain | grep '^?? dev/tmp' && echo "LEAK (bad)" || echo "wip clean (good)"
```

## Acceptance criteria

- [ ] `.gitignore` contains exactly one ignore pattern, `/dev/tmp/`, plus its comment
- [ ] `git check-ignore dev/tmp/finished` succeeds; `git check-ignore` on a file under `dev/dev-plan-directory-layout/` fails
- [ ] `dev/wip/`, `dev/finished/` and `dev/vibe/` no longer exist
- [ ] `dev/tmp/finished/` holds all three previously archived sets, files renamed ordinal-first with a `0-` base
- [ ] `dev/tmp/vibe/` holds all six previously existing records plus this run's two
- [ ] `git status --short` shows no untracked path under `dev/tmp/`
- [ ] The former `dev/wip/` research contents are all present under `dev/tmp/`, unmodified

## Commit

Suggested message: `chore(dev): reserve dev/tmp for generated plan state`

Path-scoped: `git add .gitignore` only. The moves are untracked and ignored and
contribute nothing to the diff — this is expected, and the commit body should
say so.

## Dependencies

- Requires stages: none. This is the first stage.
- Parallel-safe with: nothing — stages 2, 3 and 4 all follow it.

## Implementation log

(Append-only log added by implementers and planner during execution.)

- Rewrote `.gitignore` to exactly:
  ```
  # Plans are versioned per directory under dev/; generated state is not.
  /dev/tmp/
  ```
  `git diff .gitignore`:
  ```
  -# Keep root plan Markdown files trackable; ignore generated plan directories.
  -/dev/*/
  +# Plans are versioned per directory under dev/; generated state is not.
  +/dev/tmp/
  ```
- Moved `dev/wip/*` (9 entries: `csv/`, `mkt/`, `harness-models/`, `harness-models.csv`,
  `livebench-model-map.csv`, `metrics.md`, `models.md`, `models-aa.md`,
  `models-reasoning.md`, `agy-slug-tie-break-fix-brief.md`) into `dev/tmp/` via `mv`,
  then `rmdir dev/wip`. File sizes verified identical before/after (e.g.
  `harness-models.csv` 39540 bytes, `livebench-model-map.csv` 34063 bytes,
  `metrics.md` 12589 bytes — unchanged).
- Moved the three archived sets `dev/finished/{agy-slug-tie-break,
  devcontainer-setup-harness-clis, repeatable-model-map-refresh}/` into
  `dev/tmp/finished/` via `mv`, then `rmdir dev/finished`.
- Renamed files inside each archived set to ordinal-first, base included:
  - `agy-slug-tie-break/`: `agy-slug-tie-break.md`→`0-agy-slug-tie-break.md`,
    `agy-slug-tie-break-1.md`→`1-agy-slug-tie-break.md`
  - `devcontainer-setup-harness-clis/`: base→`0-…md`, `-1`→`1-…md`, `-2`→`2-…md`
  - `repeatable-model-map-refresh/`: base→`0-…md`, `-1`..`-5`→`1-…md`..`5-…md`
  - No `F*` fix files existed in any of the three sets, so no F-renames applied.
- Moved the 6 pre-existing `dev/vibe/*.md` records into `dev/tmp/vibe/` (which
  already held this run's 2 records, `decisions-dev-plan-directory-layout.md`
  and `story-dev-plan-directory-layout.md`, placed there by the planner and
  left untouched), then `rmdir dev/vibe`. `dev/tmp/vibe/` now holds 8 files.
- All moves used `mv` (rename); none used copy-then-delete.

**Verification evidence:**

```
$ git check-ignore -v dev/tmp/finished
.gitignore:2:/dev/tmp/	dev/tmp/finished

$ git check-ignore -v dev/dev-plan-directory-layout/0-dev-plan-directory-layout.md
(no output, exit 1) → "plan trackable (good)"

$ git status --short
 M .gitignore
?? dev/

$ git status --porcelain | grep '^?? dev/tmp' && echo LEAK || echo "wip clean (good)"
wip clean (good)

$ git status --porcelain=v1 --untracked-files=all -- dev/
?? dev/dev-plan-directory-layout/0-dev-plan-directory-layout.md
?? dev/dev-plan-directory-layout/1-dev-plan-directory-layout.md
?? dev/dev-plan-directory-layout/2-dev-plan-directory-layout.md
?? dev/dev-plan-directory-layout/3-dev-plan-directory-layout.md
?? dev/dev-plan-directory-layout/4-dev-plan-directory-layout.md
```
(confirms `--untracked-files=all` expansion under `dev/` surfaces only the
plan directory's own files — nothing from `dev/tmp/` — i.e. the ignore rule
is airtight in both directions.)

```
$ for d in dev/wip dev/finished dev/vibe; do [ -d "$d" ] && echo "$d STILL EXISTS" || echo "$d gone"; done
dev/wip gone
dev/finished gone
dev/vibe gone

$ ls -la dev/
dev-plan-directory-layout/
tmp/

$ find dev/tmp/finished -type f | sort
dev/tmp/finished/agy-slug-tie-break/0-agy-slug-tie-break.md
dev/tmp/finished/agy-slug-tie-break/1-agy-slug-tie-break.md
dev/tmp/finished/devcontainer-setup-harness-clis/0-devcontainer-setup-harness-clis.md
dev/tmp/finished/devcontainer-setup-harness-clis/1-devcontainer-setup-harness-clis.md
dev/tmp/finished/devcontainer-setup-harness-clis/2-devcontainer-setup-harness-clis.md
dev/tmp/finished/repeatable-model-map-refresh/0-repeatable-model-map-refresh.md
dev/tmp/finished/repeatable-model-map-refresh/1-repeatable-model-map-refresh.md
dev/tmp/finished/repeatable-model-map-refresh/2-repeatable-model-map-refresh.md
dev/tmp/finished/repeatable-model-map-refresh/3-repeatable-model-map-refresh.md
dev/tmp/finished/repeatable-model-map-refresh/4-repeatable-model-map-refresh.md
dev/tmp/finished/repeatable-model-map-refresh/5-repeatable-model-map-refresh.md

$ ls dev/tmp/vibe/ | sort
decisions-agy-slug-tie-break.md
decisions-devcontainer-setup-harness-clis.md
decisions-dev-plan-directory-layout.md
decisions-repeatable-model-map-refresh.md
story-agy-slug-tie-break.md
story-devcontainer-setup-harness-clis.md
story-dev-plan-directory-layout.md
story-repeatable-model-map-refresh.md
```

All acceptance criteria satisfied. `.gitignore` contains exactly one pattern
plus comment; `dev/tmp/finished` is ignored while plan files under
`dev/dev-plan-directory-layout/` are trackable; `dev/wip`, `dev/finished`,
`dev/vibe` no longer exist; `dev/tmp/finished/` holds all three sets renamed
ordinal-first with `0-` bases; `dev/tmp/vibe/` holds 8 files (6 prior + 2 this
run's); `git status --short` shows no untracked path under `dev/tmp/`; every
move was a rename (verified via file-size equality), no content deleted.

## Dispatch log

| Attempt | Status | Agent | Runner | Session ID | Outcome |
|---------|--------|-------|--------|------------|---------|
| 1 | W | implementer-ai-tools | sonnet | 43451650-7d37-4e6d-8c5f-c9f7dd675800 | V → accepted |
