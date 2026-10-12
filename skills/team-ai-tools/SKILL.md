---
name: team-ai-tools
description: >
  Run a full engineering team over one story. The session acts as PO to settle
  scope and write the story, an Architect subagent designs the architecture and
  decomposes the plan, and for each task a domain Specialist details it, a
  clean-context Implementer delivers code and tests, and the Specialist
  validates and commits, ending with git cleanup and a pull request. Use for
  /team-ai-tools.
argument-hint: "[story or feature description, or slug of a team plan to resume]"
---

<skill name="team-ai-tools">
  <overview>
    Plan and deliver one story with a team of specialist subagents. The session acts as the Product Owner (PO), reviewing repository documentation without reading application code, asking batched questions with recommended options, settling the implementer choice, and writing the story to disk. Once approved, the session dispatches an Architect subagent with clean context to perform technical code intake, draft the target architecture with Mermaid diagrams, decompose work into atomic tasks with assigned Specialists, and record architectural decisions. After plan approval, for each task the session dispatches the designated Specialist with clean context to write the task file detailing changes and required test behaviors, dispatches the resolved Implementer with clean context to write code, author and execute tests, run linters, and record a factual report, and re-engages the Specialist to validate the delivery against the uncommitted git diff and commit on approval. Upon completing all tasks, the session removes the plan directory, commits the cleanup, pushes the team branch, and creates a pull request.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `Story` (User Story): Business-level structuring of the user request written to `docs/team-ai-tools/{SLUG}/story-{SLUG}.md` by the PO session.
      - `Plan`: Technical artifact written to `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` decomposed into atomic tasks, guiding technical execution.
      - `Task`: Atomic, committable deliverable specified in `docs/team-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md` by a Specialist.
      - `Specialist`: Subagent dispatched with clean zeroed context and assigned a specific domain role to plan, advise, and validate a task.
      - `Validator`: The Specialist when reviewing task implementation against the uncommitted git diff and committing the task.
      - `User`: Person interacting with the session.
      - `PO` (Product Owner): The interactive session itself. Focuses exclusively on repository documentation and business domain requirements without reading application code.
      - `Architect`: Dispatched specialist subagent who designs architecture, creates the general plan `0-{SLUG}.md`, assigns specialists, and specifies architectural decisions.
      - `Implementer`: Subagent or session executor resolved per `<rule id="implementer-types">` to write code and tests for a task.
    </rule>

    <rule id="po-role">The session embodies the Product Owner role exclusively:
      - The PO never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/).
      - The PO resolves scope boundaries, business logic, user-facing behavior, and ambiguities.
      - If documentation is missing, outdated, or requires adjustments, the PO includes documentation adequacy as a mandatory story requirement.
    </rule>

    <rule id="implementer-selection">The first mandatory question asked by the PO before planning a new story resolves who will implement it:
      - `mid-level`: Mid-level tier of the current harness skill (`agy-ai-tools`, `claude-ai-tools`, `copilot-ai-tools`) - recommended.
      - `harness-default`: Default subagent worker of the current harness (Antigravity = Flash; Claude = Sonnet; Copilot = Gemini 3.8 Flash (Copilot)).
      - `session-subagent`: Subagent spawned with clean context inheriting current session model and effort.
      - `senior`: Senior tier of the current harness skill.
      - `junior`: Junior tier of the current harness skill.
      - `session`: The interactive session itself implements directly.
      The story file records only the resolved type name so that any harness executing the plan can resolve it dynamically via `<rule id="implementer-types">`.
    </rule>

    <rule id="specialists-catalog">Specialist roles available for task assignment in the macro plan, each with the domain guidelines injected into its dispatches ({SPECIALIST_SUMMARY}):
      - `architect`: Software architect — modularity, clean architecture, dependency inversion, interface contracts, loose coupling, verifying assumptions against code.
      - `sec-eng`: Senior security engineer — zero trust, threat modeling, input sanitization, authentication and authorization, secret hygiene, least privilege, OWASP Top 10 mitigations.
      - `devops-eng`: Senior DevOps engineer — CI/CD automation, reproducible builds, containerization, environment configuration, infrastructure safety, observability.
      - `back-eng`: Senior backend engineer — domain modeling, business logic integrity, API contracts, robust error handling, performance optimization, transactional safety.
      - `front-eng`: Senior frontend engineer — component isolation, accessible UI (WCAG), responsive design, predictable state management, client routing, bundle size awareness.
      - `data-eng`: Senior data engineer / DBA — schema evolution, backward-compatible migrations, safe rollbacks, index optimization, query performance, data integrity.
      - `qa-eng`: Senior QA and test engineer — comprehensive test design, anti-happy-path, boundary values, negative test cases, mock isolation, coverage rigor.
      - `techwriter`: Senior technical writer — accurate documentation matching real implementation, API references, user guides, ADRs, changelogs, verification commands.
      - `ux-designer`: Senior UX designer — intuitive flows, ergonomic interaction patterns, design system consistency, clear feedback and error messaging, microcopy, accessibility.
    </rule>

    <rule id="transient-docs">All user-facing artifacts, user stories, general plans, task files, and decisions belong under `docs/team-ai-tools/{SLUG}/`. Raw tool outputs, binary caches, and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. In-repo plan files are committed along the workflow.</rule>

    <rule id="architect-question-rounds">If the Architect encounters major discrepancies between the user story and repository code, it sends batched questions with recommended options to the PO session. The PO answers directly, up to a maximum of 3 rounds. If critical ambiguities remain after 3 rounds, the PO asks the user whether to continue for another 3 rounds. For critical decisions involving financial costs, irreversible data loss, or destructive operations, the PO relays the question directly to the user and awaits explicit confirmation before proceeding.</rule>

    <rule id="clean-context-lifecycle">Specialist and Implementer instances are spawned with clean, zeroed context for each task. Both remain active exclusively while their task is underway (for queries, execution, and validation). Once a task is committed or finalized, both instances are terminated. No context carries over across distinct tasks.</rule>

    <rule id="implementer-rules">The Implementer executes under strict agnostic constraints:
      - Delivers strictly the scope defined in the task file, referencing the user story and general plan.
      - If blocked or if planned instructions contradict codebase realities, stops immediately and notifies the session (which consults the specialist).
      - Authors tests covering specified behaviors (unit tests, smoke tests, schema checks, linters per task nature) and runs test suites, fixing defects until all checks pass.
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
      - The session removes the plan directory (`git rm -r docs/team-ai-tools/{SLUG}`) and commits with `chore(team): complete {SLUG} delivery`.
      - The session pushes branch `team/{SLUG}` to remote.
      - The session inspects `git log` difference against the base branch and creates a pull request formatted with a business overview followed by technical change highlights.
    </rule>
  </boundaries>

  <session_workflow>
    <step id="1" name="resolve-entry">
      Derive kebab-case {SLUG} from the argument. If `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` exists, or the active branch is `team/{SLUG}` holding that file, resume at `<step id="15">`. Otherwise start a new story at `<step id="2">`.
    </step>

    <step id="2" name="implementer-inquiry">
      Prompt the user via `<user_interaction>` with the mandatory first question to select the {IMPLEMENTER} type per `<rule id="implementer-selection">`.
    </step>

    <step id="3" name="po-doc-analysis">
      Session acts as PO per `<rule id="po-role">`: read repository documentation (README.md, AGENTS.md, docs/). Do not inspect application code. Evaluate user request feasibility from a business perspective. If documentation is lacking or outdated, mark documentation updates as a mandatory requirement.
    </step>

    <step id="4" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first). Resolve ambiguities, business rules, acceptance criteria, edge cases, and scope trade-offs. Repeat until all points are settled.
    </step>

    <step id="5" name="write-story">
      Write the finalized user story to `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`. Include business context, scope boundaries, acceptance criteria, documentation requirements, and the selected implementer type (as a type identifier, not a specific model).
    </step>

    <step id="6" name="story-approval">
      Send an atomic chat message to the user containing the link to the story file, as an independent step sent before requesting approval. Then prompt the user via `<user_interaction>` asking whether they approve the story or request modifications. If modifications are requested, iterate through `<step id="4">` and `<step id="5">` until approved.
    </step>

    <step id="7" name="dispatch-architect">
      Spawn `<template role="architect">` with clean zeroed context (inheriting session model and effort) with {ACTION} = macro-plan, passing {SLUG}, {STORY_FILE} = `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`, {PLAN_FILE} = `docs/team-ai-tools/{SLUG}/0-{SLUG}.md`, and empty {FEEDBACK}.
    </step>

    <step id="8" name="architect-planning">
      Architect reads {STORY_FILE}, inspects repository code in scope, identifies points of change, and drafts `0-{SLUG}.md`. The plan must contain:
      1. A task status table: `#`, `Status` (empty for unexecuted, `working`, `validating`, `retry<1..3>`, `blocked`, `done`), `Task` (name), and `Specialist` (assigned specialist from `<rule id="specialists-catalog">`).
      2. Technical objective.
      3. Mermaid target architecture diagram(s).
      4. Atomic, self-contained, and committable task list with summarized technical descriptions and assigned specialists.
      5. Architectural decisions and general rules.
    </step>

    <step id="9" name="architect-clarifications">
      If doubts arise, Architect sends batched questions with recommendations to the PO session per `<rule id="architect-question-rounds">`. Session answers or relays critical decisions to the user. All settled decisions are appended to the "Decisions" section of `0-{SLUG}.md`.
    </step>

    <step id="10" name="architect-handover">
      Architect concludes plan drafting, appends decisions, and replies to the session with: "Plan completed successfully: docs/team-ai-tools/{SLUG}/0-{SLUG}.md".
    </step>

    <step id="11" name="plan-announcement">
      Session outputs an atomic chat message to the user with: "Plan completed successfully: docs/team-ai-tools/{SLUG}/0-{SLUG}.md" along with the link to `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`.
    </step>

    <step id="12" name="plan-approval">
      Prompt the user via `<user_interaction>` asking whether they approve the plan or request modifications.
    </step>

    <step id="13" name="plan-iteration">
      If modifications are requested, update {STORY_FILE} if necessary, then dispatch the live Architect with {ACTION} = re-plan and {FEEDBACK} containing user requests. Repeat `<step id="11">` and `<step id="12">` until the user approves.
    </step>

    <step id="14" name="branch-and-commit">
      Upon plan approval, create git branch `team/{SLUG}` based on the current branch. Stage and commit `docs/team-ai-tools/{SLUG}/story-{SLUG}.md` and `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` with Conventional Commit message `chore(team): initialize plan and story for {SLUG}`. Proceed directly to `<step id="15">`.
    </step>

    <step id="15" name="resolve-task">
      Read `docs/team-ai-tools/{SLUG}/0-{SLUG}.md` and `docs/team-ai-tools/{SLUG}/story-{SLUG}.md`. Locate the first unexecuted or active task from the plan status table. When every task is `done`, proceed to `<step id="22">`.
    </step>

    <step id="16" name="dispatch-task-planner">
      For task {TASK_NUM}, identify the assigned specialist role ({SPECIALIST_ROLE}) from `0-{SLUG}.md`. Spawn `<template role="specialist">` with clean zeroed context, {ACTION} = detail-task, passing {SLUG}, {TASK_NUM}, {TASK_SLUG}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE} = `docs/team-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY} from `<rule id="specialists-catalog">`.
    </step>

    <step id="17" name="task-planning-wait">
      Specialist drafts {TASK_FILE} with technical objective, touched files list, test behaviors to verify per file/change (unit tests for code; smoke tests, linters, or schema validations for non-code files), Mermaid relationship diagram, and suggested implementation steps. If questions arise, specialist queries PO or Architect via session relay (up to 3 rounds). Specialist finishes and returns concise outcome with {TASK_FILE} link. Specialist remains active on standby.
    </step>

    <step id="18" name="dispatch-implementer">
      Update task status to `working` in `0-{SLUG}.md`. Resolve implementer type declared in `story-{SLUG}.md` per `<rule id="implementer-types">`. Spawn `<template role="implementer">` with clean zeroed context, {ACTION} = execute-task, passing {SLUG}, {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and empty {REWORK_NOTES}.
    </step>

    <step id="19" name="implementer-execution-wait">
      Implementer executes per `<rule id="implementer-rules">`: changes, tests and linters, factual report appended to {TASK_FILE}, task status `validating` in `0-{SLUG}.md`, and outcome with {TASK_FILE} link. If blocked, implementer notifies session, which consults the live specialist and relays guidance back.
    </step>

    <step id="20" name="dispatch-validator">
      Session sends validation request to the active Specialist with {ACTION} = validate-task, {SLUG}, {TASK_NUM}, {PLAN_FILE}, {TASK_FILE}, {SPECIALIST_ROLE}, and {SPECIALIST_SUMMARY}.
    </step>

    <step id="21" name="validation-and-verdict">
      Specialist compares implementation report against uncommitted `git diff`, explicitly verifying that tests were written and genuinely validate defined behaviors (unit tests, smoke tests, validation scripts, or pipeline checks per task type):
      1. If approved: Specialist confirms test presence and rigor, sets task status to `done` in `0-{SLUG}.md`, stages files, commits locally with Conventional Commit message, and returns approved outcome. Session terminates specialist and implementer per `<rule id="clean-context-lifecycle">`, and advances to the next task (`<step id="15">`).
      2. If rework needed (missing tests, superficial verification, defects, or domain deviation): Specialist sets status to `retry<1..3>` in `0-{SLUG}.md`, appends rework items to {TASK_FILE}, and returns rework outcome. Session dispatches the live implementer with {ACTION} = rework-task and {REWORK_NOTES} (looping back to `<step id="19">` up to 3 attempts).
      3. If 3 attempts exhausted: Specialist sets status to `blocked` in `0-{SLUG}.md`. Session sends an atomic chat message linking {TASK_FILE}, followed by an interactive prompt via `<user_interaction>` asking the user for extra instructions (+3 retries) or abort per `<rule id="retry-and-blocked">`.
    </step>

    <step id="22" name="plan-cleanup">
      When all tasks in `0-{SLUG}.md` reach `done`, remove the plan directory via `git rm -r docs/team-ai-tools/{SLUG}` and commit with `chore(team): complete {SLUG} delivery` per `<rule id="finalization-and-pr">`.
    </step>

    <step id="23" name="push-and-pr">
      Push branch `team/{SLUG}` to remote. Inspect git log diff against base branch and open a pull request formatted with a business overview followed by technical change highlights per `<rule id="finalization-and-pr">`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="architect" executor="inherited">
      <job>Software architect: macro architecture design, system modeling, task decomposition, architectural rules, and technical validation.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is macro-plan:
        1. Read user story for {SLUG} from {STORY_FILE}.
        2. Perform repository intake across files, modules, and dependencies in scope. Do not assume; verify actual code patterns.
        3. Identify existing points of extension and new components needed.
        4. If major discrepancies with {STORY_FILE} appear, send batched questions with recommended options to the PO session (up to 3 rounds).
        5. Write {PLAN_FILE}:
           - Task status table with columns: `#`, `Status` (initially blank), `Task`, `Specialist`.
           - Technical objective.
           - Mermaid architecture diagram(s) showing target modules, classes, and service boundaries.
           - Atomic task breakdown: each task must be self-sufficient and independently committable, with technical summary and assigned specialist (from architect, sec-eng, devops-eng, back-eng, front-eng, data-eng, qa-eng, techwriter, ux-designer).
           - Architectural decisions and general rules guiding specialists and implementers.
           - "Decisions" section recording resolved questions and choices.
        6. Return concise outcome: "Plan completed successfully: {PLAN_FILE}".

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, existing {PLAN_FILE}, and user {FEEDBACK}.
        2. Adjust architecture diagrams, task breakdown, specialist assignments, and decisions in {PLAN_FILE}.
        3. Return concise outcome: "Plan completed successfully: {PLAN_FILE}".
      </instructions>
      <constraints>
        <constraint>Adhere strictly to clean architecture, dependency inversion, and modularity principles.</constraint>
        <constraint>Do not make unverified code assumptions; verify against repository reality.</constraint>
      </constraints>
    </template>

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
        3. Write {TASK_FILE}:
           - General task objective in technical terms.
           - List of files to create or modify, with brief description of expected changes.
           - Test behaviors per file or change: concrete summary of expected behaviors to verify via unit tests (for application code) or suitable alternatives based on task nature (smoke tests, linter rules, schema validations, or integrity checks for non-code assets such as XML, JSON, markdown, CI pipelines, or configuration files).
           - Mermaid diagram illustrating relationships between affected components.
           - Suggested sequential implementation steps for the implementer (without writing code), explicitly including authoring tests and verifications for the defined behaviors.
        4. Return concise outcome with link to {TASK_FILE}. Remain active on standby.

        When {ACTION} is validate-task:
        1. Read implementation report in {TASK_FILE} and compare against uncommitted git diff.
        2. Verify that corresponding tests were actually written (e.g., unit tests for code; smoke tests, validation scripts, schema checks, or linters for non-code files, pipelines, or configs) and assert that they genuinely test the behaviors defined in {TASK_FILE} rather than superficial assertions.
        3. Evaluate adherence to task specifications, test coverage and execution results, code quality, and domain principles ({SPECIALIST_SUMMARY}).
        4. Append review observations and verdict to {TASK_FILE}.
        5. If approved: update task {TASK_NUM} status to `done` in {PLAN_FILE}, stage files, commit locally with Conventional Commit message, and return approved outcome with {TASK_FILE}.
        6. If rework needed (including missing tests, tests failing to verify defined behaviors, defects, or domain regressions): update task {TASK_NUM} status to `retry<attempt>` (1..3) or `blocked` (if attempt exceeds 3) in {PLAN_FILE}, append specific rework instructions to {TASK_FILE}, and return rework outcome with {TASK_FILE}.
      </instructions>
      <constraints>
        <constraint>Maintain strict domain standards and never approve implementations that lack required tests or fail to genuinely verify defined behaviors.</constraint>
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
        3. Author tests covering defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files per task specification) and execute test suites and static analysis linters. Fix defects until all tests and checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE} detailing changed files, tests written and executed, test/lint outcomes, blockers encountered, and specialist decisions applied. Do not include self-evaluations.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit changes locally. Return concise outcome with link to {TASK_FILE}.

        When {ACTION} is rework-task:
        1. Read {REWORK_NOTES} and feedback appended to {TASK_FILE}.
        2. Apply requested fixes in place to affected files, tests, or validation scripts.
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
