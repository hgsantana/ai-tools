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
