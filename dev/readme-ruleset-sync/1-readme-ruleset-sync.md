# Stage 1: Rules text matches the tree

## Objective

Make the Repository rules and the Semantic XML grammar describe the committed tree. Base plan findings: 1, 6, 7, 8, 10, 11, 13, 14, 15, 17, 18, 20, 21, 22, 24, 25, 26, 27. No rule number changes.

## Files

- Create: none
- Modify: `README.md` (Overview item 3, rules 3, 4, 6, 7, 9, 11, 20, 21, 23, 24, 25, Semantic XML grammar)
- Remove: none

## Steps

Keep rule 8 concision. The texts below are drafts: wording may be tightened, but not their content.

1. Overview item 3: `(rule 2)` → `(rule 3)`.
2. Rule 3, first two sentences, become: "`USER-AGENTS.md` is an installation artifact for user-wide harness instructions, not this repository's rule file. After a title and a short preamble, its body is semantic XML under `<user_instructions>` ([Semantic XML grammar](#semantic-xml-grammar)) with no markdown sub-headings, and every internal cross-reference is a deterministic XML tag reference." The rest of rule 3 is unchanged.
3. Rule 4: replace "Change the version only in the commit or merge that lands the change on `master`." with "Every pull request that changes `skills/`, `scripts/`, or `USER-AGENTS.md` changes the version against its base branch; stacked pull requests each bump once." Apply this only if open question 2 is not answered otherwise. If the user picks the CI alternative, leave rule 4 unchanged.
4. Rule 6, part (3), becomes: "`Agent:` with `session` when the skill never spawns implementers, or `session + implementer (model asked once)` exactly when its body defines `<implementer_job>` and a `<template executor="implementer">`, which only `vibe-ai-tools` and `campaign-ai-tools` may do; the skill offer's Execution column shows this value."
5. Rule 7: delete ", and file basename" so that the rule lists skill directory, slash command, and frontmatter `name:`.
6. Rule 9: after "every `<template>` names its `role` and `executor`." insert "A skill with a `<template>` cites USER-AGENTS `<execution_protocol>` for spawning and never restates the harness native subagent API list."
7. Rule 11, last sentence: "`USER-AGENTS.md` surfaces it **before** execution in the skill offer table, whose Description column comes from `Impact:` and Execution column from `Agent:`."
8. Grammar, Executors bullet: add to the list "the payload rule (populated payload and file paths, never conversation context)" and "the spawn announcement".
9. Grammar, Protocol bullet, becomes: "**Protocol** is a block, not prose: return tokens live in `<return_protocol>`/`<signal>` and stage states in `<status_protocol>`/`<state>`. A template whose outcome the caller branches on ends with one cited `<signal>`; any other template returns a one-line outcome with paths."
10. Vocabulary table:
    - Remove `` / `<step id name>` `` from the `<overview>` row.
    - Add the row `` | `<step id name>` | all | one numbered workflow step; `name` optional (USER-AGENTS `<skill_offer>` omits it) | ``.
    - Change `` `<template role>` `` to `` `<template role executor>` ``.
    - Keep the set of tag names identical: 40 tags, still equal to `XML_VOCAB`.
11. Rule 20: replace "Every mutating script supports `--dry-run`." with "Every mutating process script (install, remove, update) supports `--dry-run`; the bootstrap scripts only clone, then pass their arguments to `install.sh`."
12. Rule 21 becomes: "Entry-point scripts (`scripts/*.sh`, `scripts/shell/*.sh`) are committed executable; case files under `scripts/test/` are sourced and are not. `.gitattributes` pins everything under `scripts/` to LF."
13. Rule 23: replace "records the named branch it analyzes as the plan's base, requests the host harness's best planning capability or mode, and aligns" with "records the checked-out branch it analyzes as the plan's base and aligns".
14. Rule 24:
    - After the Task-mode clause, add "Queue mode lists unfinished base plans, proposes an order, and runs the accepted plans in turn." and change "both modes run unattended" to "every mode runs unattended". Keep "update any documentation the step made stale" (open question 4).
    - Before the campaign sentence, add: "`vibe-ai-tools` plans interactively through `plan-ai-tools`, asks the implementer-model question once the plan is on disk, then runs this sequence with implementers writing stage code, logging in-scope decisions to `dev/<slug>/vibe-decisions.md`."
    - After the campaign sentence, add: "The campaign records the implementer model in `dev/improve/<campaign>/campaign.md` and reuses it on resume. A pass that cannot spawn its implementer or a default worker never does that work itself and ends blocked, so USER-AGENTS `spawn-fallback` never applies inside a pass. The campaign stops after a blocked pass or two consecutive planning passes with nothing to plan."
15. Rule 25: delete "; outside a Git repository, use `$HOME/.ai-tools-plans/tmp/`" (the sentence ends after "created if absent").

## Tests

Follow the verification protocol in the base plan, with declared files `README.md`.

- `grep -nE 'file basename|best planning|ai-tools-plans|lands the change on .master' README.md` prints nothing. The last pattern applies only if rule 4 was changed.
- `grep -c '^[0-9]\+\. ' <(awk '/^## Repository rules/{p=1;next} /^## /{p=0} p' README.md)` prints 25.
- The vocabulary set is unchanged:
  `awk '/^Vocabulary\./{p=1;next} p&&/^#/{exit} p&&/^\| .</' README.md | grep -oE '.<[a-z_]+' | tr -d '\`<' | sort -u | wc -l` prints 40, and `diff` against the sorted `XML_VOCAB` words is empty.
- Scratch clone: `scripts/lint.sh` exits 0 with 0 warnings; `scripts/test.sh` exits 0.

## Acceptance criteria

- Every action in base plan findings 1, 6-8, 10, 11, 13-15, 17, 18, 20-22, 24-27 is present in README.
- Rules 1-25 keep their numbers and topics. No other section changes.
- The README vocabulary table still lists exactly the `XML_VOCAB` tags.
- No file outside `README.md` changes. Nothing under `skills/` is touched.

## Commit message

```
docs(readme): align repository rules with the session-model tree
```

## Dependencies

None.

## Implementation log
