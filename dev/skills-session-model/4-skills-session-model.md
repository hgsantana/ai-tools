# Stage 4: vibe inline with an implementer question

## Objective

`vibe-ai-tools` plans and coordinates inline in the session. It runs plan-ai-tools steps 1 and 3, with its own alignment and no Task-mode redirect. With the plan on disk, it asks one implementer-model question, guided by a self-contained `<implementer_job>` block. It then runs dev-ai-tools steps 2-4, sending stage implementation to an `executor="implementer"` template spawned with the chosen model. Tests go to the dev `stage-verifier` default worker.

The new tag `<implementer_job>` is registered in `XML_VOCAB`, in the README vocabulary table, and in the README rule 5 optional-blocks list, all in this commit (README Semantic XML grammar requires that).

## Files

- Create: none
- Modify:
  - `skills/vibe-ai-tools/SKILL.md` (full rewrite to the target below)
  - `scripts/lint.sh`: `XML_VOCAB` only
  - `README.md`: rule 5 optional-blocks list and the vocabulary table only
- Remove: none

## Steps

1. Replace `skills/vibe-ai-tools/SKILL.md` with the target below.
   - `plan-author`, `vibe-coordinator`, the vibe `stage-verifier`, and `<return_protocol>` are deleted.
   - Tests use `dev-ai-tools <template role="stage-verifier">` through dev step 3.
2. `scripts/lint.sh`: append `implementer_job` to `XML_VOCAB`, on the same single line.
3. `README.md` rule 5: "Optional blocks `<status_protocol>`, `<return_protocol>`, and `<plan_file_format>` hold protocol that steps and templates cite" becomes "Optional blocks `<status_protocol>`, `<return_protocol>`, `<plan_file_format>`, and `<implementer_job>` hold protocol that steps and templates cite".
4. `README.md` vocabulary table: add the row `` | `<implementer_job>` | skills | the implementer's job, from which the session offers 1-3 implementer models | `` directly after the `<plan_file_format>` row.

### Target: skills/vibe-ai-tools/SKILL.md

```
---
name: vibe-ai-tools
description: >
  Plan a change under dev/, then execute that plan through dev-ai-tools,
  deciding in-scope implementation questions. Use for /vibe-ai-tools.
  Impact: after the plan is on disk, edits on a dedicated branch, commits,
  pushes, and opens a pull request unattended; edits and removals can be hard
  to undo. Pre-existing history remains intact. Cloud and destructive
  operations require separate approval. Agent: session + implementer (model
  asked once).
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change under dev/{SLUG}/ interactively with the user, then execute and deliver that plan unattended through dev-ai-tools mechanics, deciding in-scope implementation questions autonomously.
    The session plans, accepts, commits, and delivers; implementer subagents write stage code on the model the user chose; builds and tests go to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="interactive_planning">
      Run plan-ai-tools `<step id="1">` to record {BASE_BRANCH}.
      Refine scope, architecture, and trade-offs interactively with the user in chat, and derive a kebab-case {SLUG}.
      Run plan-ai-tools `<step id="3">` to write the plan under dev/{SLUG}/ per plan-ai-tools `<plan_file_format>`.
      Skip the standalone `/dev-ai-tools` offer once the plan is on disk.
    </step>

    <step id="2" name="implementer_model">
      With the plan on disk and before execution, ask the user exactly one question through USER-AGENTS `<user_interaction>`: which model implements this plan's stages, with 1-3 options chosen per `<implementer_job>`.
      Record the answer as {IMPLEMENTER_MODEL} in dev/{SLUG}/vibe-decisions.md; ask nothing else before delivery.
    </step>

    <step id="3" name="unattended_execution">
      Run dev-ai-tools `<step id="2">`, dev-ai-tools `<step id="3">`, and dev-ai-tools `<step id="4">` for dev/{SLUG}/ against {BASE_BRANCH}, with two differences:
      - Stage implementation goes to `<template role="stage-implementer">` from `<dispatch_templates>`, spawned with {IMPLEMENTER_MODEL} and substituting {STAGE_FILE} and {SLUG}; record the Executor as `implementer` plus that model, then review and accept its diff in the session.
      - Decide in-scope implementation questions and retry choices from code evidence, and record each decision and trade-off in dev/{SLUG}/vibe-decisions.md.
    </step>

    <step id="4" name="report">
      In chat (user's language), provide the report path, a one-line outcome, the implementer model used, and the PR URL or review patch path.
      Interrupt the user during execution only for unresolvable blockers or approvals reserved by USER-AGENTS `<security_guardrails>`.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: the strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` as the model, and state that in the report. When a spawn with the chosen model fails, retry once with the harness default and record that.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read {STAGE_FILE} of dev/{SLUG}/ and the repository rules (README.md, AGENTS.md if present). Implement only that stage.
        Match surrounding style, keep edits within the declared files, and write behaviour tests for delivered changes.
        Append factual notes to the Implementation log of {STAGE_FILE}, set status V per dev-ai-tools `<status_protocol>`, and return a one-line outcome with the changed paths.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for session review.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="session-owns-delivery">The session owns user alignment, planning, the implementer question, in-scope decisions, acceptance, commits, archival, and the pull request.</rule>
    <rule id="one-model-question">Ask the implementer model question once per run, after the plan is on disk; reuse the answer for every stage and rework.</rule>
    <rule id="spawn-apis">Spawn subagents through the harness's native subagent API (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent), passing the populated payload and file paths, never conversation context: each `<template executor="implementer">` with the recorded implementer model, and dev-ai-tools `<template role="stage-verifier">` with the harness default agent type and model.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="log-decisions">Log in-scope decisions to dev/{SLUG}/vibe-decisions.md for PR reviewer audit.</rule>
    <rule id="reserved-approvals">Never bypass approvals reserved by USER-AGENTS `<security_guardrails>` for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
```

## Tests

- `scripts/lint.sh; echo $?` prints `0`. The output includes:
  - `ok: semantic XML balanced, in vocabulary` for vibe (proves `implementer_job` is registered)
  - `ok: qualified reference resolves: plan-ai-tools <plan_file_format>`
  - `ok: reference resolves: <step id="1">`, `<step id="3">` (plan-ai-tools), and `<step id="2">`, `<step id="3">`, `<step id="4">` (dev-ai-tools), each in vibe. Target file paths are in the log line.
  - `ok: reference resolves: <template executor="implementer">` in vibe
  - `ok: reference names a vocabulary tag: <implementer_job>` in vibe
- Lint reports the vibe description within 500 characters (expected about 442).
- `git grep -niE '(planner|implementer|mechanical)-ai-tools|agent="|coordinator|sub-dispatch|high-reasoning|return_protocol' -- skills/vibe-ai-tools` prints nothing.
- Negative probe: in a disposable worktree (`git worktree add` at HEAD, then copy the working-tree `scripts/lint.sh` and `skills/vibe-ai-tools/SKILL.md` into it), remove `implementer_job` from the copied `XML_VOCAB`. Lint must exit 2 with `tag outside the vocabulary <implementer_job>`. Remove the worktree afterwards.
- `scripts/test.sh` exits 0. The CI shellcheck command reports only the known `SC1071`.

## Acceptance criteria

- [ ] vibe has no coordinator, planner, or verifier template and no `<return_protocol>`
- [ ] The session plans via plan-ai-tools steps 1 and 3, asks one implementer question after the plan is on disk, and runs dev-ai-tools steps 2-4
- [ ] `<implementer_job>` describes the job and capability, how to pick 1-3 models, and the harness fallback
- [ ] `stage-implementer` uses `executor="implementer"`; the description ends with `Agent: session + implementer (model asked once).`
- [ ] `implementer_job` is registered in `XML_VOCAB`, the README vocabulary table, and README rule 5
- [ ] lint and test exit 0

## Commit message

`feat(skills)!: run vibe inline and ask for the implementer model`

## Dependencies

- Requires stages: 3 (dev steps 2-4, plan step 3, `plan_file_format` sections)

## Implementation log

- Replaced `skills/vibe-ai-tools/SKILL.md` in full with the target text: session-inline planning (plan-ai-tools `<step id="1">`, `<step id="3">`), the new `<implementer_job>` block, one `<template role="stage-implementer" executor="implementer">`, and `<boundaries>` naming the native spawn APIs. `plan-author`, `vibe-coordinator`, the vibe `stage-verifier`, and `<return_protocol>` are gone.
- Appended `implementer_job` to the single-line `XML_VOCAB` string in `scripts/lint.sh` (line 411).
- `README.md` rule 5: added `` `<implementer_job>` `` to the optional-blocks sentence.
- `README.md` vocabulary table: added the `` `<implementer_job>` `` row directly after `` `<plan_file_format>` / `<structure>` ``.
- `scripts/lint.sh; echo $?` → `0` (`315 ok, 1 skipped, 0 warnings`; the skip is the version-bump check needing `--base`). Output includes `ok: reference names a vocabulary tag: <implementer_job> in .../skills/vibe-ai-tools/SKILL.md`, the plan-ai-tools `<step id="1">`/`<step id="3">` and dev-ai-tools `<step id="2">`/`<step id="3">`/`<step id="4">` reference lines, `ok: reference resolves: <template executor="implementer">`, and `ok: skill description within cap: .../vibe-ai-tools/SKILL.md (442/500)`.
- `git grep -niE '(planner|implementer|mechanical)-ai-tools|agent="|coordinator|sub-dispatch|high-reasoning|return_protocol' -- skills/vibe-ai-tools` → exit 1 (no matches; grep's "nothing found" code).
- Negative probe: `git worktree add --detach <scratchpad>/vibe-stage4-probe HEAD`, copied in the working-tree `scripts/lint.sh` and `skills/vibe-ai-tools/SKILL.md`, stripped ` implementer_job` from the copied `XML_VOCAB`. `./scripts/lint.sh` in that worktree → exit `2`, with `WARN: xml grammar: tag outside the vocabulary <implementer_job> at line 32: .../skills/vibe-ai-tools/SKILL.md`. Removed the worktree afterwards (`git worktree remove --force`); `git worktree list` back to the pre-existing four entries (main tree plus `enhance-planner-reporting-dev-ai-tools`, `modelo-e-harness-info`, `qual-o-seu-harness`, none touched).
- `scripts/test.sh` → exit 0, `305 ok, 0 skipped, 0 warnings`.
- `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` → exit 1, only the known `SC1071` on `scripts/shell/install-zsh.sh` (pre-existing, not a regression).
