---
name: campaign-ai-tools
description: >
  Run an autonomous local campaign in which the session iterates scope,
  a planner writes each plan, and implementers deliver its stages. Use for
  /campaign-ai-tools. Impact: creates or resumes a campaign branch, edits or
  removes files, runs commands and tests, and makes multiple local commits.
  It never pushes or writes outside the repository. Agent: session +
  implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Run an autonomous local campaign that repeatedly plans and delivers user-directed repository improvements.
    Each iteration plans per `<planning_protocol>` and delivers per `<implementation_protocol>`, committing locally on `improve/{CAMPAIGN}`: the chosen planner writes each plan, the chosen implementer delivers stage code, and a session-subagent validates diffs. Chat names paths only.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve kebab-case {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS} via `<user_interaction>` per `<planning_protocol>`.
      Verify repository root with `git rev-parse --show-toplevel`.
      Recovery check: if `plans/improve/{CAMPAIGN}/campaign.md` exists on `improve/{CAMPAIGN}` or can be restored, resume it (preserve branch, last accepted stage, last iteration, {PLANNER}, and {IMPLEMENTER}). Otherwise, check out `improve/{CAMPAIGN}` from a clean base branch and initialize `plans/improve/{CAMPAIGN}/campaign.md` with goals, priorities, exclusions, and active status.
      When not recorded, resolve {PLANNER} per `<rule id="planner-offer">` and {IMPLEMENTER} per `<rule id="implementer-offer">`, framed by `<implementer_job>`, once for the whole campaign; record both in campaign.md.
      Commit campaign start or resume: `chore(plans): start campaign {CAMPAIGN}` or `chore(plans): resume campaign {CAMPAIGN}`.
    </step>

    <step id="2" name="plan">
      Run `<template role="campaign-planner">` from `<dispatch_templates>` with {MODE} set to PLAN, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and empty {STAGE_FILE}: spawn it when {PLANNER} is `executor="planner"`; otherwise the session runs its instructions itself.
      Record only the `<signal>` from `<return_protocol>`. Name the plan path in chat without opening the directory.
      Two consecutive `<signal code="NONE">` outcomes cleanly terminate the campaign.
      If the planner cannot be spawned, treat the campaign as `<signal code="BLOCKED">`.
    </step>

    <step id="3" name="stage_loop">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, stay on `improve/{CAMPAIGN}`. Commit the plan first if uncommitted: `chore(plans): plan` plus the directory name.
      Run unfinished stages per `<implementation_protocol>` with these skill specifics:
        1. Stage planning: run `<template role="campaign-planner">` as in `<step id="2">` with {MODE} set to STAGE-PLAN and {STAGE_FILE}.
        2. Implementation: record {IMPLEMENTER} in the base plan Executor column and spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {STAGE_FILE} and {CAMPAIGN}; it runs `<template role="stage-verifier">` in place of a separate tester spawn. If rejected only for its model, retry once with harness default.
        3. Review: spawn `<template role="stage-validator">` as `executor="session-subagent"`, substituting {CAMPAIGN} and {STAGE_FILE}; pass paths only without assembling a diff. REWORK retries read `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md`; `<signal code="BLOCKED">` from validation sets E.
      On E: stop remaining stages, retain plan, and go to `<step id="5">` as blocked.
      On all stages F, replace the delivery lifecycle of `<implementation_protocol>` locally: archive plan to `${TMPDIR:-/tmp}/ai-tools/finished/`, remove with `git rm -r`, commit `chore(plans): archive` plus slug, record iteration file in `plans/improve/{CAMPAIGN}/iterations/`, update campaign.md with last accepted stage and iteration {N}, and commit `chore(plans): record campaign {CAMPAIGN} iteration {N}`.
    </step>

    <step id="4" name="iteration_loop">
      Repeat `<step id="2">` for a new PLAN.
      Continue until two consecutive `<signal code="NONE">` outcomes, host halt, budget exhaustion, or `<signal code="BLOCKED">`, then proceed to `<step id="5">`.
    </step>

    <step id="5" name="completion_and_archival">
      On two consecutive `<signal code="NONE">`: archive `plans/improve/{CAMPAIGN}/` to `${TMPDIR:-/tmp}/ai-tools/finished/improve/{CAMPAIGN}/`, remove with `git rm -r`, and commit `chore(plans): complete campaign {CAMPAIGN}`.
      On halt or budget limit: preserve `plans/improve/{CAMPAIGN}/`, update campaign.md with paused status and progress, and commit `chore(plans): pause campaign {CAMPAIGN}`.
      On `<signal code="BLOCKED">`: retain directory, record reason and evidence path in campaign.md, and commit `chore(plans): block campaign {CAMPAIGN}`.
      Report branch, HEAD, and disk paths in chat (user's language). Never push or open a pull request.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within declared scope, matches repository style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    State the resolved model behind each option when the harness exposes it. When the native subagent API cannot select a model per spawn, the chosen executor runs on harness default; record the model used in the iteration file. When the planner or implementer cannot be spawned, `<rule id="no-planner-or-implementer-fallback">` applies.
  </implementer_job>

  <dispatch_templates>
    <template role="campaign-planner" executor="planner">
      <job>Campaign planner: in PLAN mode, write base plan with succinct stages; in STAGE-PLAN mode, detail one stage file.</job>
      <input>
        <mode>{MODE}</mode>
        <campaign>{CAMPAIGN}</campaign>
        <priorities>{PRIORITIES}</priorities>
        <exclusions>{EXCLUSIONS}</exclusions>
        <assigned_file>{STAGE_FILE}</assigned_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Assemble nested spawn payloads per `<rule id="payload-assembly">`. Include `<template role="repo-discovery">` in the brief.
        When {MODE} is PLAN: inspect the working tree of campaign {CAMPAIGN} against {PRIORITIES}, skipping {EXCLUSIONS}. On an unfinished plan, validate recorded statuses and return `<signal code="RESUME">`. Otherwise, spawn `<template role="repo-discovery">` as executor="default-worker" for questions, derive kebab-case slug, and write base plan `0-<slug>.md` per `<planning_protocol>`. Leave code unchanged. Return PLAN, RESUME, NONE, or BLOCKED `<signal>`. {STAGE_FILE} is unused in PLAN.
        When {MODE} is STAGE-PLAN: read {STAGE_FILE}'s outline in the base plan and write detailed stage file `{STAGE_FILE}` per `<planning_protocol>`. Set stage status to PF in base plan and return `<signal code="PLANNED">` or `<signal code="BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Do not push or touch remote repository.</constraint>
        <constraint>Do not edit product or test code.</constraint>
        <constraint>If a default-worker spawn fails, run that discovery yourself per `<rule id="spawn-fallback">`.</constraint>
      </constraints>
    </template>

    <template role="stage-validator" executor="session-subagent">
      <job>Stage reviewer: judge one stage from the working-tree diff.</job>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <assigned_file>{STAGE_FILE}</assigned_file>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {STAGE_FILE} and inspect `git diff` against HEAD on campaign {CAMPAIGN} branch `improve/{CAMPAIGN}`. Judge whether the diff meets acceptance criteria, write the verdict to `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md`, and return `<signal code="ACCEPT">`, `<signal code="REWORK">`, or `<signal code="BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Edit only the verdict file; do not commit, push, or touch remote repository.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <campaign>{CAMPAIGN}</campaign>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Assemble nested spawn payloads per `<rule id="payload-assembly">`. Include `<template role="stage-verifier">` in the brief.
        Read {STAGE_FILE} on improve/{CAMPAIGN} and repository rules (README.md, AGENTS.md if present). If `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md` exists, apply its corrections. Implement only that stage.
        Match surrounding style, keep product and test edits within declared files, and write behaviour tests for delivered changes.
        Spawn `<template role="stage-verifier">` as executor="default-worker" with stage commands and a kebab-case topic. If that spawn fails, run commands yourself and write the same log.
        Append factual notes to the Implementation log of {STAGE_FILE}, set stage status to V in the base plan Status table, and return a one-line outcome with changed paths, test exit code, and log path.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Edit only declared stage files, Implementation log of {STAGE_FILE}, and stage status in the base plan.</constraint>
        <constraint>Do not commit or push; leave changes in working tree for `<template role="stage-validator">`.</constraint>
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

    <template role="repo-discovery" executor="default-worker">
      <job>Default worker: collect read-only repository facts for planning.</job>
      <input>
        <questions>{QUESTIONS}</questions>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Answer {QUESTIONS} from the working tree with read-only searches, file reads, and commands.
        Write file paths, line references, and command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return output path and a one-line summary.
      </instructions>
      <constraints>
        <constraint>Leave product, test, and plan files unchanged; do not commit or change branches.</constraint>
        <constraint>The sole write is the report file ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.</constraint>
        <constraint>Report facts; leave design decisions to the caller.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="PLAN">PLAN {PLAN_PATH}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-mediates">The session iterates scope, owns the planner and implementer offers, commits, archives, and names disk paths in chat. It does not judge a stage diff; `<template role="stage-validator">` does.</rule>
    <rule id="protocols">Planning follows user-wide `<planning_protocol>` and delivery follows `<implementation_protocol>`; this skill states only its specifics.</rule>
    <rule id="one-offer-each">Ask the planner and implementer offers at most once per campaign; reuse the choices recorded in campaign.md for every iteration and on resume.</rule>
    <rule id="spawn-apis">Per `<execution_protocol>`: `<template role="campaign-planner">` runs as {PLANNER}; `<template role="stage-implementer">` runs as {IMPLEMENTER}; `<template role="stage-validator">` runs as `executor="session-subagent"`; `<template role="stage-verifier">` and `<template role="repo-discovery">` run as `executor="default-worker"`.</rule>
    <rule id="no-planner-or-implementer-fallback">If a chosen planner or implementer, or the validator, cannot be spawned, the session does not take that role: it ends as `<signal code="BLOCKED">` naming the missing spawn, and the campaign stops through `<step id="4">` and records the block in `<step id="5">` without archival.</rule>
    <rule id="strictly-local">Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="pause-not-archive">Archive the campaign directory only after two consecutive NONE results. Budget exhaustion and host halt pause and commit resumable campaign.md; they do not remove it.</rule>
  </boundaries>
</skill>
