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
    The session aligns scope with the user, directs iterations on disk, and commits locally on `improve/{CAMPAIGN}`: a session-subagent planner writes each plan base and validates diffs, while implementers deliver stage code. Chat names paths only.
  </overview>

  <session_workflow>
    <step id="1" name="campaign_initialization">
      Resolve kebab-case {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS} via `<user_interaction>` per `<planning_protocol>`.
      Verify repository root with `git rev-parse --show-toplevel`.
      Recovery check: if `plans/improve/{CAMPAIGN}/campaign.md` exists on `improve/{CAMPAIGN}` or can be restored, resume it (preserve branch, last accepted stage, last iteration, and recorded model). Otherwise, check out `improve/{CAMPAIGN}` from a clean base branch and initialize `plans/improve/{CAMPAIGN}/campaign.md` with goals, priorities, exclusions, and active status.
      Resolve {IMPLEMENTER_MODEL}: reuse the recorded model in campaign.md; if none, check `config.local.json` (`ask_implementer_model`), or ask the user once through `<user_interaction>` per `<implementer_job>` and record the choice in campaign.md.
      Commit campaign start or resume: `chore(plans): start campaign {CAMPAIGN}` or `chore(plans): resume campaign {CAMPAIGN}`.
    </step>

    <step id="2" name="plan">
      Spawn `<template role="campaign-planner">` from `<dispatch_templates>` as executor="session-subagent" with {MODE} set to PLAN, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and empty {STAGE_FILE}.
      Record only the `<signal>` from `<return_protocol>`. Name the plan path in chat without opening the directory.
      Two consecutive `<signal code="NONE">` outcomes cleanly terminate the campaign.
      If the planner cannot be spawned, treat the campaign as `<signal code="BLOCKED">`.
    </step>

    <step id="3" name="stage_loop">
      On `<signal code="PLAN">` or `<signal code="RESUME">`, stay on `improve/{CAMPAIGN}`. Commit the plan first if uncommitted: `chore(plans): plan` plus the directory name.
      For each unfinished stage in dependency order per `<status_protocol>`:
        1. If unplanned (status empty or resumed at P): set P, spawn `<template role="campaign-planner">` from `<dispatch_templates>` as executor="session-subagent" with {MODE} set to STAGE-PLAN, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and {STAGE_FILE}; if spawn fails, treat as `<signal code="BLOCKED">`.
        2. Set W and record Executor as implementer plus {IMPLEMENTER_MODEL} in the base plan Status table.
        3. Spawn `<template role="stage-implementer">` from `<dispatch_templates>` as executor="implementer" with {IMPLEMENTER_MODEL}, substituting {STAGE_FILE} and {CAMPAIGN}; if rejected for that model, retry once with harness default; if spawn fails, treat as `<signal code="BLOCKED">`.
        4. Spawn `<template role="campaign-planner">` as executor="session-subagent" with {MODE} set to VALIDATE, substituting {CAMPAIGN}, {PRIORITIES}, {EXCLUSIONS}, and {STAGE_FILE}. Pass paths only without assembling a diff.
        5. On `<signal code="ACCEPT">`: commit with stage's Conventional Commit and set F. On `<signal code="REWORK">`: set R1..R3 and retry implementer up to 3 times (reading `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md`), then set E. On `<signal code="BLOCKED">` from VALIDATE: set E.
      On E: stop remaining stages, retain plan, and go to `<step id="5">` as blocked.
      On all stages F: archive plan to `${TMPDIR:-/tmp}/ai-tools/finished/`, remove with `git rm -r`, commit `chore(plans): archive` plus slug, record iteration file in `plans/improve/{CAMPAIGN}/iterations/`, update campaign.md with last accepted stage and iteration {N}, and commit `chore(plans): record campaign {CAMPAIGN} iteration {N}`.
    </step>

    <step id="4" name="iteration_loop">
      Repeat `<step id="2">` with a new PLAN spawn.
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
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` in campaign.md, and name that path in chat. When a spawn is rejected for the recorded model, retry once with harness default and record the model used in the iteration file. When the planner or implementer cannot be spawned, `<rule id="no-planner-or-implementer-fallback">` applies.
  </implementer_job>

  <dispatch_templates>
    <template role="campaign-planner" executor="session-subagent">
      <job>Campaign planner: in PLAN mode, write base plan with succinct stages; in STAGE-PLAN mode, detail one stage file; in VALIDATE mode, judge one stage from the working-tree diff.</job>
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
        When {MODE} is VALIDATE: read {STAGE_FILE} and inspect `git diff` against HEAD on `improve/{CAMPAIGN}`. Judge whether diff meets acceptance criteria, write verdict to `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-validate.md`, and return `<signal code="ACCEPT">`, `<signal code="REWORK">`, or `<signal code="BLOCKED">`. Do not edit product code or commit.
      </instructions>
      <constraints>
        <constraint>Do not push or touch remote repository.</constraint>
        <constraint>PLAN does not edit product or test code; VALIDATE edits only the verdict file.</constraint>
        <constraint>If a default-worker spawn fails, run that discovery yourself per `<rule id="spawn-fallback">`.</constraint>
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
        <constraint>Do not commit or push; leave changes in working tree for planner VALIDATE.</constraint>
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
    <rule id="session-mediates">The session iterates scope, owns the implementer question, commits, archives, and names disk paths in chat. It does not judge a stage diff; VALIDATE does.</rule>
    <rule id="one-model-question">Ask the implementer model question at most once per campaign; reuse the model recorded in campaign.md for every iteration and on resume.</rule>
    <rule id="spawn-apis">Per `<execution_protocol>`: `<template role="campaign-planner">` runs as `executor="session-subagent"` on the session's own model; `<template role="stage-implementer">` runs as `executor="implementer"` with the recorded {IMPLEMENTER_MODEL}, or harness default per `<implementer_job>` when the API cannot select a model; `<template role="stage-verifier">` and `<template role="repo-discovery">` run as `executor="default-worker"`.</rule>
    <rule id="no-planner-or-implementer-fallback">If the planner or implementer cannot be spawned, the session does not take that role: it ends as `<signal code="BLOCKED">` naming the missing spawn, and the campaign stops through `<step id="4">` and records the block in `<step id="5">` without archival.</rule>
    <rule id="strictly-local">Work is strictly local: no push, fetch, PR, deployment, or remote mutation.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="pause-not-archive">Archive the campaign directory only after two consecutive NONE results. Budget exhaustion and host halt pause and commit resumable campaign.md; they do not remove it.</rule>
  </boundaries>
</skill>
