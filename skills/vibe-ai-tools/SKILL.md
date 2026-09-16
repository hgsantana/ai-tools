---
name: vibe-ai-tools
description: >
  Plan a change under dev/, then execute that plan through a fresh
  execution pass, deciding in-scope implementation questions. Use for
  /vibe-ai-tools. Impact: after the plan is on disk, edits on a dedicated
  branch, commits, pushes, and opens a pull request unattended; edits and
  removals can be hard to undo. Pre-existing history remains intact. Cloud
  and destructive operations require separate approval. Agent: session +
  implementer (model asked once).
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change under dev/{SLUG}/ interactively with the user, then spawn a fresh execution pass to deliver it.
    The session plans and asks the implementer model; a session-subagent accepts, commits, and opens the pull request; implementers write stage code; builds and tests go to a default worker.
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
      Spawn a fresh `<template role="vibe-executor">` from `<dispatch_templates>`, substituting {SLUG}, {BASE_BRANCH}, and {IMPLEMENTER_MODEL}.
      Record only the `<signal>` from `<return_protocol>`. Do not open the plan, vibe-decisions.md, or the report body.
    </step>

    <step id="4" name="report">
      In chat (user's language), provide the report or evidence path, a one-line outcome, the implementer model from the `<signal>`, and the PR URL or review patch path from the `<signal>` fields.
      Interrupt the user only when the pass returns `<signal code="BLOCKED">` for an unresolvable blocker or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: the strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` as the model, and state that in the report. When a spawn with the chosen model fails, retry once with the harness default and record that.
  </implementer_job>

  <dispatch_templates>
    <template role="vibe-executor" executor="session-subagent">
      <job>Execution pass: deliver one plan on plan/{SLUG} with implementers, then open the pull request.</job>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <implementer_model>{IMPLEMENTER_MODEL}</implementer_model>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`. Include `<template role="stage-implementer">` from this file and dev-ai-tools `<template role="stage-verifier">` plus dev-ai-tools `<status_protocol>` in the brief.
        Check out plan/{SLUG} from {BASE_BRANCH} and commit the unit first: `chore(dev): plan {SLUG}`.
        For each unfinished stage in dependency order, own every status except V: set W and record Executor as implementer plus {IMPLEMENTER_MODEL} in the base plan Status table; spawn `<template role="stage-implementer">` as executor="implementer" with {IMPLEMENTER_MODEL}, substituting the stage file and {SLUG}; if that spawn is rejected only for the recorded model, retry once with the harness default and use that model for remaining stages; review the working-tree diff against objective, declared files, and acceptance; set T and spawn dev-ai-tools `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic (it writes logs under dev/tmp/ and returns command, exit code, and path); on pass, commit with the stage's Conventional Commit message and set F; else append corrections, set R1..R3, retry up to three times, then set E.
        Decide in-scope questions from code evidence; append each decision to dev/{SLUG}/vibe-decisions.md.
        Successful completion is every required stage F. Only then: copy the unit to dev/tmp/finished/{SLUG}, git rm it, commit `chore(dev): archive {SLUG}`, push plan/{SLUG}, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write dev/tmp/{SLUG}-review.patch, write dev/tmp/{SLUG}-report.md, and end with `<signal code="DELIVERED">` using the implementer model actually used.
        If any required stage is E, a nested spawn is missing, or a reserved approval is pending: retain the unit, do not archive, push, or open a pull request, write evidence to dev/tmp/{SLUG}-blocked.md, and end with `<signal code="BLOCKED">`. Do not start a dependent stage after E. Partial delivery is not authorized.
      </instructions>
      <constraints>
        <constraint>Leave stage code to the implementer and builds and tests to default workers; own review, acceptance, commits, and the pull request.</constraint>
        <constraint>When the implementer or a default worker cannot be spawned, do not do that work yourself: end with `<signal code="BLOCKED">` naming the missing nested-spawn capability.</constraint>
        <constraint>Preserve pre-existing commit history.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read {STAGE_FILE} of dev/{SLUG}/ and the repository rules (README.md, AGENTS.md if present). Implement only that stage.
        Match surrounding style, keep product and test edits within the declared files, and write behaviour tests for delivered changes.
        Append factual notes to the Implementation log of {STAGE_FILE}, set that stage's Status cell to V in the base plan Status table, and return a one-line outcome with the changed paths.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Edit only the declared stage files, the Implementation log of {STAGE_FILE}, and that stage's Status cell in `dev/{SLUG}/0-{SLUG}.md`.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for execution pass review.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_OR_PATCH} {IMPLEMENTER_MODEL}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-owns-planning">The session owns user alignment, planning, the implementer question, and reporting from the `<signal>`; the execution pass owns in-scope decisions, acceptance, commits, archival, and the pull request.</rule>
    <rule id="signals-only">After spawning `<template role="vibe-executor">`, the session stores only the `<signal>` line and its fields. It does not read the plan, vibe-decisions.md, or the report body.</rule>
    <rule id="one-model-question">Ask the implementer model question once per run, after the plan is on disk; reuse the answer for every stage and rework.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>` for the native subagent API list and payload rules: `<template role="vibe-executor">` runs as `executor="session-subagent"` on the session's own model; `<template role="stage-implementer">` runs as `executor="implementer"` with the recorded {IMPLEMENTER_MODEL}; dev-ai-tools `<template role="stage-verifier">` runs as `executor="default-worker"` with the harness default agent type and model.</rule>
    <rule id="no-host-fallback">If `<template role="vibe-executor">` cannot be spawned, do not run delivery in the session: report the missing capability.</rule>
    <rule id="completion-is-f">Archive, push, and pull-request creation run only when every required stage is F. An E stage is BLOCKED and retains the work unit.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="log-decisions">Log in-scope decisions to dev/{SLUG}/vibe-decisions.md for PR reviewer audit.</rule>
    <rule id="reserved-approvals">Never bypass approvals reserved by USER-AGENTS `<security_guardrails>` for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
