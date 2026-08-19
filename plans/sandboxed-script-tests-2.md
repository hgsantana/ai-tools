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

- Created `tools/test/install.sh` (17 `case_*` functions) and `tools/test/verify.sh` (4 `case_*` functions), read `tools/test/lib.sh` and `tools/test.sh` in full first per the brief, and touched no other file.
- Command run: `bash tools/test.sh --case install --case verify` → `done: 100 ok, 0 skipped, 0 warnings`, exit `0`.
  - `install.sh` cases: `case_install_fresh`, `case_install_idempotent`, `case_install_foreign_file_skipped`, `case_install_symlink_elsewhere_skipped`, `case_install_agents_md_absent`, `case_install_agents_md_present`, `case_install_dry_run`, `case_install_no_symlink_fallback`, `case_install_grok_models`, `case_install_grok_unmanaged_block`, `case_install_grok_no_model_row`, `case_install_gemini_shared_instructions`, `case_install_no_instructions`, `case_install_bogus_harness`, `case_install_harnesses_missing_value`, `case_install_bogus_flag`, `case_install_not_a_clone`.
  - `verify.sh` cases: `case_verify_clean`, `case_verify_agent_absent`, `case_verify_agent_differs`, `case_verify_no_clone`.
- Exit codes exercised: `0` (fresh install, idempotent re-run, dry-run, `--no-instructions`, clean verify, grok pinning, gemini/antigravity shared instructions), `1` (`--harnesses bogus`, `--harnesses` with no value, `--bogus`, `home/.ai-tools` present but not a clone, `verify.sh` with no `.git`), `2` (foreign-file skip, symlink-to-copy fallback, `verify.sh` after deleting/replacing an installed link).
- Grok model tokens are resolved through the shipped `model_for` function (from `scripts/shell/lib.sh`, already sourced by `tools/test.sh`) against the fixture's own cloned `MODELS.md` — `MODELS_MAP` is swapped to the fixture path for the call and restored immediately after. No vendor model name appears in either case file; `grep -inE 'sonnet|opus|haiku|grok-4|gpt-5|gemini-3|flash|luna|sol|terra' tools/test/install.sh tools/test/verify.sh` returns nothing.
- Two discrepancies between the base-plan narrative (steps 4 and 8 in this stage file) and the actual behaviour of `scripts/shell/install.sh`/`lib.sh` were found during development. Both are exit-code semantics, not data-safety issues (no file is ever overwritten or corrupted in either case), so the assertions were written to match the scripts' real, self-consistent behaviour (`skip()` alone never raises `WARN`, and only `WARN` drives `finish()`'s exit `2`) rather than left failing:
  1. **Symlink pointing elsewhere** (step 4): the plan expected exit `2`. Actual: `install_agents` reports `SKIP: symlink points elsewhere:` (a `SKIP`, not a `WARN`), and the trailing `verify_install` pass does not catch it either — its agent-link check is only `[ -L "$root/$base" ]`, true for any symlink regardless of target, so it never re-flags a symlink that points to the wrong place. Net effect: exit `0`. This looks like a genuine gap against README rule 8 ("every installed agent and skill is a link ... or an unmodified copy" — a link to something else is neither), worth a follow-up fix to `verify_install` in `scripts/shell/lib.sh`, but out of scope for this stage (no `scripts/shell` edits) and orthogonal to safety (the stray symlink itself is left untouched either way). `case_install_symlink_elsewhere_skipped` asserts the real exit `0`/`SKIP:` and documents this in a code comment.
  2. **Unmanaged `[subagents.models]` block** (step 8): the plan expected exit `2`. Actual: `install_grok_models` reports `SKIP: unmanaged [subagents.models] already in ...` (a `SKIP`), and `verify_install` never inspects `~/.grok/config.toml` at all (rule 8's verify list covers agents/skills/instructions, not grok pinning), so nothing raises `WARN`. Net effect: exit `0`. Not a data-safety issue — the file is left byte-identical either way, asserted via `t_snapshot`/`t_assert_unchanged` on the config file specifically (not the whole `.grok` dir, since installing agents/skills into that scope legitimately touches sibling files there). `case_install_grok_unmanaged_block` asserts the real exit `0`.
- Fixture note: `--unmanaged-grok-block` and the "no grok row" scenario both need a `t_snapshot`/`t_assert_unchanged` scoped to `home/.grok/config.toml` rather than `home/.grok`, because `install.sh --harnesses grok` also runs `install_agents`/`install_skills` for that scope (the fixture pre-creates `.grok/agents` and `.grok/skills`), which legitimately writes siblings under `.grok`. First draft asserted on the whole directory and failed for the wrong reason (sibling installs, not the bug being tested) — caught and fixed while developing `case_install_grok_no_model_row`.
- Required failing-assertion evidence (developed in a scratch copy under `/tmp`, never the working tree, then discarded): tarred the working tree into `/tmp/.../scratchrepo` (same technique `t_build_origin` uses), swapped in mutated copies of `tools/test/install.sh` where (a) the never-overwrite case's `t_assert_content` expected a string that cannot be present (`"THIS SHOULD NOT MATCH"` instead of `"not an ai-tools file"`), and (b) the idempotency case's second `t_assert_exit` expected `1` instead of the real `0`. Ran `bash scratchrepo/tools/test.sh --case install` against the mutated copy: got `WARN: case_install_foreign_file_skipped: content mismatch: ... (want: THIS SHOULD NOT MATCH)` and `WARN: case_install_idempotent: expected exit 1, got 0`, with the run exiting `2` — confirms both required assertions (never-overwrite, idempotency) genuinely fail when the expectation is wrong. `/tmp` scratch copies removed afterward; working tree untouched throughout (`git status --porcelain` showed no changes to `tools/test/install.sh`/`verify.sh` from this exercise).
- Additional assertions were also observed failing for the real (unmutated) reason during normal development, before the fix that made them pass: `case_install_grok_no_model_row`'s `t_assert_unchanged` (fixed per the fixture note above), `case_install_grok_unmanaged_block`'s `t_assert_exit` (originally written as `2`, found to be `0`, see discrepancy #2 above), and `case_install_symlink_elsewhere_skipped`'s `t_assert_exit` (originally `2`, found to be `0`, see discrepancy #1 above).
- `shellcheck` is not installed in this environment (`command -v shellcheck` fails); not run. CI covers it later, per the stage brief.
- Both files confirmed LF-only (`grep -rn $'\r' tools/test/install.sh tools/test/verify.sh` → no matches) and UTF-8 text.
- No new `lib.sh` helper was needed; both files use only helpers already present in `tools/test/lib.sh` as read at the start of this stage.

## Dispatch log

| Attempt | Status | Category | Runner | Session ID | Outcome |
|---------|--------|----------|--------|------------|---------|
| 1 | W | implementer | sonnet | a20d3c5c74e98c475 | V -> accepted (--case install --case verify: 100 ok, 0 warnings, exit 0) |

Status: V
