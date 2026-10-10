---
name: implement-ai-tools
description: >
  Execute approved plans stage by stage through just-in-time specialist task
  planning, clean-context implementer code execution, and specialist validation,
  followed by git cleanup and pull request creation. Use for
  /implement-ai-tools.
argument-hint: "[slug of plan to implement]"
---

<skill name="implement-ai-tools">
  <overview>
    Execute approved plans stage by stage using just-in-time task planning, isolated code implementation, and strict specialist validation. For each task defined in `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md`, the session dispatches the designated Specialist with clean context to write `<N>-<slug-tarefa>.md`, dispatches the resolved Implementer with clean context to write code, execute tests, run linters, and record a factual report, and re-engages the Specialist to validate the delivery against the uncommitted git diff and commit on approval. Upon completing all tasks, the session removes the plan directory, commits the cleanup, pushes the plan branch, and creates a pull request.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `História` (User Story): Business requirements artifact located at `docs/plan-ai-tools/{SLUG}/historia-{SLUG}.md`.
      - `Plano` (Plan): Macro technical execution plan located at `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md`.
      - `Tarefa` (Task): Technical specification for a single atomic unit of work located at `docs/plan-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md`.
      - `Especialista` (Specialist): Subagent with clean zeroed context assigned to plan, advise, and validate a task per its domain.
      - `Validador` (Validator): The specialist when performing validation and committing the task.
      - `Implementer`: Subagent or session executor resolved per `<rule id="implementer-types">` to write code and tests.
    </rule>

    <rule id="specialist-summaries">Domain guidelines injected into specialist dispatches ({SPECIALIST_SUMMARY}):
      - `architect`: Modularity, clean architecture, dependency inversion, interface contracts, loose coupling, verifying assumptions against code.
      - `sec-eng`: Zero trust, input sanitization, authentication and authorization, secret hygiene, least privilege, OWASP Top 10 mitigations.
      - `devops-eng`: CI/CD automation, reproducible builds, containerization, environment configuration, infrastructure safety, observability.
      - `back-eng`: Domain modeling, business logic integrity, API contracts, robust error handling, performance optimization, transactional safety.
      - `front-eng`: Component isolation, accessible UI (WCAG), responsive design, predictable state management, bundle size awareness.
      - `data-eng`: Schema evolution, backward-compatible migrations, safe rollbacks, index optimization, query performance, data integrity.
      - `qa-eng`: Comprehensive test design, anti-happy-path, boundary values, negative test cases, mock isolation, coverage rigor.
      - `techwriter`: Accurate documentation matching real implementation, API references, user guides, ADRs, verification commands.
      - `ux-designer`: Intuitive flows, ergonomic interaction patterns, design system consistency, clear feedback and error messaging, accessibility.
    </rule>

    <rule id="clean-context-lifecycle">Specialist and Implementer instances are spawned with clean, zeroed context for each task. Both remain active exclusively while their task is underway (for queries, execution, and validation). Once a task is committed or finalized, both instances are terminated. No context carries over across distinct tasks.</rule>

    <rule id="implementer-rules">The Implementer executes under strict agnostic constraints:
      - Delivers strictly the scope defined in the task file, referencing the user story and general plan.
      - If blocked or if planned instructions contradict codebase realities, stops immediately and notifies the session (which consults the specialist).
      - Runs tests and static analysis linters, fixing defects until all checks pass.
      - Appends a concise, factual implementation report to the task file covering changed files, test/lint outcomes, obstacles, and resolved specialist decisions (no self-evaluation).
      - Updates task status to `validating` in `0-{SLUG}.md`.
      - Does not commit changes locally.
    </rule>

    <rule id="retry-and-blocked">Retry and escalation protocol:
      - The validator records review observations and verdict at the bottom of the task file.
      - On rework, the validator updates task status to `retry<1..3>` in `0-{SLUG}.md` and appends rework notes. The session dispatches the live implementer with rework instructions.
      - A task allows up to 3 attempts. If the third attempt fails, the validator sets status to `blocked` in `0-{SLUG}.md`.
      - On blocked status, the session sends an atomic chat message linking the task report.
      - After sending the announcement, the session prompts the user via `<user_interaction>` asking whether to provide extra instructions for 3 additional retries or abort.
    </rule>

    <rule id="finalization-and-pr">Upon completion of all tasks:
      - The session removes the plan directory (`git rm -r docs/plan-ai-tools/{SLUG}`) and commits with `chore(plan): complete {SLUG} delivery`.
      - The session pushes branch `plan/{SLUG}` to remote.
      - The session inspects `git log` difference against the base branch and creates a pull request formatted with a business overview followed by technical change highlights.
    </rule>
  </boundaries>

  <session_workflow>
    <step id="1" name="resolve-plan">
      Identify target {SLUG} from argument, active branch `plan/{SLUG}`, or workspace scan of `docs/plan-ai-tools/*/0-*.md`. Read `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md` and `docs/plan-ai-tools/{SLUG}/historia-{SLUG}.md`. Locate the first unexecuted or active task from the plan status table.
    </step>

    <step id="2" name="dispatch-task-planner">
      For task {TASK_NUM}, identify the assigned specialist role ({SPECIALIST_ROLE}) from `0-{SLUG}.md`. Spawn `<template role="specialist">` with clean zeroed context, {ACTION} = detail-task, passing {SLUG}, {TASK_NUM}, {TASK_SLUG}, {STORY_FILE} = `docs/plan-ai-tools/{SLUG}/historia-{SLUG}.md`, {PLAN_FILE} = `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md`, {TASK_FILE} = `docs/plan-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY} from `<rule id="specialist-summaries">`.
    </step>

    <step id="3" name="task-planning-wait">
      Specialist drafts {TASK_FILE} with technical objective, touched files list, Mermaid relationship diagram, and suggested implementation steps. If questions arise, specialist queries PO or Architect via session relay (up to 3 rounds). Specialist finishes and returns concise outcome with {TASK_FILE} link. Specialist remains active on standby.
    </step>

    <step id="4" name="dispatch-implementer">
      Update task status to `working` in `0-{SLUG}.md`. Resolve implementer type declared in `historia-{SLUG}.md` per `<rule id="implementer-types">`. Spawn `<template role="implementer">` with clean zeroed context, {ACTION} = execute-task, passing {SLUG}, {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and empty {REWORK_NOTES}.
    </step>

    <step id="5" name="implementer-execution-wait">
      Implementer executes changes, runs tests and linters, appends factual report to {TASK_FILE}, updates task status to `validating` in `0-{SLUG}.md`, and returns outcome with {TASK_FILE} link. If blocked, implementer notifies session, which consults the live specialist and relays guidance back.
    </step>

    <step id="6" name="dispatch-validator">
      Session sends validation request to the active Specialist with {ACTION} = validate-task, {SLUG}, {TASK_NUM}, {PLAN_FILE}, {TASK_FILE}, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY}.
    </step>

    <step id="7" name="validation-and-verdict">
      Specialist compares implementation report against uncommitted `git diff`:
      1. If approved: Specialist sets task status to `done` in `0-{SLUG}.md`, stages files, commits locally with Conventional Commit message, and returns approved outcome. Session terminates specialist and implementer, and advances to the next task (`<step id="2">`).
      2. If rework needed: Specialist sets status to `retry<1..3>` in `0-{SLUG}.md`, appends rework items to {TASK_FILE}, and returns rework outcome. Session dispatches the live implementer with {ACTION} = rework-task and {REWORK_NOTES} (looping back to `<step id="5">` up to 3 attempts).
      3. If 3 attempts exhausted: Specialist sets status to `blocked` in `0-{SLUG}.md`. Session sends an atomic chat message linking {TASK_FILE}, followed by an interactive prompt via `<user_interaction>` asking the user for extra instructions (+3 retries) or abort per `<rule id="retry-and-blocked">`.
    </step>

    <step id="8" name="plan-cleanup">
      When all tasks in `0-{SLUG}.md` reach `done`, remove the plan directory via `git rm -r docs/plan-ai-tools/{SLUG}` and commit with `chore(plan): complete {SLUG} delivery` per `<rule id="finalization-and-pr">`.
    </step>

    <step id="9" name="push-and-pr">
      Push branch `plan/{SLUG}` to remote. Inspect git log diff against base branch and open a pull request formatted with a business overview followed by technical change highlights per `<rule id="finalization-and-pr">`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="specialist" executor="inherited">
      <job>Domain specialist: task planning, architectural guidance, and delivery validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <task_slug>{TASK_SLUG}</task_slug>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <specialist_role>{SPECIALIST_ROLE}</specialist_role>
        <specialist_summary>{SPECIALIST_SUMMARY}</specialist_summary>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Act as {SPECIALIST_ROLE} applying domain principles: {SPECIALIST_SUMMARY}.
        When {ACTION} is detail-task:
        1. Read {STORY_FILE} and {PLAN_FILE} for plan {SLUG}, focusing on task {TASK_NUM} ({TASK_SLUG}).
        2. Inspect relevant repository code in scope. If ambiguities arise, query the PO or Architect via session relay (up to 3 rounds).
        3. Write {TASK_FILE} (`docs/plan-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`):
           - General task objective in technical terms.
           - List of files to create or modify, with brief description of expected changes.
           - Mermaid diagram illustrating relationships between affected components.
           - Suggested sequential implementation steps for the implementer (without writing code).
        4. Return concise outcome with link to {TASK_FILE}. Remain active on standby.

        When {ACTION} is validate-task:
        1. Read implementation report in {TASK_FILE} and compare against uncommitted git diff.
        2. Evaluate adherence to task specifications, test coverage, and domain quality ({SPECIALIST_SUMMARY}).
        3. Append review observations and verdict to {TASK_FILE}.
        4. If approved: update task {TASK_NUM} status to `done` in {PLAN_FILE}, stage files, commit locally with Conventional Commit message, and return approved outcome with {TASK_FILE}.
        5. If rework needed: update task {TASK_NUM} status to `retry<attempt>` (1..3) or `blocked` (if attempt exceeds 3) in {PLAN_FILE}, append specific rework instructions to {TASK_FILE}, and return rework outcome with {TASK_FILE}.
      </instructions>
      <constraints>
        <constraint>Maintain strict domain standards and never approve unverified or failing implementations.</constraint>
      </constraints>
    </template>

    <template role="implementer" executor="implementer">
      <job>Task implementer: deliver code, run tests, and report factual findings without self-validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <rework_notes>{REWORK_NOTES}</rework_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is execute-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM} of plan {SLUG}.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities, stop immediately and notify the session.
        3. Execute test suites and static analysis tools/linters. Fix defects until all tests and checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE} detailing changed files, test/lint outcomes, blockers encountered, and specialist decisions applied. Do not include self-evaluations.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit changes locally. Return concise outcome with link to {TASK_FILE}.

        When {ACTION} is rework-task:
        1. Read {REWORK_NOTES} and feedback appended to {TASK_FILE}.
        2. Apply requested fixes in place to affected files.
        3. Re-run tests and linters, fixing any new failures.
        4. Append rework summary to {TASK_FILE} and ensure task {TASK_NUM} status remains `validating` in {PLAN_FILE}.
        5. Do not commit changes locally. Return concise outcome with link to {TASK_FILE}.
      </instructions>
      <constraints>
        <constraint>Stay strictly within task scope and report factual results only without local commits.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
