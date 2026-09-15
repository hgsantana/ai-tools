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
