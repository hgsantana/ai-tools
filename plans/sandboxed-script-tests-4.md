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
