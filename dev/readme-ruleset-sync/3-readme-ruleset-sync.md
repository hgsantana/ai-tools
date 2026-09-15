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
