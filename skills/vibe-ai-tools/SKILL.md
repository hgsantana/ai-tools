---
name: vibe-ai-tools
description: >
  Align the design tree and plan under plans/, then deliver with implementers
  per stage, deciding in-scope implementation questions. Use for
  /vibe-ai-tools. Impact: after the plan is on disk, edits on a dedicated
  branch, commits, pushes, and opens a pull request unattended; edits and
  removals can be hard to undo. Pre-existing history remains intact. Cloud
  and destructive operations require separate approval. Agent: session +
  implementer (model asked once).
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Grill the user along the design tree and plan a change under plans/{SLUG}/, then the session delivers it.
    Planning follows `<planning_protocol>` and delivery follows `<implementation_protocol>`: the chosen planner plans, the chosen implementer writes stage code, tests go to a default worker when that spawn works, and the session judges each stage, commits, and opens the pull request.
  </overview>

  <session_workflow>
    <step id="1" name="interactive_planning">
      Execute `<planning_protocol>` for the requested change, resolving {PLANNER} per `<rule id="planner-offer">`: the chosen planner runs the grill-me interview and writes the base plan `plans/{SLUG}/0-{SLUG}.md`.
    </step>

    <step id="2" name="implementer_choice">
      With the plan on disk and before the first stage, resolve {IMPLEMENTER} once per `<rule id="implementer-offer">`, framed by `<implementer_job>`.
      Record {PLANNER} and {IMPLEMENTER} in plans/{SLUG}/vibe-decisions.md; ask nothing else before delivery.
    </step>

    <step id="3" name="unattended_execution">
      Read the base plan and repository rules (README.md, AGENTS.md if present), then deliver per `<implementation_protocol>` with these skill specifics:
        1. Stage planning: when {PLANNER} is `executor="planner"`, spawn `<template role="stage-planner">` from `<dispatch_templates>`, substituting {STAGE_FILE} and {SLUG}; otherwise the session runs that template's instructions itself.
        2. Implementation: spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {STAGE_FILE} and {SLUG}; it runs `<template role="stage-verifier">` in place of a separate tester spawn. If a spawn is rejected only for its model, retry once with the harness default and keep that for remaining stages.
        3. Review: the session reviews the working-tree diff against the stage objective, declared files, and acceptance criteria in place of a reviewer spawn, decides in-scope questions from code evidence, and appends each decision to plans/{SLUG}/vibe-decisions.md. On rework, append concrete correction tasks to the stage log.
      On E: stop remaining stages, retain the work unit, and go to `<step id="4">` as blocked. Do not start a dependent stage.
      On all stages F, finish the delivery lifecycle of `<implementation_protocol>`: target {BASE_BRANCH} with `gh pr create` or write ${TMPDIR:-/tmp}/ai-tools/{SLUG}-review.patch when no host is available, write ${TMPDIR:-/tmp}/ai-tools/{SLUG}-report.md, and treat the outcome as `<signal code="DELIVERED">`.
      If blocked: retain unit without push or PR, write evidence to ${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md, and treat outcome as `<signal code="BLOCKED">`. Partial delivery is not authorized.
    </step>

    <step id="4" name="report">
      In chat (user's language), provide the report or evidence path, a one-line outcome, the implementer actually used, and the PR URL or review patch path.
      Interrupt the user only for `<signal code="BLOCKED">` or an approval reserved by `<security_guardrails>`.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    State the resolved model behind each option when the harness exposes it. When the native subagent API cannot select a model per spawn, the chosen executor runs on the harness default; state that in the report.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-planner" executor="planner">
      <job>Stage planner: inspect repository state and write detailed stage file for one stage.</job>
      <input>
        <stage_file>{STAGE_FILE}</stage_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read base plan plans/{SLUG}/0-{SLUG}.md and repository rules (README.md, AGENTS.md if present).
        Inspect the working tree and commit history after previous stages. Expand {STAGE_FILE}'s outline from the base plan into a detailed stage file under plans/{SLUG}/{STAGE_FILE}: Objective, Decisions, Files, Steps, Tests, Acceptance criteria, Commit message, Dependencies, and Implementation log.
        Set that stage's Status cell to PF in plans/{SLUG}/0-{SLUG}.md.
        End with `<signal code="PLANNED">` or `<signal code="BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Do not modify product or test code.</constraint>
        <constraint>Edit only {STAGE_FILE} and that stage's Status cell in plans/{SLUG}/0-{SLUG}.md.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per `<rule id="payload-assembly">`. Include `<template role="stage-verifier">` from this file in the brief.
        Read {STAGE_FILE} of plans/{SLUG}/ and the repository rules (README.md, AGENTS.md if present). Implement only that stage.
        Match surrounding style, keep product and test edits within the declared files, and write behaviour tests for delivered changes.
        Spawn `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic. If that spawn fails, run the commands yourself and write the same log.
        Append factual notes to the Implementation log of {STAGE_FILE}, set that stage's Status cell to V in the base plan Status table, and return a one-line outcome with the changed paths, test exit code, and log path.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Edit only the declared stage files, the Implementation log of {STAGE_FILE}, and that stage's Status cell in `plans/{SLUG}/0-{SLUG}.md`.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for session review.</constraint>
      </constraints>
    </template>

    <template role="stage-verifier" executor="default-worker">
      <job>Default worker: run builds and tests and collect factual evidence.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute {COMMANDS} without design decisions.
        Capture stdout and stderr to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}-output.log.
        Return facts: command, exit code, and output path.
      </instructions>
      <constraints>
        <constraint>Do not modify production or test code unless explicitly passed as a patch.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="PLANNED">PLANNED {STAGE_FILE}</signal>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_OR_PATCH} {IMPLEMENTER}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-owns-delivery">The session owns user alignment, the planner and implementer offers, in-scope decisions, judgment, commits, archival, the pull request, and reporting from disk paths.</rule>
    <rule id="protocols">Planning follows user-wide `<planning_protocol>` and delivery follows `<implementation_protocol>`; this skill states only its specifics.</rule>
    <rule id="one-offer-each">Ask the planner offer once when planning starts and the implementer offer once after the plan is on disk; reuse both for every stage, rework, and resume.</rule>
    <rule id="spawn-apis">Per `<execution_protocol>`: `<template role="stage-planner">` runs as {PLANNER}; `<template role="stage-implementer">` runs as {IMPLEMENTER}; `<template role="stage-verifier">` runs as `executor="default-worker"`.</rule>
    <rule id="no-implementer-fallback">If a chosen planner or implementer cannot be spawned, do not plan or implement that stage in the session: end as `<signal code="BLOCKED">` naming the missing spawn.</rule>
    <rule id="worker-fallback">If a default-worker spawn fails, the spawning context runs those commands itself per `<rule id="spawn-fallback">`.</rule>
    <rule id="completion-is-f">Archive, push, and pull-request creation run only when every required stage is F. An E stage is BLOCKED and retains the work unit.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="log-decisions">Log in-scope decisions to plans/{SLUG}/vibe-decisions.md for PR reviewer audit.</rule>
    <rule id="reserved-approvals">Never bypass approvals reserved by `<security_guardrails>` for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
