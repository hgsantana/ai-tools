# Stage 5: Lint harness table parity

## Objective

Detect drift between the harness table in `scripts/shell/lib.sh` and the README, which covers the Scope bullet and the Supported harnesses table (base plan finding 44). This stage is optional per open question 6. Drop it if the user defers harness parity to ROADMAP story 12.

## Files

- Create: none
- Modify: `scripts/lint.sh`, `README.md` (Development checks, check families), `ROADMAP.md` (story 12)
- Remove: none

## Steps

1. New `check_harness_table` (rule 19). `lint.sh` already sources `lib.sh`, so `ALL_HARNESSES`, `skills_root`, and `instructions_dest` are available.
   - **Keys.** Take the README line containing `harness keys (`, extract the backticked tokens, and sort them. They must equal the sorted `ALL_HARNESSES`. Warn per missing or extra key.
   - **Paths.** Set `sect` to the README text between `## Supported harnesses` and the next `## `. For each key, compute the literal paths in a subshell with `HOME='$HOME'`: `r=$(HOME='$HOME'; skills_root "$h")` and `i=$(HOME='$HOME'; instructions_dest "$h")`. Then `sect` must contain `` `$r/` ``, and must contain `` `$i` `` when `i` is non-empty. Warn with the key and the missing path.
   - `ok "Supported harnesses match lib.sh (N harnesses)"` when clean.
   - Add `# shellcheck disable=SC2016` where the single-quoted `'$HOME'` is intentional.
2. Call it from the Run block.
3. **`lint.sh` usage:** add "harness table — lib.sh harness keys, skills roots, and instructions destinations appear in the README Scope bullet and Supported harnesses table (rule 19)".
4. **README check families:** add the same bullet.
5. **`ROADMAP.md` story 12:** delete the clause ", and have the linter verify that every harness key in `lib.sh` has a Supported harnesses entry". The checklist part of the story stays.

## Tests

Follow the verification protocol in the base plan, with declared files `scripts/lint.sh`, `README.md`, and `ROADMAP.md`.

- Scratch clone, clean tree: `scripts/lint.sh` exits 0 with 0 warnings, and prints "Supported harnesses match lib.sh (6 harnesses)".
- Negative probes on fresh scratch clones, each exiting 2:
  1. In `$V/scripts/shell/lib.sh`, change `cursor) echo "$HOME/.cursor/skills"` to `.cursor/skills2`: missing-path warning for cursor.
  2. In `$V/README.md`, delete `` `grok`, `` from the Scope bullet: key warning for grok.
  3. In `$V/README.md`, change `$HOME/.gemini/GEMINI.md` in the table: missing instructions path for antigravity.
- `scripts/test.sh` exits 0. shellcheck shows only SC1071.

## Acceptance criteria

- The check passes on the committed tree and catches all three probes.
- README, `lint.sh` usage, and ROADMAP story 12 are consistent.
- No change under `skills/`. No new dependency.

## Commit message

```
feat(lint): check Supported harnesses against lib.sh
```

## Dependencies

Stage 4.

## Implementation log

- Confirmed `lint.sh` sources `lib.sh` via `. "$AI_TOOLS/scripts/shell/lib.sh"` at the top, so `ALL_HARNESSES` ("claude-code grok codex copilot cursor antigravity"), `skills_root()`, and `instructions_dest()` are in scope for a new check with no extra sourcing. Confirmed `instructions_dest cursor` returns `""` (Cursor has no global instructions destination) — the draft's "when `i` is non-empty" guard is exercised for real, not just theoretical.
- Implemented `check_harness_table` (rule 19) exactly as scoped: keys parity between the README line containing `harness keys (` (Scope bullet) and `ALL_HARNESSES`, then per-key literal-path containment of `` `$r/` `` (skills root) and, when non-empty, `` `$i` `` (instructions path) inside the README text between `## Supported harnesses` and the next `## `. Paths are computed as `r=$(HOME='$HOME'; skills_root "$h")` / `i=$(HOME='$HOME'; instructions_dest "$h")` so the functions echo the literal `$HOME`-prefixed strings that appear verbatim in the README table, matched with `grep -qF` (no regex metachar risk from the paths' `.`/`/`). Emits `ok "Supported harnesses match lib.sh (N harnesses)"` when clean, one `warn` per missing/extra key and per missing path otherwise. Called from the Run block after `check_rule_citations`.
- Deviation from the draft: added a second `# shellcheck disable=SC2016` beyond the one the draft anticipated (for the `HOME='$HOME'` subshells). Shellcheck also flagged the backtick-token extraction `grep -oE '`[a-z-]+`'` used for the Scope-bullet keys (SC2016, info-level: single quotes don't expand — a false positive here, since the pattern is a literal regex, not an intended expansion). Disabled it inline with a comment so `-x` shellcheck stays at SC1071-only.
- Added the `lint.sh` usage heredoc entry ("harness table — ...") and the matching README Development checks bullet, both citing rule 19 per the draft.
- `ROADMAP.md` story 12: deleted only the clause ", and have the linter verify that every harness key in `lib.sh` has a Supported harnesses entry"; the checklist sentence and `/vibe-ai-tools` routing stay untouched.
- Verified `check_rule_citations` (stage 4) still passes with `ROADMAP.md` in its fileset ("ok: rule citations resolve to README rules 1-25") after the ROADMAP edit, and confirmed rule 19 ("`scripts/shell` is canonical. A behaviour change lands there and in the process sections below, in the same commit.") is in range 1-25 and topically fits a lib.sh/README sync check.
- Tests: `verify-stage.sh scripts/lint.sh README.md ROADMAP.md` — lint exit 0, "done: 392 ok, 1 skipped, 0 warnings", prints "ok: Supported harnesses match lib.sh (6 harnesses)"; `test.sh` exit 0, "done: 305 ok, 0 skipped, 0 warnings"; shellcheck exit 1 with only SC1071 on `install-zsh.sh` (expected, pre-existing).
- Negative probes, each on a fresh scratch clone of `plan/readme-ruleset-sync` with only `scripts/lint.sh`, `README.md`, `ROADMAP.md` copied in and the probe edit applied inside the clone:
  1. `lib.sh` cursor `skills_root` changed to `echo ".cursor/skills2"`: lint exit 2, `WARN: harness cursor: Supported harnesses table missing skills root \`.cursor/skills2/\` (rule 19)`, 1 warning total.
  2. README Scope bullet: removed `` `grok`, `` only: lint exit 2, `WARN: harness key mismatch: grok missing from README Scope bullet (rule 19)`, 1 warning total.
  3. README Supported harnesses table: `$HOME/.gemini/GEMINI.md` changed to `$HOME/.gemini/GEMINI2.md`: lint exit 2, `WARN: harness antigravity: Supported harnesses table missing instructions path \`$HOME/.gemini/GEMINI.md\` (rule 19)`, 1 warning total.
