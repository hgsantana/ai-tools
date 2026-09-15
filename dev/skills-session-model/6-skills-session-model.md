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

`scripts/lint.sh`:
- `check_xml_grammar` first awk, inside `if (name == "template") { … }`: added the two `print` lines for a retired `agent="..."` attribute and for a missing/invalid `executor="(default-worker|implementer|session-subagent)"`.
- `check_skill_description_content`: pattern changed to `*"Impact:"*"Agent:"*` (ordered); `impact` computed via `sub(/.*Impact:/, "")` then `sub(/Agent:.*/, "")` (plus the existing whitespace trim kept for the emptiness check); finding text `skill description missing ordered Impact: and Agent: (rule 6)`; ok text `skill description has what + Impact + Agent`.
- Added `IMPLEMENTER_SKILLS="vibe-ai-tools campaign-ai-tools"`, `AGENT_SESSION="session"`, `AGENT_IMPLEMENTER="session + implementer (model asked once)"`, and `check_skill_agent_field()` (verbatim per the stage spec), defined right after `check_skill_description_content` and above `# --- Run ---`.
- Run list: `check_skill_agent_field` added right after `check_skill_description_content`.
- Usage text: `skill description` entry now ends "...then Impact:, then Agent: (rule 6)"; new `agent field` entry added after it; `xml grammar` entry now mentions role+executor and "never an agent attribute".

`README.md`:
- Rule 5: "two parts" -> "three parts"; inserted the executor/session-model sentence after the `<session_workflow>` sentence.
- Rule 6: added clause (3) for `Agent:` with its two allowed values.
- Rule 9: "role" -> "role and executor".
- Semantic XML grammar: Identity bullet now says "role and an executor"; added a new **Executors** bullet describing the three executor values and that session-only work is a `<step>`, never a template.
- Development checks: `skill description` entry updated; new `agent field` entry added; `xml grammar` entry updated to mention role, valid executor, and no `agent` attribute.

Tests run:
- `scripts/lint.sh` on the real tree: exit 0, `335 ok, 1 skipped, 0 warnings`. Nine `ok: skill Agent: matches implementer usage` lines, two carrying `(session + implementer (model asked once))` (campaign-ai-tools, vibe-ai-tools), the other seven carrying `(session)`. The one skip is the pre-existing version-bump check (no `--base`).
- Six negative probes, run in a disposable worktree at `mktemp -d`, each on a fresh copy of the working-tree `scripts/lint.sh` and restored via `git checkout --` between probes:
  1. az-ai-tools template `executor="default-worker"` -> `agent="mechanical-ai-tools"`: exit 2, `WARN: xml grammar: <template> with retired agent attribute at line 36`, `WARN: xml grammar: <template> without a valid executor at line 36`, and `WARN: unresolved reference <template executor="default-worker"> in .../az-ai-tools/SKILL.md` (the rule's own backticked reference). Matches expected.
  2. Same template, `executor="bogus"`: exit 2, `WARN: xml grammar: <template> without a valid executor at line 36`. Matches expected.
  3. vibe-ai-tools description `Agent: session + implementer (model asked once).` -> `Agent: session.`: exit 2, `WARN: skill Agent: 'session' disagrees with <implementer_job> (1) or implementer templates (1) (rule 6)`. Matches expected.
  4. vibe-ai-tools description -> `Agent: planner-ai-tools.`: exit 2, `WARN: skill description has invalid Agent: 'planner-ai-tools' (rule 6)`. Matches expected.
  5. Copied `skills/vibe-ai-tools/SKILL.md` to `skills/dev-ai-tools/SKILL.md`, set `name:` and `<skill name>` to `dev-ai-tools`: exit 2, `WARN: skill spawns implementers outside vibe-ai-tools campaign-ai-tools (rule 6): .../dev-ai-tools/SKILL.md` (plus unrelated reference warnings from the copied file lacking `stage-verifier`/`<status_protocol>`, as expected). Matches expected.
  6. `git worktree remove --force` then `rm -rf` the mktemp dir: `git worktree list` afterward shows only the three unrelated pre-existing worktrees under `/home/wsl/.ai-tools.worktrees/`; no leftover from this run.
- `scripts/test.sh`: exit 0, `305 ok, 0 skipped, 0 warnings`.
- CI shellcheck command `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh`: only the known `SC1071` on `scripts/shell/install-zsh.sh`. Bare `shellcheck scripts/lint.sh` reports only `SC1091` on the pre-existing `. "$AI_TOOLS/scripts/shell/lib.sh"` line (info-level, "not following" without `-x`); confirmed identical on the committed HEAD copy of `scripts/lint.sh` before this stage's edits, so it is pre-existing and not a new finding from `check_skill_agent_field` or the other additions.
