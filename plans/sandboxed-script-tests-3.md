# Stage 3: Remove and reinstall contract (shell)

## Objective

Assert rules 18–20 and 25 against `scripts/shell/remove.sh` and `scripts/shell/reinstall.sh`: remove only what ai-tools created, keep locally modified copies, gate `--instructions` and `--purge`, sweep stale links, and end a reinstall in the same state a clean install produces.

## Files

- Create: `tools/test/remove.sh` — `case_*` functions for `remove.sh`
- Create: `tools/test/reinstall.sh` — `case_*` functions for `reinstall.sh`

## Steps

Every case installs first (via `t_run` on `install.sh`) unless it is testing removal from an unpopulated root.

1. **Removal unlinks what install linked.** `remove.sh --harnesses claude-code` → exit `0`; every agent and skill destination absent; output `removed link:`; `home/.claude/CLAUDE.md` **still present** (no `--instructions`).
2. **Idempotency** (rule 20). Second run → exit `0` with `ok: absent:` lines and no `WARN:`.
3. **An unmodified copy is removed; a modified copy is kept** (rule 19). Install through `t_run_no_symlink` so destinations are copies; append a line to one copied wrapper; `remove.sh` → exit `2`; the untouched copies are gone (`ok: removed copy:`), the modified one survives byte-for-byte with `SKIP: copy was modified locally, user work kept:`.
4. **A foreign file on a destination is never removed** (rule 19). Fixture with a foreign regular file named like a wrapper in the agents root → `SKIP: copy was modified locally` or `SKIP: not a symlink:` (assert whichever the code path yields, and that the file still exists with its marker).
5. **A symlink to something else is never removed.** Destination symlink pointing outside `$AI_TOOLS` → `SKIP: symlink not to ai-tools:`, link intact.
6. **`$HOME/AGENTS.md` is never touched** (rule 22). Present with content before every removal case; assert byte-identical after `remove.sh`, after `remove.sh --instructions`, and after `remove.sh --purge --yes`.
7. **`--instructions` gate.** Without it: instructions link survives. With it: `home/.claude/CLAUDE.md` removed. With scope `gemini` only while `antigravity` is also detected: `SKIP: GEMINI.md serves gemini and antigravity; antigravity not in scope` and the file survives. With scope `gemini,antigravity`: removed.
8. **Grok block.** Managed block removed and the rest of `config.toml` byte-identical around it; an unmanaged `[subagents.models]` left untouched with `SKIP:`; no `config.toml` at all → `ok: absent:`, file not created.
9. **Stale-link sweep.** Fixture option that plants a symlink into `$AI_TOOLS` under an obsolete name in an agents root. Default run → it is removed (`removed link:`). `--no-sweep` → it survives. Assert the sweep never removes a link pointing outside `$AI_TOOLS`, and never removes a real directory.
10. **`--purge` defaults to refuse** (rule 25). `remove.sh --purge` with `no` on stdin (`t_run_stdin`) → `SKIP: purge not confirmed:` and `home/.ai-tools` still present, exit `2`. With `--purge --yes` → clone deleted, exit `0`, and `home/AGENTS.md` still present. With `--purge --dry-run` → `ok: would delete:` and the clone present.
11. **`--dry-run` changes nothing.** `t_snapshot`/`t_assert_unchanged` around `remove.sh --dry-run` after a full install.
12. **Removal without a clone.** Delete `home/.ai-tools` after installing, then `remove.sh` → exit `2` with `WARN: ... missing — copies cannot be verified; removing links only (sweep)`, and the now-dangling links are gone.
13. **Precondition failures exit `1`**: `--harnesses bogus`, `--harnesses` without a value, an unknown flag.
14. **`reinstall.sh` cases** (`tools/test/reinstall.sh`):
    - From a clean fixture with no local changes → exit `0`; end state identical to a fresh `install.sh` run (compare a `t_snapshot` of `home` taken after a plain install in an equivalent fixture, ignoring the clone's own git metadata and any timestamp-bearing paths).
    - With a stale link from an older layout present → gone afterwards, and the current set installed.
    - With a locally modified copy present → kept (`SKIP:`), exit `2`.
    - With `home/.ai-tools` absent → the fresh-clone path runs offline through the fixture's `insteadOf` rewrite, `info: fresh clone — already at origin/master, reset skipped` appears, and the install completes at exit `0`.
    - With an uncommitted change inside the clone and no `--discard-local` → exit `1`, nothing removed, nothing installed (assert the harness roots are still in their pre-run state).
    - `--no-instructions` → instructions destination untouched by both the remove and the install pass.
    - `--dry-run` → nothing changes.

## Tests

This stage is test code.

- `bash tools/test.sh --case remove --case reinstall` → exit `0`.
- Each assertion observed failing once during development (as in stage 2).
- Any genuine contract violation found in `scripts/shell/` is recorded in the Implementation log and fixed in its own commit, not here.

## Acceptance criteria

- [ ] Every case above exists and passes through `tools/test.sh`
- [ ] `$HOME/AGENTS.md` survival is asserted on all three removal shapes
- [ ] `--purge` is proven to refuse without confirmation and to obey `--dry-run`
- [ ] The reinstall end state is compared against a fresh install rather than spot-checked
- [ ] Exit codes `0`, `1`, and `2` are each asserted at least once
- [ ] `shellcheck`-clean; LF endings

## Commit

Suggested message: `test(shell): cover the remove and reinstall contract`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 2, 4

## Implementation log

(Append-only.)
