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
