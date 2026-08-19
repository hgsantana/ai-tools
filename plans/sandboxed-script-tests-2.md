# Stage 2: Install and verify contract (shell)

## Objective

Assert rules 17–22 and 25 against `scripts/shell/install.sh` and `scripts/shell/verify.sh`: symlink first with a copy fallback, never overwrite a user file, idempotency, `$HOME/AGENTS.md` left alone, the Grok managed block, `--dry-run`, and exit codes `0`/`1`/`2`.

## Files

- Create: `tools/test/install.sh` — `case_*` functions for `install.sh`
- Create: `tools/test/verify.sh` — `case_*` functions for `verify.sh`

## Steps

Each case builds its own fixture via `t_fixture` and runs with an explicit `--harnesses` list so the assertions name exact paths. Use `claude-code` as the default single-harness scope, and one multi-harness case for the shared `GEMINI.md`.

1. **Fresh install links everything** (rule 17). `install.sh --harnesses claude-code` → exit `0`. Assert: every `agents/claude-code/*-ai-tools.md` is a symlink at `home/.claude/agents/` resolving into `$AI_TOOLS`; every `skills/*-ai-tools` is a symlink at `home/.claude/skills/`; `home/.claude/CLAUDE.md` is a symlink to `USER-AGENTS.md`; output carries `linked:` and no `WARN:`.
2. **Idempotency** (rule 20). Run the same command a second time → exit `0`, output carries `already linked:` for the same destinations and no `SKIP:`/`WARN:`, and the destinations are unchanged.
3. **Foreign file on a destination is skipped, not overwritten** (rules 18, 20, 25). Fixture with a foreign regular file at `home/.claude/agents/planner-ai-tools.md` holding a known marker. Run → exit `2`; output has `SKIP: exists, not overwriting: .../planner-ai-tools.md`; the file is still a regular file with the marker byte-for-byte; every *other* wrapper still got linked (the run completes rather than aborting — rule 25).
4. **A symlink pointing elsewhere is skipped.** Fixture option that puts a symlink to an out-of-tree file on a destination → exit `2`, `SKIP: symlink points elsewhere:`, the link still points where it did.
5. **`$HOME/AGENTS.md` is user-owned** (rule 22). Two cases: absent → created, empty, `ok: created empty:`; present with content → content byte-identical afterwards and `ok: already present, untouched:`. Assert in both that it is never a symlink.
6. **`--dry-run` changes nothing** (rule 25). `t_snapshot home` before, `install.sh --harnesses claude-code --dry-run` → exit `0`, output has `would link:` and the closing `(dry-run: nothing was changed)`; `t_assert_unchanged home` after. Also assert `install.sh` skipped verification (`info: dry-run: verification skipped`).
7. **Symlink-to-copy fallback** (rule 17). `t_run_no_symlink` with `install.sh --harnesses claude-code` → the wrappers and skills arrive as regular files/directories with `ok: copied (will not track updates):` in the output; `home/.claude/CLAUDE.md` is **not** copied — instructions must stay a single source of truth, so assert `WARN: symlink refused for ... add a one-line include pointer` and exit `2`.
8. **Grok model pinning.** `install.sh --harnesses grok` → `home/.grok/config.toml` contains the marker-delimited block, one line per `agents/*-ai-tools.md`, models read from `MODELS.md` (assert the block's model tokens equal `model_for grok planner` / `implementer` resolved from the fixture's own `MODELS.md` — never a hard-coded vendor name, rule 11). Re-run → `ok: grok models block up to date:`. Then a fixture whose `config.toml` already has an unmanaged `[subagents.models]` → exit `2` with `SKIP: unmanaged [subagents.models]` and the file byte-identical. Then a fixture whose `MODELS.md` has no `grok` row → `SKIP: grok model pinning: no usable` and the config untouched.
9. **Shared `GEMINI.md`.** `install.sh --harnesses gemini,antigravity` → one link at `home/.gemini/GEMINI.md`, agents in `home/.gemini/agents/` and `home/.gemini/config/agents/` respectively, skills likewise in `skills/` and `config/skills/`.
10. **`--no-instructions`** → no instructions destination is created and `verify_install` does not warn about them (exit `0`).
11. **Precondition failures exit `1`** (rule 25). `--harnesses bogus` → exit `1`, `ERROR: unknown harness`. `--harnesses` with no value → exit `1`. `--bogus` → exit `1` with usage on stderr. A fixture where `home/.ai-tools` is a directory that is not a clone → exit `1`, `is not an ai-tools clone`.
12. **`verify.sh` cases** (`tools/test/verify.sh`): after a clean install → exit `0`, no `WARN:`. After deleting one installed agent link → exit `2` with `WARN: agent absent:`. After replacing one installed link with an unrelated regular file → exit `2` with `WARN: agent differs from source:`. With no clone at all → exit `1`, `is missing or not a clone`. Assert `verify.sh` mutates nothing: `t_snapshot`/`t_assert_unchanged` around every one of these runs.

## Tests

This stage is test code; the evidence is the suite's own output.

- `bash tools/test.sh --case install --case verify` → exit `0` with every case reporting `ok`.
- Contract-violation evidence, recorded but **not** committed: for at least the never-overwrite case and the idempotency case, temporarily break the expectation in a scratch copy of the sandbox (e.g. pre-create the destination as a link ai-tools *would* replace) and confirm the assertion reports `WARN` and the suite exits `2` — a test that cannot fail proves nothing.
- If any case exposes a genuine violation in `scripts/shell/`, record it in the Implementation log and stop: the fix is its own commit (see the base plan's Notes), not part of this stage.

## Acceptance criteria

- [ ] Every case above exists and passes, run through `tools/test.sh`
- [ ] Each case builds and destroys its own fixture; no case depends on another's leftovers
- [ ] Exit codes `0`, `1`, and `2` are each asserted at least once
- [ ] No vendor model name appears in the test code (`MODELS.md` is read, rule 11)
- [ ] Each assertion has been observed failing at least once during development
- [ ] `shellcheck`-clean; LF endings

## Commit

Suggested message: `test(shell): cover the install and verify contract`

## Dependencies

- Requires stages: 1
- Parallel-safe with: 3, 4

## Implementation log

(Append-only.)
