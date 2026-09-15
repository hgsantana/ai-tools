# Stage 4: Lint that rule citations resolve

## Objective

Make lint fail when README rule numbering has a gap or a `rule N` citation names a rule that does not exist, so that a future renumbering cannot leave dangling citations. Lint checks the range only; stage 6 checks meaning once, by hand.

## Files

- Create: none
- Modify: `scripts/lint.sh`, `README.md` (Development checks, check families)
- Remove: none

## Steps

1. New `check_rule_citations` (rule 1):
   - **Numbering.** Read `README.md` between `## Repository rules` and the next `## ` heading. Every line matching `^[0-9]+\. ` is a rule, and the k-th one must start with `k.`. Warn on each gap or out-of-order number. `N` is the count, 25 today.
   - **Citations.** In the tracked files `README.md`, `ROADMAP.md`, `docs/USAGE.md`, `.gitattributes`, `scripts/lint.sh`, `scripts/test.sh`, `scripts/test/*.sh`, and `scripts/shell/*.sh` (list them with `git ls-files`, so `dev/` and untracked files are excluded), extract every match of `[Rr]ules? [0-9]+([–-][0-9]+)?(, [0-9]+([–-][0-9]+)?)*`. Replace non-digits with spaces and check that every number is between 1 and `N`. Warn `"rule citation out of range (1-$N): $path:$line: $match"`.
   - `ok "rule citations resolve to README rules 1-$N"` when clean.
   - Skip `skills/` and `USER-AGENTS.md`; stage 3 forbids rule numbers there.
   - Use grep, sed, and awk only; the en dash `–` must match (UTF-8 bytes in the ERE are fine).
2. Avoid self-matches that fail. Code comments and regex literals that `lint.sh` adds must not contain an out-of-range `rule N`. Write the ERE so that its literal text does not match itself, for example `[Rr]ule[s]? ` followed by a bracket expression.
3. Call it from the Run block.
4. **`lint.sh` usage:** add "rule citations — README rules numbered 1..N without gaps; every rule N cited in tracked docs and scripts is within 1..N (rule 1)".
5. **README check families:** add "**rule citations** — Repository rules are numbered 1..N without gaps, and every `rule N` citation in `README.md`, `ROADMAP.md`, `docs/USAGE.md`, `.gitattributes`, and `scripts/` names an existing rule (rule 1)".

## Tests

Follow the verification protocol in the base plan, with declared files `scripts/lint.sh` and `README.md`.

- Scratch clone, clean tree: `scripts/lint.sh` exits 0 with 0 warnings, and prints "rule citations resolve to README rules 1-25".
- Negative probes on fresh scratch clones, each exiting 2 with its warning:
  1. In `$V/scripts/test/update.sh`, change a comment to "(rule 26)": out-of-range warning naming the file and line.
  2. In `$V/README.md`, renumber rule `12.` as `13.`: numbering gap warning.
  3. In `$V/.gitattributes`, change "rule 21" to "rules 18–30": out-of-range warning for 30.
- `scripts/test.sh` exits 0. shellcheck shows only SC1071.

## Acceptance criteria

- The check passes on the committed tree, detects all three probes, and does not match its own source.
- README and `lint.sh` usage describe it accurately.
- No change under `skills/`. No new dependency.

## Commit message

```
feat(lint): check README rule numbering and rule citations
```

## Dependencies

Stage 3.

## Implementation log
