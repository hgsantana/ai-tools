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

**Design.** Added `check_rule_citations` to `scripts/lint.sh` (rule 1), called
last in the Run block (after `check_version_bump`). Two parts, one `clean`
flag shared across both:

- Numbering: `awk` isolates the `## Repository rules` section up to the next
  `## ` heading (the `### ` subsection headings inside it do not match).
  `grep -E '^[0-9]+\. '` plus `sed -E 's/^([0-9]+)\..*/\1/'` extracts each
  rule's leading number; an `awk` pass compares the k-th number to `k` and
  reports every gap or out-of-order position. `n` (25 today) is the count of
  matched lines, reused as the citation range ceiling.
- Citations: `git -C "$AI_TOOLS" ls-files -- README.md ROADMAP.md
  docs/USAGE.md .gitattributes scripts/lint.sh scripts/test.sh
  'scripts/test/*.sh' 'scripts/shell/*.sh'` lists the declared fileset (glob
  pathspecs, no shell expansion since single-quoted). For each tracked file,
  `grep -noE` with the pattern below extracts every citation; `sed -E
  's/[^0-9]/ /g'` turns each match into space-separated numbers, checked
  against `1..n` in a shell `for` loop (no external tool beyond
  grep/sed/awk/git, per the stage's tool restriction).
- Pattern: `[Rr]ule[s]? [0-9]+(–[0-9]+|-[0-9]+)?(, [0-9]+(–[0-9]+|-[0-9]+)?)*`.
  En dash matched via a literal UTF-8 byte alternative (`–[0-9]+`) alongside
  ASCII hyphen, avoiding a multibyte-in-bracket-expression portability risk
  (used alternation `(a|b)` instead of a bracket `[ab]` for the dash).
  Self-match avoidance (stage step 2): `[Rr]ule[s]?` keeps the letters `R`/`r`
  each walled off from `ule` by a bracket close, so the pattern's own literal
  source text (wherever this file quotes it — the `pattern=` line, the usage
  heredoc, the README bullet) never itself spells a bare contiguous
  `rule`/`Rule` run followed by a space and a digit; verified by inspection
  and confirmed empirically (baseline run below is 0 warnings with
  `scripts/lint.sh` itself in the scanned fileset).
- `ok "rule citations resolve to README rules 1-$n"` fires only when both
  parts are clean.

**Usage and README.** Added the `rule citations` entry to `lint.sh`'s usage
heredoc (after `spawn protocol citation`) and the **rule citations** bullet
to README's Development checks family list (after **version bump**), both
using the exact wording given in the stage file.

**Tests** (`verify-stage.sh scripts/lint.sh README.md`, scratch clone of
`plan/readme-ruleset-sync` from the worktree):

- lint: exit 0, 391 ok / 1 skipped / 0 warnings, including `ok: rule
  citations resolve to README rules 1-25`.
- test.sh: exit 0, 305 ok / 0 skipped / 0 warnings.
- shellcheck (`-x -P scripts/shell -P scripts/test scripts/shell/*.sh
  scripts/*.sh scripts/test/*.sh`): only SC1071 on `install-zsh.sh`.

**Negative probes**, each on a fresh scratch clone of `plan/readme-ruleset-sync`
with `scripts/lint.sh` and `README.md` copied in from the worktree, probe
edit applied inside the clone, committed, then `scripts/lint.sh` run:

1. `scripts/test/update.sh:145` comment `(rule 13)` → `(rule 26)`: exit 2,
   `WARN: rule citation out of range (1-25): scripts/test/update.sh:145: rule 26`.
2. `README.md` rule `12.` renumbered to `13.` (leaving the real rule 13 line
   unchanged, so both read "13."): exit 2,
   `WARN: README rule numbering: position 12 reads "13.", expected "12." (rule 1)`.
3. `.gitattributes` `rule 21` → `rules 18–30`: exit 2,
   `WARN: rule citation out of range (1-25): .gitattributes:1: rules 18–30`.

All three probes matched their expected file:line and out-of-range number,
and each is the only warning lint reports for its clone.
