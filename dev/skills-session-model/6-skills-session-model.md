# Stage 6: Lint the executor convention and the Agent: field

## Objective

`scripts/lint.sh` enforces the convention the skills now follow:

- Every `<template>` carries `executor` with value `default-worker`, `implementer`, or `session-subagent`. The retired `agent` attribute is a finding.
- Every skill description has `Agent:` after `Impact:`, with value `session` or `session + implementer (model asked once)`.
- A skill's `Agent:` value names `implementer` exactly when the skill defines `<implementer_job>` and at least one `<template executor="implementer">`. Only `vibe-ai-tools` and `campaign-ai-tools` may do so.

README rules 5, 6, and 9, the Semantic XML grammar, and Development checks describe these checks in the same commit (README Development checks: "add its check … in the same commit").

## Files

- Create: none
- Modify:
  - `scripts/lint.sh`: usage text, `check_xml_grammar` template branch, `check_skill_description_content`, a new `check_skill_agent_field`, and the run list
  - `README.md`: rules 5, 6, and 9; Semantic XML grammar bullets; Development checks list
- Remove: none

## Steps

### scripts/lint.sh

1. In the `check_xml_grammar` first awk, inside `if (name == "template") { … }`, keep the role check and add:
   ```awk
   if (tok ~ / agent="/) print "<template> with retired agent attribute at line " NR
   if (tok !~ / executor="(default-worker|implementer|session-subagent)"/) print "<template> without a valid executor at line " NR
   ```
2. `check_skill_description_content`: require `Impact:` before `Agent:`. Change the pattern to `*"Impact:"*"Agent:"*`. Compute `impact` as the text between `Impact:` and `Agent:` (`sub(/.*Impact:/, ""); sub(/Agent:.*/, "")`). The finding text becomes `skill description missing ordered Impact: and Agent: (rule 6)`, and the ok text becomes `skill description has what + Impact + Agent`.
3. Add near the other skill checks:
   ```bash
   IMPLEMENTER_SKILLS="vibe-ai-tools campaign-ai-tools"
   AGENT_SESSION="session"
   AGENT_IMPLEMENTER="session + implementer (model asked once)"

   check_skill_agent_field() {
     # rule 6: Agent: value matches implementer usage (<implementer_job> plus a
     # structural executor="implementer" template), allowed only in
     # IMPLEMENTER_SKILLS.
     local d name f val agent job impl expect
     for d in "$AI_TOOLS"/skills/*-ai-tools/; do
       [ -d "$d" ] || continue
       name=$(basename "$d"); f="${d}SKILL.md"
       [ -f "$f" ] || continue
       val=$(yaml_frontmatter_folded_value "$f" description)
       case "$val" in *"Agent:"*) ;; *) continue ;; esac  # reported by check_skill_description_content
       agent=$(printf '%s\n' "$val" | awk '{ sub(/.*Agent:[ \t]*/, ""); sub(/[ \t.]+$/, ""); print }')
       case "$agent" in
         "$AGENT_SESSION") expect=0 ;;
         "$AGENT_IMPLEMENTER") expect=1 ;;
         *) warn "skill description has invalid Agent: '$agent' (rule 6): $f"; continue ;;
       esac
       job=0; xml_body "$f" | grep -q '<implementer_job>' && job=1
       impl=0; xml_body "$f" | grep -q '<template [^>]*executor="implementer"' && impl=1
       if [ "$job" != "$expect" ] || [ "$impl" != "$expect" ]; then
         warn "skill Agent: '$agent' disagrees with <implementer_job> ($job) or implementer templates ($impl) (rule 6): $f"
       elif [ "$expect" = 1 ] && ! in_list "$name" "$IMPLEMENTER_SKILLS"; then
         warn "skill spawns implementers outside $IMPLEMENTER_SKILLS (rule 6): $f"
       else
         ok "skill Agent: matches implementer usage: $f ($agent)"
       fi
     done
   }
   ```
   `xml_body` strips backticked spans, so references such as `` `<template executor="implementer">` `` in a rule never count. The implementer may adjust local names and message wording but must keep the behaviour.
4. Run list: call `check_skill_agent_field` right after `check_skill_description_content`.
5. Usage text (`Checks:` block):
   - `skill description`: "…states what the skill does, then Impact:, then Agent: (rule 6)".
   - Add an entry `agent field` with: "Agent: is session, or session + implementer (model asked once) exactly when the skill defines <implementer_job> and an executor="implementer" template; only vibe-ai-tools and campaign-ai-tools (rule 6)".
   - `xml grammar`: "…gives every <rule> a unique id, and every <template> a role and an executor (default-worker, implementer, session-subagent), never an agent attribute (rule 9…)".

### README.md

6. Rule 5:
   - "Descriptions contain two parts" becomes "Descriptions contain three parts".
   - After "the host session executes the `<session_workflow>`." insert: "Skills run on the session model; a `<template>`'s `executor` decides where its payload runs ([Semantic XML grammar](#semantic-xml-grammar)). Only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers, after one implementer-model question guided by their `<implementer_job>`."
7. Rule 6: after part (2), add "; (3) `Agent:` with `session` when the skill never spawns implementers, or `session + implementer (model asked once)` when it does." Keep the 500-character sentence.
8. Rule 9: "every `<rule>` has an `id`, and every `<template>` names its `role`" becomes "every `<rule>` has an `id`, and every `<template>` names its `role` and `executor`".
9. Semantic XML grammar:
   - Identity bullet: "every `<template>` carries a functional `role` and an `executor`".
   - Add a bullet after Identity: "**Executors**: `executor="default-worker"` runs the payload through the harness's native subagent API with its default agent type and model (builds, tests, script runs, bulk fact collection); `executor="implementer"` runs it with the model the user chose from the skill's `<implementer_job>` question; `executor="session-subagent"` runs it in a fresh subagent on the session's model. Work the session does itself is a `<step>`, never a template."
10. Development checks list:
    - **skill description**: "…states what it does, then `Impact:`, then `Agent:` (rule 6)".
    - Add after it: "**agent field** — `Agent:` is `session`, or `session + implementer (model asked once)` exactly when the skill defines `<implementer_job>` and a `<template executor="implementer">`; only `vibe-ai-tools` and `campaign-ai-tools` spawn implementers (rule 6)".
    - **xml grammar**: "…every `<rule>` a unique `id`, and every `<template>` a `role` and a valid `executor`, never an `agent` attribute (rule 9, …)".

## Tests

- `scripts/lint.sh; echo $?` prints `0`, with nine lines `ok: skill Agent: matches implementer usage` (two carrying the implementer value) and no warning.
- Negative probes. HEAD lacks the uncommitted `lint.sh`, so copy it into the worktree before each probe. Run each probe on a fresh copy of the affected file:
  1. `wt=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-lint.XXXXXX"); git worktree add -q "$wt/t" HEAD; cp scripts/lint.sh "$wt/t/scripts/lint.sh"`
  2. In `$wt/t/skills/az-ai-tools/SKILL.md`, replace `executor="default-worker"` on the template with `agent="mechanical-ai-tools"`. Lint exits 2 with `<template> with retired agent attribute` and `<template> without a valid executor`. It also warns about the unresolved `<template executor="default-worker">` reference in the rule.
  3. Restore it, then set `executor="bogus"`. Expect `without a valid executor`.
  4. Restore it. In `$wt/t/skills/vibe-ai-tools/SKILL.md`, change the description to `Agent: session.` Expect `disagrees with <implementer_job> (1) or implementer templates (1)`.
  5. Restore it, then change it to `Agent: planner-ai-tools.` Expect `invalid Agent: 'planner-ai-tools'`.
  6. Copy `skills/vibe-ai-tools/SKILL.md` to `$wt/t/skills/dev-ai-tools/SKILL.md`, then set its `name:` and `<skill name>` to `dev-ai-tools`. Expect `spawns implementers outside`.
  7. `git worktree remove --force "$wt/t"; rm -rf "$wt"`. `git worktree list` shows no leftover.
  - Probe 6 also produces unrelated reference warnings, because the copied dev file lacks `stage-verifier` and `<status_protocol>`. Assert exit 2 and grep for the expected message only.
  - Define `check_skill_agent_field` above the `# --- Run ---` section. A call without a definition prints `command not found` and still exits 0, so probes 4-6 would pass vacuously.
- `scripts/test.sh` exits 0.
- The CI shellcheck command reports only the known `SC1071`, so the new function adds no finding.

## Acceptance criteria

- [ ] lint rejects templates without a valid `executor` and templates with `agent=`
- [ ] lint requires ordered `Impact:` then `Agent:` and accepts only the two values
- [ ] lint ties `Agent:` to `<implementer_job>` plus `executor="implementer"` templates and limits them to vibe and campaign
- [ ] All six negative probes fail as described; the real tree passes
- [ ] README rules 5, 6, and 9, the Semantic XML grammar, and Development checks describe exactly these checks
- [ ] lint and test exit 0; shellcheck shows no new finding

## Commit message

`feat(lint): enforce template executors and the skill Agent: field`

## Dependencies

- Requires stages: 2, 3, 4, 5 (every skill conforms)

## Implementation log
