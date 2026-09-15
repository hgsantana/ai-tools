# Stage 3: Lint grammar identity and citation hygiene

## Objective

Add cheap, deterministic lint checks for README rules that hold today but are unenforced. Base plan findings: 6, 9, 12, 16, 19.

## Files

- Create: none
- Modify: `scripts/lint.sh`, `README.md` (Development checks, check families)
- Remove: none

## Steps

1. **Identity attributes** (rule 9, Semantic XML grammar). In the first awk program of `check_xml_grammar`, next to the existing `rule` and `template` tests, add for tags outside `<input>`:
   - `step`: `tok !~ / id="[0-9]+"/` → print "`<step>` without a numeric id at line NR".
   - `case`: requires ` id="..."`. `response`: requires ` type="..."`. `signal` and `state`: require ` code="..."`. Print "`<name>` without its id/type/code at line NR".

   Findings flow through the existing `xml grammar:` warn loop. No new function.
2. **No rule numbers in skills or USER-AGENTS** (rule 9). New `check_rule_anchor_citations`: for `USER-AGENTS.md` and each `skills/*/SKILL.md`, `grep -nE '\b[Rr]ules? [0-9]'`. Any hit → `warn "cites a README rule number instead of a section anchor (rule 9): $f:$line"`; otherwise `ok`.
3. **No sub-headings in USER-AGENTS** (rule 3). New check, either in `check_instructions_cap` or as `check_instructions_headings`: `grep -nE '^#{2,} ' USER-AGENTS.md` → warn on a hit.
4. **Description names its slash command** (rule 6). In `check_skill_description_content`, after the Impact/Agent test, require `"/$name"` (directory basename) inside the folded description value. Warn "skill description does not name /$name (rule 6)".
5. **Vocabulary parity** (rule 9, Semantic XML grammar). New `check_vocab_parity`:
   - `readme`: in `README.md`, take the lines after the one starting `Vocabulary.` up to the next heading, keep only table rows starting with `` | `< ``, extract every `` `<name `` token, and produce a sorted unique list.
   - `lint`: `printf '%s\n' $XML_VOCAB | sort -u`.
   - If they differ, warn once per tag with the side it is missing from; otherwise `ok "README vocabulary table matches XML_VOCAB (N tags)"`.

   Use only awk, grep, sed, sort, and tr.
6. Call the new checks from the Run block, next to `check_xml_grammar`.
7. **`lint.sh` usage heredoc:** extend "xml grammar" with the identity attributes, and add the entries "rule anchors (rule 9)", "instructions headings (rule 3)", and "vocabulary parity (rule 9)". Add "names /name" to "skill description".
8. **README check families:** extend **xml grammar** ("every `<step>` has a numeric `id`, and `<case>`, `<response>`, `<signal>`, `<state>` carry `id`, `type`, or `code`"). Extend **skill description** ("names `/<name>`"). Add bullets:
   - "**rule anchors** — no `SKILL.md` or `USER-AGENTS.md` cites a README rule number (rule 9)";
   - "**instructions headings** — `USER-AGENTS.md` has no `##` sub-heading (rule 3)";
   - "**vocabulary parity** — the Semantic XML grammar table and `XML_VOCAB` list the same tags (rule 9)".
9. Keep new code bash 3.2 compatible and shellcheck-clean.

## Tests

Follow the verification protocol in the base plan, with declared files `scripts/lint.sh` and `README.md`. Before committing, run the read-only `skills/` versus HEAD comparison from the base plan risks.

- Scratch clone, clean tree: `scripts/lint.sh` exits 0 with 0 warnings, and the new `ok` lines appear (grep for "vocabulary table matches", "rule number", "has no ##", "names /").
- Negative probes, each on a fresh scratch clone and never in the real tree. Each must exit 2 with the named warning:
  1. In `$V/skills/az-ai-tools/SKILL.md`, `<step id="1"` → `<step id="one"`: "without a numeric id".
  2. In `$V/USER-AGENTS.md`, delete ` type="stop"` from `<response>`: identity warning.
  3. Append " (rule 9)" to a prose line in `$V/skills/dev-ai-tools/SKILL.md`: rule anchors warning.
  4. Insert `## Notes` before `<user_instructions>` in `$V/USER-AGENTS.md`: headings warning.
  5. Remove "Use for /gc-ai-tools." from `$V/skills/gc-ai-tools/SKILL.md`: names /name warning.
  6. Drop `` `<boundaries>` `` from the README table in `$V/README.md`: parity warning naming `boundaries`.
  7. Add `foo` to `XML_VOCAB` in `$V/scripts/lint.sh`: parity warning naming `foo`.
- `scripts/test.sh` exits 0. shellcheck shows only SC1071.

## Acceptance criteria

- The five checks exist, run in the default lint run, and pass on the committed tree.
- Each negative probe produces its warning and exit 2.
- README check families and the `lint.sh` usage describe exactly the new checks and cite the rules above.
- No change under `skills/`. No new dependency beyond the tools `lint.sh` already uses.

## Commit message

```
feat(lint): check grammar identity attributes, rule anchors, and vocabulary parity
```

## Dependencies

Stages 1 and 2. The vocabulary table layout is final after stage 1, and the check-family text after stage 2.

## Implementation log

Skills-vs-HEAD check before committing: `git show HEAD:<p> | cmp` over every
tracked `skills/` path showed no diff — the working tree matched HEAD, so no
scratch copy of working-tree skills was needed.

Checks added to `scripts/lint.sh`:

- Identity attributes folded into `check_xml_grammar`'s awk program: `<step>`
  requires a numeric `id`; `<case>` requires `id`; `<response>` requires
  `type`; `<signal>` and `<state>` require `code`. No new function.
- `check_rule_anchor_citations` (rule 9): `grep -nE '\b[Rr]ules? [0-9]'` over
  `USER-AGENTS.md` and every `skills/*/SKILL.md`.
- `check_instructions_headings` (rule 3): `grep -nE '^#{2,} '` over
  `USER-AGENTS.md`.
- `check_skill_description_content` extended to also require `/$name`
  (directory basename) inside the folded description.
- `check_vocab_parity` (rule 9): compares the README vocabulary table's
  backticked tag names against `XML_VOCAB` using only awk/grep/sed/sort/tr.
- Run block: added `check_instructions_headings`, `check_vocab_parity`, and
  `check_rule_anchor_citations` next to `check_xml_grammar`.
- Usage heredoc extended: "xml grammar" entry documents the identity
  attributes; "skill description" documents `/<name>`; new entries
  "instructions headings", "vocabulary parity", "rule anchors".
- README Development checks: extended **xml grammar** and **skill
  description** bullets; added **rule anchors**, **instructions headings**,
  **vocabulary parity** bullets.

Verification (scratch clones of `plan/readme-ruleset-sync`, declared files
`scripts/lint.sh` and `README.md`, per the base plan's execution note):

- Clean scratch clone: `lint.sh` exit 0, 390 ok, 1 skipped, 0 warnings; all
  new `ok` lines present ("skill description names /<name>", "USER-AGENTS.md
  has no ## sub-heading", "README vocabulary table matches XML_VOCAB (40
  tags)", "cites no README rule number").
- `test.sh`: exit 0, 305 ok, 0 skipped, 0 warnings (matches baseline).
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh
  scripts/*.sh scripts/test/*.sh`: exit 1, SC1071 on `install-zsh.sh` only
  (matches baseline; not a stage-3 regression).

Negative probes, each on its own fresh scratch clone, edit applied then
committed:

1. `<step id="1"` → `<step id="one"` in `skills/az-ai-tools/SKILL.md`: exit
   2, `xml grammar: <step> without a numeric id at line 8`.
2. Dropped ` type="stop"` from the `<response>` in `USER-AGENTS.md`: exit 2,
   `xml grammar: <response> without its type at line 43`.
3. Appended " (rule 9)" to the `<overview>` line in
   `skills/dev-ai-tools/SKILL.md`: exit 2, one warning, `cites a README rule
   number instead of a section anchor (rule 9): .../SKILL.md:13`.
4. Inserted `## Notes` before `<user_instructions>` in `USER-AGENTS.md`: exit
   2, one warning, `USER-AGENTS.md has a ## sub-heading at line 7 (rule 3)`.
5. Removed "Use for /gc-ai-tools." from `skills/gc-ai-tools/SKILL.md`'s
   description: exit 2, one warning, `skill description does not name
   /gc-ai-tools (rule 6)`.
6. Dropped `` `<boundaries>` `` from the README vocabulary table: exit 2, one
   warning, `vocabulary parity: boundaries missing from README table (rule
   9)`.
7. Added `foo` to `XML_VOCAB` in `scripts/lint.sh`: exit 2, one warning,
   `vocabulary parity: foo missing from README table (rule 9)`.

Each probe produced exactly one warning (its named one) and no others.

WIP-skills check (plan risk "parallel skills work"): on a separate scratch
clone, replaced `skills/` with the provided WIP snapshot
(`wip-skills-snapshot/skills`, the same nine skill directories) and
committed it, then ran `lint.sh` unmodified otherwise. Result: exit 0, 421
ok, 1 skipped, 0 warnings — none of the five new checks (identity
attributes, rule anchors, instructions headings, `/name` in description,
vocabulary parity) fired against the WIP content. No finding to report; no
skill file was touched.

### Coordinator review (R1)

Correction tasks (portability; existing lint.sh uses `\t` only inside awk):

1. `check_vocab_parity`: replace `sed 's/$/\tR/'` and `sed 's/$/\tL/'` (GNU-only `\t` in sed; BSD sed emits a literal `t`) with awk tagging, e.g. `awk '{ print $0 "\tR" }'`, or restructure without a tab separator.
2. `check_rule_anchor_citations`: replace the GNU `\b` in `grep -nE '\b[Rr]ules? [0-9]'` with a portable boundary such as `(^|[^A-Za-z])[Rr]ules? [0-9]`.
3. Re-run the clean-tree lint and probes 3, 6, and 7; confirm results unchanged.

#### R1 applied

Both correction tasks applied to `scripts/lint.sh`:

- `check_vocab_parity`: the `sed 's/$/\tR/'` / `sed 's/$/\tL/'` tagging step
  replaced with `awk '{ print $0 "\tR" }'` / `awk '{ print $0 "\tL" }'`
  (portable; the existing consumer awk still splits on the same literal tab).
- `check_rule_anchor_citations`: `grep -nE '\b[Rr]ules? [0-9]'` replaced with
  `grep -nE '(^|[^A-Za-z])[Rr]ules? [0-9]'` (portable word boundary).

Re-verification (fresh scratch clones of `plan/readme-ruleset-sync`, declared
files `scripts/lint.sh` and `README.md`):

- Clean scratch clone: `lint.sh` exit 0, 390 ok, 1 skipped, 0 warnings;
  "README vocabulary table matches XML_VOCAB (40 tags)" and "cites no README
  rule number (rule 9)" ok lines present for `USER-AGENTS.md` and every
  `skills/*/SKILL.md`. `test.sh` exit 0. `shellcheck -x -P scripts/shell -P
  scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`: exit 1,
  SC1071 on `install-zsh.sh` only.
- Probe 3 (appended " (rule 9)" to the `<overview>` prose line in
  `skills/dev-ai-tools/SKILL.md`): exit 2, one warning, `cites a README rule
  number instead of a section anchor (rule 9):
  .../skills/dev-ai-tools/SKILL.md:15`. Unchanged from before R1.
- Probe 3 extra check: inserted a new line "Rule 9 applies." (rule number at
  the very start of the line, no preceding character) into the same file:
  exit 2, one warning, `.../skills/dev-ai-tools/SKILL.md:16` — confirms the
  `(^|[^A-Za-z])` boundary still matches a line-initial "Rule 9".
- Probe 6 (dropped `` `<boundaries>` `` from the README vocabulary table):
  exit 2, one warning, `vocabulary parity: boundaries missing from README
  table (rule 9)`. Unchanged from before R1.
- Probe 7 (added `foo` to `XML_VOCAB` in `scripts/lint.sh`): exit 2, one
  warning, `vocabulary parity: foo missing from README table (rule 9)`.
  Unchanged from before R1.

Each probe produced exactly one warning (its named one) and no others. No
change made under `skills/`; only `scripts/lint.sh` was edited (plus this
plan file and the base plan Status table).
