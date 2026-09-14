# Stage 2: Lint without agents

## Objective

`scripts/lint.sh` no longer checks agent bases, the subagent contract, harness wrappers, wrapper templates, `MODELS.csv` pins, Grok model rules, the skill description `Agent:` part, `<template agent="...">`, or the `Agent:` mention in `USER-AGENTS.md`. Agent-only XML vocabulary is removed. Structural skill validation stays:

- naming, frontmatter keys, name match
- description cap and "what + Impact"
- skill layout
- instructions cap, line endings, executable bits, no binaries, `dev/tmp` untracked
- XML grammar, references, placeholder parity, `<template role>`
- version bump

The README Development checks list and the Semantic XML grammar section change in the same commit. `agents/`, `MODELS.csv`, and the scripts under `scripts/shell/` are still present and unchanged in this stage.

## Files

- Create: none
- Modify:
  - `scripts/lint.sh`
  - `README.md`: only the "Semantic XML grammar" and "Development checks" sections
- Remove: none

## Steps

1. `scripts/lint.sh`, header comment and `usage()` text:
   - Delete these check entries: wrapper coverage, wrapper body, model parity, effort pinning, description parity, model row coverage, wrapper cap.
   - naming: "every skills/*/ directory ends in -ai-tools (rule 14)".
   - skill description: "…states what the skill does, then Impact: (rule 9)".
   - skill layout: "USER-AGENTS.md has <routing_gate>" (drop "and Agent:").
   - no binaries: "under skills/ and scripts/".
   - version bump: "when skills/, scripts/, or USER-AGENTS.md changed".
   - xml grammar: "every semantic-XML body (USER-AGENTS.md, SKILL.md) … and every <template> a role".
2. Delete the "Discovery" block (`harnesses`, `agent_names`, `wrapper_ext`, `wrapper_path`) and its comment. Keep `in_list`, and move it next to `ends_in_ai_tools` if the section header disappears.
3. Delete `toml_field_value`; after the steps below it has no caller.
4. Delete these functions and their section comments: `check_wrapper_coverage`, `check_agent_layout`, `canonical_body`, `wrapper_body_md`, `wrapper_body_toml`, `check_wrapper_body`, `check_model_parity`, `check_effort_pinning`, `check_description_parity`, `check_wrapper_templates`, `check_models_row_coverage`, `check_wrapper_cap`. Also delete the comment `# model_effort_for lives in scripts/shell/lib.sh next to model_for.`
5. `check_naming`: keep only the `skills/*/` directory loop, and drop now-unused locals.
6. `check_skill_layout`: delete the `grep -q 'Agent:'` block for `USER-AGENTS.md`. Keep the `<routing_gate>` check and everything else.
7. `check_skill_description_content`: require `Impact:` only.
   - The match becomes `*"Impact:"*`.
   - `before` is the text before `Impact:` and must be non-empty.
   - `impact` is the text after `Impact:`, trimmed, and must be non-empty. Do not strip or parse any later suffix.
   - Messages: ok `skill description has what + Impact: $f`; warn `skill description missing Impact: (rule 9): $f`.
   - Section comment: `rule 9: description states what it does, then Impact:`.
8. `check_no_binaries`: `git ls-files skills scripts`.
9. `XML_VOCAB`: remove `subagent_contract governance brief user_channel questions approvals stake_disclaimers reporting payload channel delegation agent_base identity role_workflow role_scope user_decisions assignment_rules execution_rules`. Keep `dispatch_protocol agents worker` (used by the untouched `USER-AGENTS.md`) and everything else.
10. `xml_files`: echo `USER-AGENTS.md` and every `skills/*/SKILL.md` only.
11. `xml_file_for`: keep `USER-AGENTS`; the `*-ai-tools` branch resolves only `skills/$1/SKILL.md`; drop the `SUBAGENT-CONTRACT` branch.
12. `check_xml_grammar`:
    - Drop the `agents` local and its `agent_names` call.
    - In the awk, keep the `<template> without role` finding and delete the `<template> without agent` finding.
    - Delete the loop that prints `template agent is a shipped agent` / `…is not a shipped agent`.
    - The ok message becomes `semantic XML balanced, in vocabulary, rules and templates addressable: $f` (unchanged wording is fine).
13. `check_version_bump`: the pathspec becomes `-- skills scripts USER-AGENTS.md`.
14. Run list at the bottom, final order: `check_naming`, `check_skill_frontmatter`, `check_skill_name_match`, `check_skill_layout`, `check_skill_description_cap`, `check_skill_description_content`, `check_instructions_cap`, `check_line_endings`, `check_executable_bits`, `check_no_binaries`, `check_dev_tmp_untracked`, `check_xml_grammar`, `check_version_bump`.
15. `README.md` "Semantic XML grammar":
    - Intro: "The semantic-XML bodies (`USER-AGENTS.md` and every `SKILL.md`) follow one grammar…".
    - References bullet: "Qualifiers are `USER-AGENTS` or a skill name."
    - Identity bullet: "every `<template>` carries a functional `role`" (drop "and the shipped `agent` that receives the payload").
    - Vocabulary table: delete the `<subagent_contract>`, contract sections, `<agent_base name role>`, and bases rows.
    - `<worker name>` meaning becomes "worker entry".
    - `<dispatch_templates>` row: `<template role>` instead of `<template role agent>`, meaning "the payload a template carries".
16. `README.md` "Development checks" check families:
    - Delete the wrapper coverage, wrapper body, model parity and effort pinning, description parity, and model row coverage bullets.
    - naming: "skill directories end in `-ai-tools` (rule 14)".
    - skill description: "…at most 500 characters and states what it does, then `Impact:` (rule 9)".
    - size caps: "`USER-AGENTS.md` at most 8,000 characters (rule 3), every skill `description` at most 500 (rule 9)".
    - xml grammar: "…and every `<template>` a `role`".
    - version bump: "a change under `skills/`, `scripts/`, or `USER-AGENTS.md`…".
    - Closing paragraph: "the two caps above (rules 3, 6)" becomes "the caps above (rules 3, 9)".
    - Keep the current (pre-renumbering) rule numbers in this stage; stage 5 renumbers.

## Tests

- `scripts/lint.sh` exits 0 with 0 warnings. No output line mentions `wrapper`, `MODELS.csv`, `model parity`, `agent base`, `subagent contract`, or `template agent`.
- `grep -nE 'agent_names|harnesses\(\)|wrapper|canonical_body|model_for|model_effort_for|category_for|MODEL_TABLE|SUBAGENT-CONTRACT|agent_base|toml_field_value' scripts/lint.sh` prints nothing.
- Negative probes. Each probe runs in its own disposable worktree (`git worktree add -q "$wt/t" HEAD`, edit, run `"$wt/t/scripts/lint.sh"`, `git worktree remove --force "$wt/t"`) and must exit 2 with the named finding:
  1. Delete `Impact:` from the description of `skills/az-ai-tools/SKILL.md`: `skill description missing Impact:`.
  2. Change one `<template role="` to `<template name="` in `skills/plan-ai-tools/SKILL.md`: `<template> without role`.
  3. Add `<bogus_tag></bogus_tag>` inside `<overview>` of `skills/gh-ai-tools/SKILL.md`: `tag outside the vocabulary <bogus_tag>`.
  4. Rename `skills/gc-ai-tools` to `skills/gc-tools` with `git mv`: `skill directory does not end in -ai-tools`.
  5. Add `<subagent_contract></subagent_contract>` inside `<overview>` of a skill: `tag outside the vocabulary <subagent_contract>`. This proves the pruning.
- `scripts/test.sh` exits 0. Tests do not source `lint.sh`, but `lib.sh` is unchanged and must still run.
- The CI shellcheck command reports only the pre-existing `SC1071`.
- `git diff --quiet master -- skills USER-AGENTS.md` succeeds.

## Acceptance criteria

- [ ] No lint check, helper, usage line, or comment in `scripts/lint.sh` concerns agents, wrappers, wrapper templates, `MODELS.csv`, Grok model pins, `Agent:`, or `<template agent>`
- [ ] Structural skill validation and XML grammar checks still fire (negative probes 1–5)
- [ ] `XML_VOCAB` holds no contract or agent-base tags, and the README vocabulary table matches it
- [ ] README Development checks lists exactly the checks `lint.sh` runs
- [ ] `scripts/lint.sh` and `scripts/test.sh` exit 0; shellcheck shows no new finding
- [ ] `skills/` and `USER-AGENTS.md` unchanged

## Commit message

`refactor(lint): drop agent, wrapper, and model pin checks`

## Dependencies

- Requires stages: 1

## Implementation log

Implemented in `scripts/lint.sh` and `README.md` ("Semantic XML grammar", "Development checks" sections only), per the Steps above:

- Deleted `check_wrapper_coverage`, `check_agent_layout`, `canonical_body`, `wrapper_body_md`, `wrapper_body_toml`, `check_wrapper_body`, `check_model_parity`, `check_effort_pinning`, `check_description_parity`, `check_wrapper_templates`, `check_models_row_coverage`, `check_wrapper_cap`, their section-header comments, and the `# model_effort_for lives in scripts/shell/lib.sh next to model_for.` comment.
- Deleted the Discovery block (`harnesses`, `agent_names`, `wrapper_ext`, `wrapper_path`) and `toml_field_value`; moved `in_list` next to `ends_in_ai_tools` under "Frontmatter helpers".
- Simplified `check_naming` to the `skills/*/` directory loop only.
- `check_skill_layout`: dropped the `Agent:` grep block for `USER-AGENTS.md`; kept `<routing_gate>`.
- `check_skill_description_content`: now requires `Impact:` only (dropped the `Agent:` clause and the `agent_names` lookup); messages are `skill description has what + Impact: $f` / `skill description missing Impact: (rule 9): $f`.
- `check_no_binaries`: `git ls-files skills scripts` (dropped `agents`).
- `XML_VOCAB`: removed the contract/agent-base tag set; kept `dispatch_protocol agents worker`.
- `xml_files`: `USER-AGENTS.md` and `skills/*/SKILL.md` only (dropped `SUBAGENT-CONTRACT.md` and `agents/*-ai-tools.md`).
- `xml_file_for`: dropped the `SUBAGENT-CONTRACT` branch; `*-ai-tools` resolves only `skills/$1/SKILL.md`.
- `check_xml_grammar`: dropped the `agents` local/lookup, the `<template> without agent` finding, and the "template agent is a shipped agent" loop.
- `check_version_bump`: pathspec is now `-- skills scripts USER-AGENTS.md`.
- usage() text and Run list updated to match (final order: `check_naming check_skill_frontmatter check_skill_name_match check_skill_layout check_skill_description_cap check_skill_description_content check_instructions_cap check_line_endings check_executable_bits check_no_binaries check_dev_tmp_untracked check_xml_grammar check_version_bump`).
- `README.md` "Semantic XML grammar": intro, references, and identity bullets reworded to drop the contract/agent-base vocabulary; vocabulary table rows for `<subagent_contract>`, contract sections, `<agent_base name role>`, and bases deleted; `<worker name>` meaning is now "worker entry"; `<dispatch_templates>` row cites `<template role>` / "the payload a template carries".
- `README.md` "Development checks": removed the wrapper coverage, wrapper body, model parity/effort pinning, description parity, and model row coverage bullets; reworded naming, skill description, size caps, xml grammar, and version bump bullets; closing paragraph now cites "the caps above (rules 3, 9)". Rule numbers left unrenumbered per the stage note (stage 5 renumbers).

Commands run (from `/home/wsl/.ai-tools`):

- `./scripts/lint.sh` → exit 0, `346 ok, 1 skipped, 0 warnings` (skip is the version-bump check without `--base`).
- `grep -iE 'wrapper|MODELS\.csv|model parity|agent base|subagent contract|template agent'` over the lint output → no matches.
- `grep -nE 'agent_names|harnesses\(\)|wrapper|canonical_body|model_for|model_effort_for|category_for|MODEL_TABLE|SUBAGENT-CONTRACT|agent_base|toml_field_value' scripts/lint.sh` → no matches.
- `./scripts/test.sh` → exit 0, `361 ok, 0 skipped, 0 warnings` (matches the stage-1 baseline; lib.sh untouched).
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` → exit 1, sole finding `SC1071` on `scripts/shell/install-zsh.sh` (pre-existing).
- `git diff --quiet master -- skills USER-AGENTS.md` → exit 0 (byte-identical).

Negative probes, each in a disposable `git worktree add -q <wt> HEAD` seeded with the working `scripts/lint.sh`, worktree removed after each run:

1. Dropped `Impact:` from `skills/az-ai-tools/SKILL.md` description → exit 2, `WARN: skill description missing Impact: (rule 9): .../skills/az-ai-tools/SKILL.md`.
2. Changed the `<template role="plan-author" agent="planner-ai-tools">` tag in `skills/plan-ai-tools/SKILL.md` to `<template name="...">` → exit 2, `WARN: xml grammar: <template> without role at line 32: .../skills/plan-ai-tools/SKILL.md`.
3. Added `<bogus_tag></bogus_tag>` inside `<overview>` of `skills/gh-ai-tools/SKILL.md` → exit 2, `WARN: xml grammar: tag outside the vocabulary <bogus_tag> at line 3: .../skills/gh-ai-tools/SKILL.md`.
4. `git mv skills/gc-ai-tools skills/gc-tools` → exit 2, `WARN: skill directory does not end in -ai-tools: .../skills/gc-tools/`.
5. Added `<subagent_contract></subagent_contract>` inside `<overview>` of `skills/az-ai-tools/SKILL.md` → exit 2, `WARN: xml grammar: tag outside the vocabulary <subagent_contract> at line 3: .../skills/az-ai-tools/SKILL.md`.

All five probes fired the expected finding and no other; all worktrees were removed after each run (`git worktree list` afterward shows only the pre-existing, unrelated worktrees plus the main checkout).

Coordinator acceptance note: the verifier's probe 2 edited the first `<template role="` match, which is a backticked reference (line 29), so no `<template> without role` finding appeared. Rerun on the structural tag (line 42 of `skills/plan-ai-tools/SKILL.md`) exited 2 with `xml grammar: <template> without role`. Probes 1, 3, 4, 5 passed as specified. Evidence: `dev/tmp/remove-agents-stage2-output.log`. Lint 346 ok / 0 warnings, test.sh 361 ok, shellcheck only SC1071.
