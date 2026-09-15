# Stage 5: Documentation without agents

## Objective

The remaining documentation (README overview and rules, `docs/USAGE.md`, `ROADMAP.md`) describes a skills-and-instructions toolkit with no agents, wrappers, model pins, or dispatch to workers. The README rule list drops the agent-only rules and is renumbered, and every rule-number citation in the repository follows. The version is bumped once. The repository-wide agent grep from the base plan passes.

## Files

- Create: none
- Modify:
  - `README.md`
  - `docs/USAGE.md`
  - `ROADMAP.md`
  - `.gitattributes`: rule citation only
  - `scripts/lint.sh`: rule citations in comments and usage text only
  - `scripts/test.sh`: rule citations only
  - `scripts/test/install.sh`, `scripts/test/update.sh`, `scripts/test/remove.sh`, `scripts/test/reinstall.sh`, `scripts/test/verify.sh`, `scripts/test/smoke.sh`: rule citations in comments only
- Remove: none

## Steps

### README.md, top and overview

1. Version line: `0.0.47-ALPHA` → `0.0.48-ALPHA`.
2. Overview first sentence: "A toolkit of **skills** and **user-wide instructions** for Grok Build, Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity, and Cursor."
3. "How it operates":
   1. "**A harness toolkit.** Skills and `USER-AGENTS.md` are what the supported harnesses load after install."
   2. "**Machine-local install.** `$HOME/.ai-tools` is the only supported clone. Installed instructions and skills reference that path."
   3. Unchanged.
   4. "**Session-first skills.** Skills provide session-directed workflows in semantic XML. The host session executes them, interacts with the user, and coordinates git delivery."
   5. "**Frontmatter only in the host session.** Harnesses keep skill `name` and `description` in the skill list without loading the body. The host session offers skills from that in-memory description and reads the body only when it runs the skill."
4. Contents table:
   - `USER-AGENTS.md` row: "…Workflows live in skills" (drop "and agent bases").
   - `docs/USAGE.md` row: "Harness-agnostic invocation guide for every shipped skill".
   - `skills/` row: "Each `skills/<name>/SKILL.md` has a semantic XML body. Harnesses list frontmatter; the session executes the workflow" (drop the count and the worker-dispatch clause).
5. Quick start, last line: "…see the harness-agnostic [usage guide](docs/USAGE.md) for skill prompts."

### README.md, rules

6. Delete old rules 5, 6, 8, 10, 11, 12, and 13.
7. Rewrite the kept rules. Numbers below are the old ones; the renumbering happens in step 8.
   - **3**: "…It is structured entirely in semantic XML tags under `<user_instructions>` ([Semantic XML grammar](#semantic-xml-grammar)) without markdown sub-headings, using deterministic XML tag names for all internal cross-references…". Drop the inline tag list; keep the cap sentences.
   - **7**: drop both clauses about delivered work and `Agent:`.
     - Clause 1: "the host session executes the `<session_workflow>` and, on delegated steps, spawns the worker … `<dispatch_templates>`" becomes "the host session executes the `<session_workflow>`".
     - Clause 2: delete "the description's `Agent:` names the primary worker".
     - "Descriptions contain three parts" becomes "Descriptions contain two parts".
     - Keep the rest.
   - **9**: the description "states in order: (1) what the skill does and when to use it, including `/name`; (2) `Impact:` plus what can be billed, deleted, committed, pushed, or otherwise changed—or that impact is absent." Delete part (3).
   - **14**: "Every installed skill directory, slash command, frontmatter `name:`, and file basename ends in `-ai-tools`; bare names such as `plan` and `az` remain uninstalled."
   - **16**: "Skills and `USER-AGENTS.md` state what to do in the Semantic XML grammar: … every `<rule>` has an `id`, and every `<template>` names its `role`…".
   - **18**: delete the last sentence (stake disclaimers from agent bases).
   - **19**: "Install global instructions and skill directories as **physical copies**…".
   - **23**: "…user-level, never inside a project. Installed instructions and skills reference it; any other path breaks them."
   - **32**: "This binds every skill and `USER-AGENTS.md`."
8. Renumber. The list is continuous across the "Source of truth", "Structure and authoring", "Installation contract", "Script contract", and "Work state and reporting" subsections. Old → new:

   | old | 1 | 2 | 3 | 4 | 7 | 9 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 | 32 |
   |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
   | new | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 |

   The first item of each subsection carries its new number: Structure and authoring starts at 5, Installation contract at 12, Script contract at 18, and Work state and reporting at 22.
9. Apply the mapping to every citation of an old rule number. Examples:
   - "rule 9" → "rule 6"
   - "rules 25–28" → "rules 18–21"
   - "rules 19–24" → "rules 12–17"
   - "rules 19–27" → "rules 12–20"
   - "rules 7–9" → "rules 5–6"
   - "Rule 32" → "Rule 25"
   - "rule 29" → "rule 22"
   - "rules 20, 22" → "rules 13, 15"
   - "(rule 23)" → "(rule 16)"

   Scope:
   - `README.md`: rules text, Semantic XML grammar, Installation contract, Scripts, Development checks, Safety rules, Installation, Removal, Troubleshooting, and License.
   - `.gitattributes`: rule 28 → 21.
   - `scripts/lint.sh`:
     - usage and comments cite 3, 4, 7, 9, 14, 16, 25–27, 28, and 29, which become 3, 4, 5, 6, 7, 9, 18–20, 21, and 22.
     - "rules 7, 9" → "rules 5, 6"
   - `scripts/test.sh`: "rules 25-27" → "rules 18-20".
   - `scripts/test/*.sh`:
     - "rules 19-24, 27" → "rules 12-17, 20"
     - "rules 20-22, 27" → "rules 13-15, 20"
     - "rules 20-22, 24, 27" → "rules 13-15, 17, 20"
     - "rules 19-27" → "rules 12-20"
     - "rules 20-21" → "rules 13-14"
     - "Rules 20, 22, 25" → "Rules 13, 15, 18"
     - "Rule 19/20/24/27" → "Rule 12/13/17/20"
     - "rule 22" → "rule 15"
     - "rule 27" → "rule 20"
     - "rule 20" → "rule 13"
   - `ROADMAP.md` "Rule 4" stays 4.
10. Development checks, closing paragraph: "the caps above (rules 3, 6)".

### docs/USAGE.md

11. Intro: "This guide is harness-agnostic. Skills are the user entry points."
12. "Invocation and gate":
    - "It names each option's impact, then offers the relevant skill, **run it here**, and **something else**…" (drop "and that choosing it dispatches the agent named in `Agent:`").
    - "Choosing a skill runs its `<session_workflow>`, which coordinates delivery." (drop the worker and `<template>` clause).
13. Skills table: delete the `/models-ai-tools` row (open question 5).
14. "Delivery workflows", `/dev-ai-tools` paragraph: "It runs edits and tests, commits every accepted stage…".
15. "Continuous improvement campaign": rewrite the chain paragraph and steps 1–4 without agent names:
    - "Each iteration chains planning and execution workflows in fresh contexts while keeping the orchestrating session lean:"
    1. "A fresh planning pass evaluates the campaign branch and runs `plan-ai-tools`, saving one multi-stage plan under `dev/<slug>/`. The initial gate pre-authorizes it to resolve and accept its recommendations according to the user's campaign priorities."
    2. "A separate fresh execution pass runs `dev-ai-tools` against that accepted plan."
    3. "The execution pass judges diffs and test evidence, commits every accepted stage on `improve/<campaign>`, archives the plan, and updates `dev/improve/<campaign>/campaign.md` and `decisions.md`."
    4. "The orchestrating session starts the cycle again with a new planning pass. No planning context or conversation history is reused between passes."

    The following paragraph: "The orchestrating session only starts the planning and execution passes and routes their short statuses, keeping its context minimal. Planning decides in-scope questions under the initial gate…". Keep the rest of that paragraph.
16. "Maintenance and model operations": the heading becomes "Maintenance"; delete the `/models-ai-tools` paragraph.
17. Delete the whole "## Agents" section.

### ROADMAP.md (open question 6)

18. Delete story 13 (its table row and "### 13. Cost visibility in the dispatch ledger").
19. Story 4: "`verify` is a first-class read-only process with a script, while update and removal also have slash commands. Add a `verify-ai-tools` skill that runs `verify` and maps each finding to the matching README Troubleshooting entry: dangling links and stale copies to Update, missing skills to a harness restart. Route: `/vibe-ai-tools`."
20. Story 9: "`dev-ai-tools` defines recovery for an interrupted run through its dispatch ledger, snapshot-based liveness, and intake audit of orphaned `W` stages…" (replace "subagent" with "run"; keep the rest).
21. Story 11: "Several skills consume untrusted input: `gh-ai-tools` reads issue and pull request bodies, the cloud skills read metadata and tags, and any workflow may read a fetched page. Expand…".
22. Story 12: "Adding a harness requires coordinated edits: its skills root and instructions destination in `scripts/shell/lib.sh`, detection, the Supported harnesses table, installation steps, test fixtures, and any newly tighter constraint. Consolidate these requirements into an ordered checklist, and have the linter verify that every harness key in `lib.sh` has a Supported harnesses entry. Route: `/vibe-ai-tools`."

## Tests

- The repository-wide agent grep from `0-remove-agents.md` ("Final acceptance") prints nothing, and the `test ! -e …` line succeeds.
- `grep -nE '^[0-9]+\. ' README.md` shows the rule items numbered 1–25 in order, with no gaps or repeats inside the rules sections. Installation, Removal, and Update step lists run 1–5, 1–6, and 1–5.
- Citation audit: `grep -rnoiE 'rules? [0-9]+([–-][0-9]+)?(, [0-9]+)*' README.md ROADMAP.md .gitattributes scripts`. Check every hit against the mapping and record the checked list in the Implementation log. No citation may name a number above 25.
- `grep -n 'Version 0.0.48-ALPHA' README.md` hits line 3.
- Every README anchor link still resolves: `grep -oE '\]\(#[a-z0-9-]+\)' README.md docs/USAGE.md | sort -u`. Each anchor matches an existing heading. `#model-selection-and-wrapper-authoring` and `#choosing-the-models` must not appear.
- `scripts/lint.sh` exits 0. `scripts/lint.sh --base master` also exits 0, which confirms the version bump.
- `scripts/test.sh` exits 0.
- The CI shellcheck command reports only the pre-existing `SC1071`.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds.

## Acceptance criteria

- [ ] README describes skills and instructions only: no agents, wrappers, `MODELS.csv`, model pins, Grok model block, subagent contract, or worker dispatch
- [ ] Rules are numbered 1–25 with no gaps, and every rule-number citation in README.md, ROADMAP.md, .gitattributes, and scripts/ points to the intended rule
- [ ] `docs/USAGE.md` has no Agents section, no `/models-ai-tools` entry, and no agent names
- [ ] `ROADMAP.md` has no agent, wrapper, or `MODELS.csv` terms; story 13 removed
- [ ] README version is `0.0.48-ALPHA`
- [ ] Repository-wide agent grep passes; hits appear only in `skills/`, `USER-AGENTS.md`, and `dev/`
- [ ] `scripts/lint.sh` (with and without `--base master`) and `scripts/test.sh` exit 0; shellcheck shows no new finding
- [ ] `skills/` and `USER-AGENTS.md` unchanged

## Commit message

`docs: remove agents from README, usage guide, and roadmap`

## Dependencies

- Requires stages: 4

## Implementation log

### README/rules/scripts part (steps 1-10, plus citations in .gitattributes and scripts/)

Scope covered: `README.md` (version, overview, "How it operates", Contents, Quick start, the full rule list with deletions/rewrites/renumbering, Semantic XML grammar intro citation, Scripts, Development checks, Safety rules, Installation, Removal, Update, Troubleshooting, License), `.gitattributes`, `scripts/lint.sh`, `scripts/test.sh`, `scripts/test/install.sh`, `scripts/test/verify.sh`, `scripts/test/smoke.sh`, `scripts/test/remove.sh`, `scripts/test/reinstall.sh`, `scripts/test/update.sh`. Did not touch `docs/USAGE.md` or `ROADMAP.md` (parallel implementer's part).

**Steps 1-5 (top of README).** Version bumped to `0.0.48-ALPHA` (line 3). Overview first sentence dropped "three harness-agnostic agents". "How it operates" items 1, 2, 4, 5 rewritten per the stage file (item 3 left verbatim). Contents table: `USER-AGENTS.md` row dropped "and agent bases"; `docs/USAGE.md` row dropped "and the three spawn-only agents"; `skills/` row dropped the "Ten skills" count and the "dispatches workers via templates" clause; `scripts/` row's rule citation renumbered (see mapping below). Quick start's last line dropped "and agent names".

**Steps 6-8 (rule deletions and renumbering).** Deleted old rules 5, 6, 8, 10, 11, 12, 13 (agent bases/wrappers/spawning/MODELS.csv/Antigravity subagent-tier rules). Rewrote old rules 3, 7, 9, 14, 16, 17(citation only), 18, 23, 32 per the stage file's verbatim text. Renumbered the remaining rules continuously 1-25 using the table in step 8 (old->new: 1-4 unchanged, 7->5, 9->6, 14->7, 15->8, 16->9, 17->10, 18->11, 19->12, 20->13, 21->14, 22->15, 23->16, 24->17, 25->18, 26->19, 27->20, 28->21, 29->22, 30->23, 31->24, 32->25). Verified with `grep -nE '^[0-9]+\. ' README.md`: rules run 1-25 with no gaps or repeats; Installation/Removal/Update step lists still run 1-5, 1-6, 1-5 (their own independent numbering, unaffected).

**Rule-3 note beyond the stage file's explicit text:** rule 3 (old and new) also listed the inline USER-AGENTS.md tag set including `<dispatch_protocol>` and `<agents>`. Per the stage file's instruction to drop the inline tag list and keep the cap sentences, this removed those two flagged tokens along with the rest of the list — required for the Final acceptance grep to pass on this rule, not called out separately in the stage file's rule-7 vs rule-3 step text but implied by "drop the inline tag list".

**Step 9 (citation mapping applied everywhere).** Full old->new mapping used for every rule-number citation: 1->1, 2->2, 3->3, 4->4, 7->5, 9->6, 14->7, 15->8, 16->9, 17->10, 18->11, 19->12, 20->13, 21->14, 22->15, 23->16, 24->17, 25->18, 26->19, 27->20, 28->21, 29->22, 30->23, 31->24, 32->25 (deleted: 5, 6, 8, 10, 11, 12, 13 — no citations to those survive).

Checked citation list (file:line, old -> new; "unchanged" = same number before and after, still verified against the mapping):

- `.gitattributes:1` rule 28 -> rule 21
- `README.md:3` rule 4 unchanged
- `README.md:15` rule 2 unchanged
- `README.md:26` rules 25-28 -> rules 18-21
- `README.md:53` rules 25-28 -> rules 18-21
- `README.md:60` rule 9 -> rule 6 (x2), rule 15 -> rule 8
- `README.md:61` rule 9 -> rule 6 (description part-3 deleted)
- `README.md:65` Rule 32 -> Rule 25
- `README.md:66` rule 9 -> rule 6
- `README.md:70` rule 16 -> rule 9
- `README.md:118` rule 29 -> rule 22 (x2)
- `README.md:130` rules 25-27 -> rules 18-20
- `README.md:139` rules 25-27 -> rules 18-20
- `README.md:148-158` rule 14->7, 9->6, 9->6, 7->5, 3 unchanged + 9->6, 28->21, 29->22 (one bullet each, in file order)
- `README.md:155-157` rule 16 -> rule 9 (x3)
- `README.md:158` rule 4 unchanged
- `README.md:162` rules 3, 9 -> rules 3, 6
- `README.md:164` rules 25-27 -> rules 18-20; rules 19-27 -> rules 12-20
- `README.md:173-179` rule 19->12, 20->13, 21->14, 22->15, 24->17, 27->20, 27->20
- `README.md:183` rules 19-24 -> rules 12-17
- `README.md:185` rules 20, 22 -> rules 13, 15
- `README.md:187` rule 21 -> rule 14
- `README.md:188` rule 24 -> rule 17
- `README.md:209` rule 3 unchanged
- `README.md:225` rule 23 -> rule 16
- `README.md:228` rules 7-9 -> rules 5-6 (plus the carry-over sentence rewrite, see below)
- `README.md:229` rule 3 unchanged
- `README.md:244` rule 21 -> rule 14
- `README.md:245` rule 4 unchanged
- `README.md:246` rule 24 -> rule 17
- `README.md:275` rule 23 -> rule 16
- `README.md:290` rule 3 unchanged, rule 15 -> rule 8
- `scripts/lint.sh:3` rules 25-27 -> rules 18-20
- `scripts/lint.sh:24-25` rules 25-27 -> rules 18-20 (a citation split across two lines by the help-text word wrap; not visible to a single-line grep — found by an explicit cross-line scan and fixed in the same pass)
- `scripts/lint.sh:27,29,33,38,39,41,43,49,50,54,58,60` (help text) rule 14->7, 9->6, 9->6, 7->5, 3 unchanged, 28->21, 28->21, 4 unchanged, 29->22, 16->9 (x3)
- `scripts/lint.sh:119,134,174,298,312,316,361,407,565,573,577` (comments) rule 14->7, 9->6, rules 7,9->5,6, 9->6 (x3), 28->21, 16->9, 29->22 (x2), 4 unchanged
- `scripts/test.sh:3,94` rules 25-27 -> rules 18-20 (both)
- `scripts/test/install.sh:2,14,38,59,93,119,132,151,169` rules 19-24,27 -> rules 12-17,20; Rule 19->12; Rule 20->13; Rules 20,22,25->13,15,18; Rule 20->13; Rule 24->17 (x2); Rule 27->20; Rule 19->12
- `scripts/test/verify.sh:2` rules 19-24,27 -> rules 12-17,20
- `scripts/test/smoke.sh:4` rules 19-27 -> rules 12-20
- `scripts/test/remove.sh:2,11,13` rules 20-22,24,27 -> rules 13-15,17,20; rule 22's -> rule 15's; rule 27 -> rule 20
- `scripts/test/reinstall.sh:2` rules 20-22,27 -> rules 13-15,20
- `scripts/test/update.sh:2,8,120,145,169` rules 20-22 and 27 -> rules 13-15 and 20; rule 27->20 (x2); rule 20->13; rules 20-21->13-14

No citation above 25 remains anywhere in `README.md`, `.gitattributes`, or `scripts/` (verified by a regex scan for any cited number outside 1-25: none found).

**Step 10.** Development checks closing paragraph: "the caps above (rules 3, 9)" -> "(rules 3, 6)" (`README.md:162`).

**Carry-over items (beyond the stage file's explicit step list, per the coordinator's brief).**

- README "Installation" step 4 (Skills): rewrote "The copy is for the dispatched agent; harnesses list frontmatter without the host session loading the body." -> "Harnesses list frontmatter; the host session reads the body only when it runs the skill." (`README.md:228`), alongside its rule citation.
- Rule 3 (now still rule 3): dropped the inline USER-AGENTS.md tag list (which included `<dispatch_protocol>` and `<agents>`), keeping only the cap sentences, per the stage file's rule-3 rewrite instruction.
- Old rule 16 (new rule 9): dropped "agent bases, contracts," and "and `agent`" from "every `<template>` names its `role` and `agent`".
- Old rule 32 (new rule 25): dropped "every agent base," from the closing sentence.
- Confirmed rule 31 (new 24, `campaign-ai-tools` description) needs no rewrite: "planner" there is a common noun ("a fresh planner writes...") with no `-ai-tools` suffix, so it does not match the acceptance grep's `(planner|implementer|mechanical)-ai-tools` term.
- Left the License paragraph's "dispatched work" (`README.md:285`) unchanged: "dispatch" is not one of the acceptance grep's flagged terms.
- Left the Semantic XML grammar's Vocabulary table and "References" bullet (`README.md:74,82-88`) unchanged: they accurately document the untouched `USER-AGENTS.md`/skills grammar, including its `<dispatch_protocol>`, `<agents>`, and `<worker name>` tags and the bare `USER-AGENTS` qualifier convention (confirmed still used verbatim in `skills/*/SKILL.md`, e.g. `` USER-AGENTS `<security_guardrails>` ``). None of these are among the four exceptions the base plan's Final acceptance grep explicitly strips before matching.

**Residual Final-acceptance-grep hits (documented, not fixed).** Running the base plan's exact "Final acceptance" grep (`0-remove-agents.md`) restricted to `README.md`, `.gitattributes`, `scripts/` after all edits above still reports two hits, both being the literal qualifier string `USER-AGENTS` (no `.md` extension) used by the Semantic XML grammar's reference syntax:

- `README.md:74,82-88` — the grammar's "References" bullet and the Vocabulary table's File column, describing the untouched `USER-AGENTS.md` file with its established bare-qualifier convention.
- `scripts/lint.sh:436` — the reference-resolver's `case` branch that maps the literal qualifier `USER-AGENTS` to the file path (implemented in stage 2, unrelated to stage 5's scope; a behavior change here is out of scope for this stage).

The base plan's grep already grants four exceptions for non-agent tokens that happen to match the `agents?` term (`AGENTS.md` filenames, `$HOME/.agents`, `` `<agents>` ``, the `XML_VOCAB=` line). The bare `USER-AGENTS` qualifier is structurally the same kind of false positive — it names the excluded, byte-identical `USER-AGENTS.md` file, not the three removed agents — but is not in that exception list. Rewriting it to `USER-AGENTS.md` would make the README's grammar documentation diverge from the actual, unchanged syntax used throughout `skills/*/SKILL.md` (confirmed still bare there), which is out of scope (skills stay byte-identical per decision 1). Flagging for the coordinator: either accept this as a fifth documented exception (in the same spirit as the existing four) or treat it as a known base-plan gap; no README/`scripts/` change was made to force a literal zero-hit run.

**Verification run.**

- `grep -nE '^[0-9]+\. ' README.md`: rules 1-25, no gaps/repeats; Installation 1-5, Removal 1-6, Update 1-5.
- Citation audit regex over `README.md .gitattributes scripts`: every hit checked against the mapping above; none above 25.
- README anchor check: every `](#...)` in `README.md`/`docs/USAGE.md` resolves to an existing heading; `#model-selection-and-wrapper-authoring` and `#choosing-the-models` do not appear.
- `bash scripts/lint.sh` -> exit 0, `340 ok, 1 skipped, 0 warnings` (1 skip is the version-bump check without `--base`, as expected).
- `bash scripts/lint.sh --base master` -> exit 2, `340 ok, 0 skipped, 1 warnings`, the single warning being the expected pre-commit version-bump WARN (`still 0.0.47-ALPHA, was 0.0.47-ALPHA`): this check reads `HEAD:README.md` via `git show`, and stage 5's changes are intentionally uncommitted per the "do not commit" constraint on this implementer. This will read `0.0.48-ALPHA` and pass once the coordinator commits stage 5 (matches how rule 4 is meant to be enforced: "Change the version only in the commit... that lands the change").
- `bash scripts/test.sh` -> exit 0, `307 ok, 0 skipped, 0 warnings` (same count as stage 4's log; unaffected by comment/prose-only edits).
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` -> only the pre-existing `SC1071` on `scripts/shell/install-zsh.sh`.
- `git diff --quiet master -- skills USER-AGENTS.md` -> succeeds (both byte-identical to master).

No files outside the declared list were modified. Did not commit, push, switch branches, or set the stage status (left for the coordinator, per instructions).

Parallel implementer notes (docs/USAGE.md and ROADMAP.md, steps 11-22), appended by the coordinator:

- Step 11: USAGE intro reduced to "Skills are the user entry points."
- Step 12: dropped the `Agent:` dispatch clause and the worker/`<template>` clause from "Invocation and gate".
- Step 13: removed the `/models-ai-tools` table row.
- Step 14: `/dev-ai-tools` paragraph reads "It runs edits and tests, commits every accepted stage…".
- Step 15: campaign chain rewritten around planning pass, execution pass, and orchestrating session.
- Step 16: heading "Maintenance and model operations" became "Maintenance"; `/models-ai-tools` paragraph deleted.
- Step 17: "## Agents" section deleted.
- Steps 18-22: ROADMAP story 13 (row and section) deleted; stories 4, 9, 11, and 12 rewritten without agent, wrapper, or `MODELS.csv` terms.
- Final acceptance grep restricted to both files printed nothing (exit 1). USAGE has no in-page anchors; ROADMAP's 7 story anchors resolve, with no dangling `#13-…`.

Coordinator acceptance note: the Final acceptance grep as originally written flagged the bare `USER-AGENTS` qualifier (README lines 74 and 82-88, `scripts/lint.sh` `xml_file_for`). It names the untouched `USER-AGENTS.md` and is used verbatim by untouched skills, so the base plan's grep now also strips `USER-AGENTS`. With that exception the grep prints nothing (exit 1), and the `test ! -e` line succeeds. Verifier evidence is in `dev/tmp/remove-agents-stage5-output.log`: lint 340 ok / 0 warnings; test.sh 307 ok; shellcheck only SC1071; skills, USER-AGENTS.md, and .github unchanged; version 0.0.48-ALPHA on line 3; all README anchors resolve; no removed anchors. The highest cited rule number is 25. `lint.sh --base master` is checked after the commit, because the version-bump check reads committed history.
