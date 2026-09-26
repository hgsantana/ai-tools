---
name: dev-ai-tools
description: >
  Execute a specified plan under plans/, or list pending plans, propose an
  order, and run them; or agree one task with the user. Use for /dev-ai-tools
  or after plan acceptance. Impact: edits code, runs commands, commits each
  step on a dedicated branch, archives the plan or task, pushes, and opens a
  pull request unattended once all steps finish. Agent: session + implementer.
argument-hint: "[plan paths, or the task to implement]"
---

<skill name="dev-ai-tools">
  <overview>
    Execute a specified plan under plans/{SLUG}/, a queue of pending plans, or one task agreed with the user.
    Task mode: the session plans and implements when the work fits one Conventional Commit. Specified and queue: the session judges each stage, commits, and opens the pull request; an implementer writes each stage; tests go to a default worker when that spawn works.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_mode">
      Verify repository root with `git rev-parse --show-toplevel`.
      Select mode based on input:
      - Specified (path like `plans/{SLUG}/`, `plans/{SLUG}.md`, or archived slug): before any mutation, locate the unit as `plans/{SLUG}/` or `plans/{SLUG}.md` if present; else look up `${TMPDIR:-/tmp}/ai-tools/finished/{SLUG}/` and the archive commit in Git history. Record {BASE_BRANCH} from the plan base or the request-time branch. If `plan/{SLUG}` already exists with accepted F stages, treat as resume: preserve those commits and skip initialization already completed. An archived slug with no recoverable branch or unit returns `<signal code="BLOCKED">`. Otherwise run `<step id="2">`, `<step id="3">`, and `<step id="4">` in this session.
      - Queue (empty or `plans`): find unfinished base plans (`plans/*/0-*.md`), propose execution order, then run `<step id="2">`, `<step id="3">`, and `<step id="4">` in this session for each accepted plan; continue on `<signal code="DELIVERED">`; stop on `<signal code="BLOCKED">` and do not advance the queue.
      - Task (anything else): agree one task interactively with the user in their language, exploring the codebase before asking and interviewing one question at a time through USER-AGENTS `<user_interaction>` with recommended answers to resolve scope boundaries and design decisions. If it does not fit one Conventional Commit, present `plan-ai-tools` or `vibe-ai-tools` stating that skill's Impact and Agent from its description, obtain acceptance, and invoke it without re-entering USER-AGENTS `<routing_gate>`; on refusal, end with a short assessment and write no task file. If it fits, write `plans/{SLUG}.md`, then run `<step id="2">`, `<step id="3">`, and `<step id="4">` in this session.
    </step>

    <step id="2" name="branch_and_record">
      Read the unit of work and the repository rules (README.md, AGENTS.md if present).
      On a new unit: check out `plan/{SLUG}` from {BASE_BRANCH} and commit the unit first: `chore(plans): plan {SLUG}` (or `chore(plans): task {SLUG}`).
      On resume: stay on `plan/{SLUG}`, preserve accepted commits, and skip that first plan or task commit.
    </step>

    <step id="3" name="stage_loop">
      For each unfinished stage in dependency order (a task is one stage), following `<status_protocol>`:
        1. In specified and queue modes: if the stage is not yet planned (status empty or resumed at P): set P in the base plan Status table, spawn `<template role="stage-planner">` from `<dispatch_templates>` as executor="session-subagent", substituting {STAGE_FILE} and {SLUG}; if that spawn fails, treat the unit as `<signal code="BLOCKED">`. The planner writes {STAGE_FILE} with detailed steps, tests, and acceptance criteria, sets PF in the Status table, and returns `<signal code="PLANNED">`. (In Task mode, planning is already complete in `plans/{SLUG}.md`.)
        2. Set W and record the stage's Executor in the base plan Status table.
        3. Task mode: the session implements the stage (code and behaviour tests within its declared files, matching surrounding style, with factual notes in its Implementation log) and sets V, then spawns `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic; if that spawn fails, the session runs the commands itself. Specified and queue: spawn `<template role="stage-implementer">` from `<dispatch_templates>` as executor="implementer" with the harness default model, substituting {STAGE_FILE} and {SLUG}; if that spawn fails, treat the unit as `<signal code="BLOCKED">` without implementing the stage in the session.
        4. After `<template role="stage-verifier">` runs, spawn `<template role="stage-judge">` from `<dispatch_templates>` as executor="session-subagent", substituting {STAGE_FILE}, {SLUG}, and kebab-case {TOPIC}; if that spawn fails, treat the unit as `<signal code="BLOCKED">` without judging in the session.
        5. On `<signal code="ACCEPT">`: stage path by path, commit with the stage's Conventional Commit message, and set F.
        6. On `<signal code="REWORK">`: append the judge's feedback tasks to the stage log, set R1..R3, and retry the implementer spawn up to three times, then set E.
      On E: stop remaining stages, retain the work unit, and go to `<step id="4">` as blocked. Do not start a dependent stage.
      Interrupt the user only for a blocker, a decision uncovered by implementation, or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>

    <step id="4" name="archive_and_deliver">
      Successful completion is every required stage F. Only then: copy the unit to ${TMPDIR:-/tmp}/ai-tools/finished/{SLUG}, remove it with `git rm -r plans/{SLUG}` (or `git rm plans/{SLUG}.md`), commit `chore(plans): archive {SLUG}`, push `plan/{SLUG}`, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write ${TMPDIR:-/tmp}/ai-tools/{SLUG}-review.patch when no host is available, write ${TMPDIR:-/tmp}/ai-tools/{SLUG}-report.md, and treat the outcome as `<signal code="DELIVERED">`.
      If any required stage is E, an implementer spawn is missing, or a reserved approval is pending: retain the unit, do not archive, push, or open a pull request, write evidence to ${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md, and treat the outcome as `<signal code="BLOCKED">`. Partial delivery is not authorized.
    </step>

    <step id="5" name="report_and_handover">
      In chat (user's language), provide the report or evidence path, a one-line outcome, and the PR URL or review patch path.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="stage-planner" executor="session-subagent">
      <job>Stage planner: inspect repository state and write detailed stage file for one stage.</job>
      <input>
        <stage_file>{STAGE_FILE}</stage_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read base plan plans/{SLUG}/0-{SLUG}.md and the repository rules (README.md, AGENTS.md if present).
        Inspect the working tree and commit history after previous stages. Expand {STAGE_FILE}'s succinct outline from the base plan into a detailed stage file under plans/{SLUG}/{STAGE_FILE}: Objective, Decisions, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, Commit message, Dependencies, and Implementation log.
        Resolve in-scope design decisions from repository evidence and base plan intent without conducting user interviews; record decisions in the stage file.
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
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`. Include `<template role="stage-verifier">` from this file in the brief.
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

    <template role="stage-judge" executor="session-subagent">
      <job>High-tier judge: evaluate working-tree diff, test output, and acceptance criteria to deliver an objective verdict.</job>
      <input>
        <stage_file>{STAGE_FILE}</stage_file>
        <slug>{SLUG}</slug>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Read {STAGE_FILE} of plans/{SLUG}/ and repository rules. Inspect the working-tree git diff and verification logs in ${TMPDIR:-/tmp}/ai-tools/{TOPIC}-output.log. Write detailed verdict rationale and any required corrections to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}-verdict.md. Return either `<signal code="ACCEPT">` or `<signal code="REWORK">`.
      </instructions>
      <constraints>
        <constraint>Do not modify production code or tests.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="PLANNED">PLANNED {STAGE_FILE}</signal>
    <signal code="ACCEPT">ACCEPT {STAGE_FILE} {VERDICT_PATH}</signal>
    <signal code="REWORK">REWORK {STAGE_FILE} {VERDICT_PATH}</signal>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_OR_PATCH}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <status_protocol>
    The session owns every state except PF and V. The session sets P before stage planning and W before implementation starts. The planner sets PF once {STAGE_FILE} is written. The implementer sets V once the stage is ready for review; in Task mode the session sets V after it implements. In campaign-ai-tools, the session applies F, R1..R3, and E from the campaign-planner VALIDATE `<signal>` without judging the diff.
    On resume: a stage at P resumes with `<template role="stage-planner">`; a stage at PF or W resumes with `<template role="stage-implementer">`.
    <states>
      <state code="P">Planning - set by the session before detailed stage planning starts</state>
      <state code="PF">Planning Finished - set by the planner once the detailed stage file is written</state>
      <state code="W">Working - set by the session before implementation starts</state>
      <state code="V">Validating - set by whoever implemented the stage once it is ready for review</state>
      <state code="R1..R3">Rework - corrections after review</state>
      <state code="T">Testing - verification running</state>
      <state code="E">Exhausted - correction budget exceeded; maps to BLOCKED, never to delivery</state>
      <state code="F">Finished - accepted and committed</state>
    </states>
  </status_protocol>

  <boundaries>
    <rule id="session-owns-delivery">The session owns intake, judgment, commits, archival, the pull request, and reporting from disk paths.</rule>
    <rule id="task-interview">In Task mode, resolve scope and design decisions with the user one question at a time through USER-AGENTS `<user_interaction>`, exploring the codebase before asking and providing recommended answers.</rule>
    <rule id="task-is-one-commit">Task mode implements in the session only when the work fits one Conventional Commit; larger work is offered to plan-ai-tools or vibe-ai-tools.</rule>
    <rule id="no-implementer-fallback">If `<template role="stage-planner">` or `<template role="stage-implementer">` cannot be spawned, specified and queue modes do not plan or implement that stage in the session: they end as `<signal code="BLOCKED">` naming the missing spawn.</rule>
    <rule id="worker-fallback">If `<template role="stage-verifier">` cannot be spawned, the spawning context runs those commands itself per USER-AGENTS `<rule id="spawn-fallback">`.</rule>
    <rule id="completion-is-f">Archive, push, and pull-request creation run only when every required stage is F. An E stage is BLOCKED and retains the work unit.</rule>
    <rule id="substance-on-disk">Write substance to the unit's files or OS temp (${TMPDIR:-/tmp}/ai-tools); chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>`: `<template role="stage-planner">` and `<template role="stage-judge">` run as `executor="session-subagent"` on the session model; `<template role="stage-implementer">` runs as `executor="implementer"` with the harness default model; `<template role="stage-verifier">` runs as `executor="default-worker"`.</rule>
  </boundaries>
</skill>
