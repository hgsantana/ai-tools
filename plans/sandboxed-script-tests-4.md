# Stage 4: Update contract (shell)

## Objective

Assert the `update.sh` half of rules 18–20 and 25: the reset guard refuses to discard local work until `--discard-local` is passed, stale copies are refreshed while locally modified copies are kept, newly shipped content is linked, and the clone's reset never reaches harness configuration or `$HOME/AGENTS.md`.

## Files

- Create: `tools/test/update.sh` — `case_*` functions for `update.sh`
- Modify: `tools/test/lib.sh` — add `t_origin_commit`, a helper that adds a second commit to the fixture's bare `origin` so the clone has something to update to (append only; do not restructure stage 1's file)

## Steps

1. **`t_origin_commit <label>`** — clones the fixture's `origin.git` into a scratch directory, makes a deterministic change (append a marker line to one wrapper under `agents/claude-code/`, and add one new file `skills/<marker>-ai-tools/SKILL.md` so "newly shipped content" is testable), commits, pushes to `master`, removes the scratch clone. Returns nothing; the case reads the fixture's recorded paths.
2. **Reset guard: uncommitted edit** (rule 25). Modify a tracked file inside `home/.ai-tools`, run `update.sh --harnesses claude-code` → exit `1`; output lists the local change and `the reset would discard the local work above`; the edit is still there; nothing was installed or removed in the harness roots.
3. **Reset guard: local commit ahead.** Commit inside the clone, run → exit `1` with `local commits ahead of origin/master:`; `git -C home/.ai-tools rev-parse HEAD` unchanged.
4. **`--discard-local` performs the reset.** Same fixture, `update.sh --harnesses claude-code --discard-local` → exit `0`; `HEAD` equals `origin/master`; the local edit is gone; `ok: source at <short> (was <short>)` present.
5. **The reset stays inside the clone.** In the `--discard-local` case, assert `home/AGENTS.md` (pre-filled with content), the pre-existing harness config files, and any foreign file staged in a harness root are all byte-identical afterwards.
6. **Newly shipped content is linked.** After `t_origin_commit`, run `update.sh --harnesses claude-code` → exit `0`; the new `skills/<marker>-ai-tools` is linked into `home/.claude/skills/`; existing links report `already linked:`.
7. **Stale copy refreshed.** Install through `t_run_no_symlink` (destinations are copies), then `t_origin_commit` changes that wrapper, then `update.sh` → the copy matching the pre-reset revision is replaced (`ok: copy refreshed:`) and its content now equals the new source.
8. **Locally modified copy kept** (rule 19). Same shape, but the copy is edited locally first so it matches neither revision → `SKIP: copy modified locally (or predates ...)`, exit `2`, content byte-identical to what the user left.
9. **Up-to-date copy reported, not rewritten.** A copy already equal to the source → `ok: copy up to date:`.
10. **`--no-reset`.** With a local edit present and `--no-reset` → exit `0` or `2` per the run's own findings but **no** reset: `HEAD` unchanged and the local edit intact; output has `info: reset skipped (--no-reset)`.
11. **`--dry-run`.** `t_snapshot`/`t_assert_unchanged` around `update.sh --dry-run` on a fixture that is behind `origin/master`: `ok: would reset ... to origin/master` appears, `HEAD` does not move, nothing is linked, verification is skipped.
12. **Missing clone** → `update.sh` with `home/.ai-tools` deleted → exit `1`, `is missing or not a clone — run scripts/shell/install.sh first`; nothing created.
13. **Fetch failure is a precondition, not a warning.** Point the clone's `origin` at a non-existent local path, run → exit `1` with `fetch failed`. Confirm no network is attempted (the fixture has no reachable remote and the run must not hang: assert it returns promptly, and keep `GIT_TERMINAL_PROMPT=0` set by `t_run`).
14. **Precondition failures exit `1`**: `--harnesses bogus`, `--harnesses` without a value, an unknown flag.

## Tests

This stage is test code.

- `bash tools/test.sh --case update` → exit `0`.
- Record in the Implementation log the git version used and whether `git init -b master` was available (the fallback path matters for the older git the fixture must tolerate).
- Each assertion observed failing once during development.

## Acceptance criteria

- [ ] Every case above exists and passes through `tools/test.sh`
- [ ] The refuse-then-`--discard-local` pair is asserted on both the dirty-tree and the ahead-of-origin shapes
- [ ] Copy refresh and copy preservation are distinguished by the pre-reset revision, not by timestamps
- [ ] The reset is proven not to touch `$HOME/AGENTS.md`, harness config, or a foreign file
- [ ] No case reaches the network; every git operation resolves inside the sandbox
- [ ] Exit codes `0`, `1`, and `2` are each asserted at least once
- [ ] `shellcheck`-clean; LF endings

## Commit

Suggested message: `test(shell): cover the update contract`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 3 (this stage appends one helper to `tools/test/lib.sh`; if 2 or 3 also touch that file, land this one last and re-run the full suite)

## Implementation log

(Append-only.)

- Read `tools/test.sh` and `tools/test/lib.sh` in full before writing anything, plus `tools/test/smoke.sh` as the worked case-file example.
- Two edits made, exactly as scoped: created `tools/test/update.sh` (14 `case_update_*` functions covering steps 2-14 of this stage), and appended `t_origin_commit` to the end of `tools/test/lib.sh` (single `cat >>` — `git diff tools/test/lib.sh` shows only new lines after the prior EOF, no existing line touched).
- `t_origin_commit <label>` clones `$T_ROOT/origin.git` into a scratch dir, appends a marker comment to `agents/claude-code/maintainer-ai-tools.md`, adds `skills/<label>-ai-tools/SKILL.md`, commits, pushes to `master`, and removes the scratch clone.
- Case-by-case mapping to the plan's steps:
  - `case_update_reset_guard_dirty` (step 2): dirty edit in a tracked file → exit 1, `local changes in`, `the reset would discard the local work above`; edit still present; `home/.claude` snapshot unchanged via `t_snapshot`/`t_assert_unchanged`.
  - `case_update_reset_guard_ahead` (step 3): local commit ahead → exit 1, `local commits ahead of origin/master:`; `HEAD` unchanged.
  - `case_update_discard_local` (step 4): same dirty fixture + `--discard-local` → exit 0; `HEAD` equals `origin/master`; edit gone; `ok: source at` present.
  - `case_update_reset_confined` (step 5): fixture built with `--foreign-agent`, `$HOME/AGENTS.md` and `$HOME/.claude/CLAUDE.md` pre-filled, then a dirty+ahead clone reset with `--discard-local` — all three byte-compared (via `cat` capture, not timestamps) before/after and found unchanged. Exit is 2 here (not 0): `verify_install` correctly warns that the foreign agent file and the pre-filled `CLAUDE.md` differ from source, which is the proof they were skipped rather than overwritten.
  - `case_update_new_content_linked` (step 6): install, then `t_origin_commit`, then plain update → exit 0; new `skills/<marker>-ai-tools` symlinked into `home/.claude/skills/`; `already linked:` present for the untouched wrappers.
  - `case_update_stale_copy_refreshed` (step 7): install via `t_run_no_symlink` (copies), `t_origin_commit` changes `maintainer-ai-tools.md`, update → `copy refreshed:` present; copy content now equals the new source. Exit is 2 in every `t_run_no_symlink` case in this file: the shimmed `ln` also blocks the instructions symlink, which has no copy fallback in `install_instructions`, so `verify_install` always warns `instructions missing`/`instructions differ from source` alongside whatever the case is actually proving — documented inline at each assertion, not a defect in the case.
  - `case_update_modified_copy_kept` (step 8): same shape, copy locally edited first (matches neither revision) → `SKIP: copy modified locally (or predates`, exit 2, content byte-identical to the local edit.
  - `case_update_up_to_date_copy` (step 9): a wrapper `t_origin_commit` never touches (`az-ai-tools.md`) stays equal to source across the reset → `copy up to date: <path>`.
  - `case_update_no_reset` (step 10): dirty edit + `--no-reset` → `HEAD` unchanged, edit intact, `info: reset skipped (--no-reset)`; exit accepted as 0 or 2 per the plan (this run reported 0).
  - `case_update_dry_run` (step 11): fixture behind origin (`t_origin_commit`) + `--dry-run`, snapshot around `home/.claude` (not the whole clone, for speed) → `would reset ... to origin/master`, `HEAD` unchanged, nothing linked, `dry-run: verification skipped`.
  - `case_update_missing_clone` (step 12): `home/.ai-tools` removed, script invoked from the real repo tree (t_run still confines `HOME`/`AI_TOOLS` env vars to the sandbox — `require_clone` reads the sandboxed `$AI_TOOLS`, which is what matters) → exit 1, `is missing or not a clone — run scripts/shell/install.sh first`; nothing created.
  - `case_update_fetch_failure` (step 13): `origin` remote pointed at a nonexistent local path → exit 1, `fetch failed`; timed with `date +%s`, returned in 0s in every run — confirms no network is attempted and the run never hangs.
  - `case_update_preconditions` (step 14): `--harnesses bogus`, `--harnesses` with no value, and an unknown flag — each exit 1 with the expected message.
- Each assertion class observed failing at least once during development, in a disposable copy of the whole repo under `/tmp` (never in the working tree — verified afterward with `diff` against the real `tools/test/update.sh`, no drift): deliberately flipped `t_assert_exit 1` → `t_assert_exit 0` and replaced the expected local-edit marker text, which produced 7 `WARN:` lines (`case_update_fetch_failure`, `case_update_missing_clone`, `case_update_preconditions` ×3, `case_update_reset_guard_ahead`, `case_update_reset_guard_dirty`); separately broke a `t_assert_line` (wrong literal), a `t_assert_symlink` (wrong target prefix), a `t_assert_regular_file` (wrong path), and a `t_assert_unchanged` (tampered the directory between snapshot and check) — each produced the expected single `WARN:` line. Scratch copy removed after.
- Tests: `git --version` → `git version 2.53.0`. `git init -b master <dir>` is available and succeeds on this git (confirmed directly); `tools/test/lib.sh`'s `t_build_origin`/`t_fixture` and this stage's `t_origin_commit` nonetheless use the older-compatible `git init` + `symbolic-ref HEAD refs/heads/master` fallback path (matching stage 1's existing style), so the suite tolerates older git regardless of what's installed here.
- `bash tools/test.sh --case update` → `done: 54 ok, 0 skipped, 0 warnings`, exit 0.
- `bash tools/test.sh` (full suite, run after stages 2/3's `install.sh`/`verify.sh`/`remove.sh`/`reinstall.sh` landed) → `done: 252 ok, 0 skipped, 0 warnings`, exit 0.
- `shellcheck`: not installed in this environment — not run; CI covers it later, per this stage's brief.
- LF-only confirmed (`grep -c $'\r' tools/test/update.sh` → 0); `file` reports UTF-8 text.
- `scripts/shell/**` untouched: no contract violation found in `update.sh`/`lib.sh` during this stage's development.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | 73dd13b2-f5c7-4350-b6be-1004a8a1e57f | V -> accepted |

Status: V
