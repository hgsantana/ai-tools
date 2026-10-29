---
name: plan-ai-tools
description: >
  Plan and deliver one story. The session acts as PO to settle scope, resolve the
  implementer, and write the story, and a clean-context Planner writes the
  general plan. On approval the session orchestrates each task: a Task Planner
  details it, a single-task Implementer delivers it, and a clean-context
  Evaluator judges the diff against story and plan and commits, ending with a
  pull request. Given the slug of an existing plan, it goes straight to
  orchestration. Use for /plan-ai-tools.
argument-hint: "[story or feature description to plan, or slug of a plan to implement]"
---

<skill name="plan-ai-tools">
  <overview>
    Formulate a business user story, plan it, and deliver it. The session is Product Owner (PO) and orchestrator: it reviews repository documentation without reading application code, asks batched questions with recommended options, resolves the implementer, writes the story, and from then on only dispatches subagents and branches on their returns. Planning, execution, and validation belong to subagents, each dispatched by the session with clean context. One Planner, inheriting session model and effort, inspects the code in scope and writes the general plan: the overall architecture and the separation into atomic, independently committable tasks, with enough direction for each task to be detailed later. After the approved story and plan are committed to a dedicated plan branch, the Planner ends and the session offers implementation. For each task in order, the session dispatches one Task Planner to write the task file within the boundary the plan gave that task, then one Implementer of the story type to deliver code and tests, then one Evaluator, inheriting session model and effort, to judge the story, plan, and task file against the uncommitted git diff and the implementation report and commit approved work. Each Implementer lives for one delivery attempt, so rework goes to a fresh one; the Evaluator ends with its task. When a task exhausts its attempts the session asks the user for extra instructions or abort. Once every task is done, the session removes the plan directory, pushes the plan branch, and creates a pull request. Invoked with the slug of an existing plan, the session skips planning and goes straight to orchestration.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `Story` (User Story): Business-level structuring of the user request written to `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md` by the PO session, recording the implementer type.
      - `Plan`: General technical artifact written to `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md` by the Planner: overall architecture and task separation, with the task status table.
      - `Task`: Technical specification for a single atomic unit of work located at `docs/plan-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md`, written by the Task Planner.
      - `User`: Person interacting with the session.
      - `PO` (Product Owner): The interactive session itself. Focuses exclusively on repository documentation and business domain requirements without reading application code.
      - `Planner`: Clean-context subagent inheriting session model and effort; full-stack architect that inspects the code and writes the general plan.
      - `Task Planner`: Clean-context subagent inheriting session model and effort; details one task inside the boundary the plan gave it.
      - `Implementer`: Clean-context agent of the story implementer type, resolved per `<rule id="implementer-selection">`; lives for one delivery attempt per `<rule id="implementer-lifecycle">`.
      - `Evaluator`: Clean-context subagent inheriting session model and effort; adversarially reviews one task's delivery for defects and commits it when approved.
    </rule>

    <rule id="session-role">The session is PO and orchestrator only:
      - As PO it never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/) and resolves scope boundaries, business logic, user-facing behavior, and ambiguities.
      - If documentation is missing, outdated, or requires adjustments, the PO includes documentation adequacy as a mandatory story requirement.
      - As orchestrator it dispatches every subagent itself and branches solely on their returns per `<return_protocol>`; no subagent dispatches another. It writes no plan and no task file.
      - From the plan it reads only the task status table, to pick the next task. It never reads task files, diffs, or code to validate, rework, or re-judge a delivery; validation belongs to the Evaluator.
    </rule>

    <rule id="transient-docs">Story, plan, task files, and decisions belong under `docs/plan-ai-tools/{SLUG}/`. Raw tool outputs, binary caches, and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. In-repo plan files are committed along the workflow.</rule>

    <rule id="planner-question-rounds">If the Planner finds major discrepancies between the story and repository code, or a Task Planner finds that its task cannot be delivered inside the boundary the plan gave it, it sends batched questions with recommended options to the PO session, up to 3 rounds. The PO answers directly; decisions involving financial costs, irreversible data loss, or destructive operations are relayed to the user and await explicit confirmation. Settled answers are recorded in the "Decisions" section of the plan or of the task file.</rule>

    <rule id="clean-context-lifecycle">Every subagent is spawned with clean, zeroed context; continuity between them lives only in the plan directory and git history. The Planner ends once the plan is approved and committed. A Task Planner ends once it returns its task file. Every Implementer follows `<rule id="implementer-lifecycle">`: it ends on its return, and rework or a retry goes to a fresh one. The Evaluator of a task stays alive through its rework and its blocked escalation and is terminated once the task is approved or aborted; the next task gets a fresh one.</rule>

    <rule id="retry-and-blocked">A task allows up to 3 implementation attempts: the first delivery plus 2 reworks. When the third attempt fails validation, the Evaluator sets the task status to `blocked`, leaves that task's uncommitted changes in place for inspection, commits only the plan and task files, and returns `<signal code="TASK_BLOCKED">`. The session sends an atomic chat message linking the task file, then prompts the user via `<user_interaction>` to provide extra instructions for 3 additional attempts or abort.</rule>

    <rule id="finalization-and-pr">Once every task is `done`:
      - The session removes the plan directory (`git rm -r docs/plan-ai-tools/{SLUG}`) and commits with `chore(plan): complete {SLUG} delivery`.
      - The session pushes branch `plan/{SLUG}` to remote.
      - The session inspects `git log` difference against the base branch and creates a pull request formatted with a business overview followed by technical change highlights.
    </rule>
  </boundaries>

  <return_protocol>
    <signal code="TASK_PLANNED">Task Planner: task file written or revised; task status `working`.</signal>
    <signal code="TASK_DELIVERED">Implementer: changes and tests in the worktree, report appended to the task file; task status `validating`.</signal>
    <signal code="TASK_STOPPED">Implementer: the task file contradicts the codebase or a blocker prevents delivery; the line states it.</signal>
    <signal code="TASK_APPROVED">Evaluator: delivery approved and committed; task status `done`; worktree clean.</signal>
    <signal code="TASK_REWORK">Evaluator: delivery rejected with rework items appended to the task file; task status `retry` plus the next attempt number.</signal>
    <signal code="TASK_BLOCKED">Evaluator: third attempt rejected per `<rule id="retry-and-blocked">`; task status `blocked`.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="resolve-entry">
      Derive kebab-case {SLUG} from the argument, or from the active branch `plan/{SLUG}` when no argument is given. When `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md` and `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md` exist, the plan is already made: check out `plan/{SLUG}` and go straight to `<step id="12">`. Otherwise plan a new story from `<step id="2">`.
    </step>

    <step id="2" name="resolve-implementer">
      Set the {IMPLEMENTER} type per `<rule id="implementer-selection">`: `harness-default` unless the user's request names another.
    </step>

    <step id="3" name="po-doc-analysis">
      Session acts as PO per `<rule id="session-role">`: read repository documentation (README.md, AGENTS.md, docs/). Do not inspect application code. Evaluate user request feasibility from a business perspective. If documentation is lacking or outdated, mark documentation updates as a mandatory requirement.
    </step>

    <step id="4" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first). Resolve ambiguities, business rules, acceptance criteria, edge cases, and scope trade-offs. Repeat until all points are settled.
    </step>

    <step id="5" name="write-story">
      Write the finalized user story to `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md`. Include business context, scope boundaries, acceptance criteria, documentation requirements, and the {IMPLEMENTER} type as recorded per `<rule id="implementer-selection">`.
    </step>

    <step id="6" name="story-approval">
      Send an atomic chat message linking the story file, then prompt the user via `<user_interaction>` to approve it or request modifications. Iterate `<step id="4">` and `<step id="5">` until approved.
    </step>

    <step id="7" name="dispatch-planner">
      Announce the spawn in one chat line. Spawn `<template role="planner">` with clean zeroed context, inheriting session model and effort, with {ACTION} = plan, passing {SLUG}, {STORY_FILE} = `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md`, {PLAN_FILE} = `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md`, and empty {FEEDBACK}.
    </step>

    <step id="8" name="planner-clarifications">
      Answer the Planner's batched questions per `<rule id="planner-question-rounds">`, relaying critical decisions to the user, until the Planner returns the plan path.
    </step>

    <step id="9" name="plan-approval">
      Send an atomic chat message linking the plan and story files, then prompt the user via `<user_interaction>` to approve the plan or request modifications. On modifications, update {STORY_FILE} if necessary, dispatch the live Planner with {ACTION} = re-plan and {FEEDBACK} containing the user requests, and repeat this step until approved.
    </step>

    <step id="10" name="branch-and-commit">
      Create git branch `plan/{SLUG}` based on the current branch. Stage and commit only the story and plan files with Conventional Commit message `chore(plan): initialize plan and story for {SLUG}`. Terminate the Planner.
    </step>

    <step id="11" name="offer-implementation">
      Send an atomic chat message announcing that planning is finalized on branch `plan/{SLUG}`, with links to the story and plan. Then prompt the user via `<user_interaction>` offering to implement the plan now. If approved, proceed to `<step id="12">`; otherwise conclude the session, pointing out that invoking this skill with {SLUG} resumes at orchestration.
    </step>

    <step id="12" name="resolve-task">
      Read the {IMPLEMENTER} type from the story and the task status table from the plan, per `<rule id="session-role">`. Take the first task whose status is not `done` as {TASK_NUM} with its {TASK_SLUG}, set {TASK_FILE} = `docs/plan-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`, {ATTEMPT} = 1, and empty {FEEDBACK} and {REWORK_NOTES}:
      1. Every task `done`: proceed to `<step id="18">`.
      2. Status blank: proceed to `<step id="13">`.
      3. Status `blocked`: proceed to `<step id="17">`.
      4. Any other status, left by an interrupted run: the task file exists; proceed to `<step id="14">`, where the fresh Implementer takes the uncommitted changes as its starting point per `<rule id="implementer-lifecycle">`.
    </step>

    <step id="13" name="dispatch-task-planner">
      Announce the spawn in one chat line. Spawn `<template role="task-planner">` with clean zeroed context, inheriting session model and effort, with {ACTION} = detail-task, passing {SLUG}, {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and empty {FEEDBACK}. Answer its questions per `<rule id="planner-question-rounds">`. On `<signal code="TASK_PLANNED">`, terminate the Task Planner.
    </step>

    <step id="14" name="dispatch-implementer">
      Announce the spawn in one chat line. Spawn `<template role="implementer">` as one fresh agent of type {IMPLEMENTER}, resolved per `<rule id="implementer-selection">`, with clean zeroed context and {ACTION} = execute-task, or rework-task when {REWORK_NOTES} is non-empty, passing {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and {REWORK_NOTES}. When that type cannot be dispatched from this environment, report it to the user in one line and conclude, leaving the plan branch untouched. The Implementer ends on its return per `<rule id="implementer-lifecycle">`; branch on it:
      1. `<signal code="TASK_DELIVERED">`: proceed to `<step id="15">`.
      2. `<signal code="TASK_STOPPED">`: spawn a fresh `<template role="task-planner">` with {ACTION} = revise-task and {FEEDBACK} set to the Implementer's line, terminate it on `<signal code="TASK_PLANNED">`, then repeat this step with a fresh Implementer and the same {REWORK_NOTES}.
    </step>

    <step id="15" name="dispatch-evaluator">
      When the Evaluator of this task is alive, send it a new validation request with the current {ATTEMPT} and {FEEDBACK}. Otherwise announce the spawn in one chat line and spawn `<template role="evaluator">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {TASK_NUM}, {ATTEMPT}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and {FEEDBACK}.
    </step>

    <step id="16" name="evaluator-verdict">
      Wait for the Evaluator signal and branch per `<rule id="session-role">` without reading or validating anything:
      1. `<signal code="TASK_APPROVED">`: terminate the Evaluator per `<rule id="clean-context-lifecycle">` and return to `<step id="12">`.
      2. `<signal code="TASK_REWORK">`: increment {ATTEMPT}, set {REWORK_NOTES} pointing at the rework items in {TASK_FILE}, and return to `<step id="14">`.
      3. `<signal code="TASK_BLOCKED">`: proceed to `<step id="17">`.
    </step>

    <step id="17" name="blocked-escalation">
      Escalate per `<rule id="retry-and-blocked">`. On extra instructions, set {FEEDBACK} to them, {ATTEMPT} = 1, and {REWORK_NOTES} = {FEEDBACK}, and return to `<step id="14">`. On abort, terminate the Evaluator, leave branch `plan/{SLUG}` and the plan directory in place for inspection, and report the blocked task in one line.
    </step>

    <step id="18" name="plan-cleanup">
      Remove the plan directory via `git rm -r docs/plan-ai-tools/{SLUG}` and commit with `chore(plan): complete {SLUG} delivery` per `<rule id="finalization-and-pr">`.
    </step>

    <step id="19" name="push-and-pr">
      Push branch `plan/{SLUG}` to remote. Inspect git log diff against base branch and open a pull request formatted with a business overview followed by technical change highlights per `<rule id="finalization-and-pr">`. Send a one-line outcome with the pull request link.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="planner" executor="inherited">
      <job>Full-stack architect: inspect the code in scope, define the overall architecture, and separate one story into atomic, independently committable tasks that a Task Planner will detail later.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is plan:
        1. Read the story for {SLUG} from {STORY_FILE}.
        2. Inspect the files, modules, and dependencies in scope. Verify against actual code; do not assume. Identify existing points of extension and new components needed.
        3. If major discrepancies with {STORY_FILE} appear, send batched questions with recommended options to the PO session (up to 3 rounds).
        4. Write {PLAN_FILE} as a general plan: task status table with columns `#`, `Status` (blank, `working`, `validating`, `retry` plus attempt number, `blocked`, `done`), and `Task`; technical objective; overall architecture with a Mermaid diagram of the affected components; the tasks, each atomic, self-contained, and independently committable; a "Decisions" section recording resolved questions and choices.
        5. Give each task what a Task Planner with no other context needs to detail it: a technical summary, the acceptance criteria of the story it serves, its boundary (modules and areas inside it, and what is left to other tasks), its dependencies on earlier tasks, and the architectural direction to follow. Leave file-level changes, test behaviors, and implementation steps to the Task Planner.
        6. Return a one-line outcome with {PLAN_FILE}.

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, the existing {PLAN_FILE}, and {FEEDBACK}.
        2. Adjust the architecture, diagram, task separation, and decisions in {PLAN_FILE}.
        3. Return a one-line outcome with {PLAN_FILE}.
      </instructions>
      <constraints>
        <constraint>Plan only: write nothing but {PLAN_FILE}, change no code, and commit nothing.</constraint>
        <constraint>Do not make unverified code assumptions; verify against repository reality.</constraint>
      </constraints>
    </template>

    <template role="task-planner" executor="inherited">
      <job>Full-stack architect detailing one task of an approved plan into a specification a single implementer can deliver.</job>
      <input>
        <action>{ACTION}</action>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Keep the plan as written: settle task-level questions yourself and change no scope.
        When {ACTION} is detail-task:
        1. Read {STORY_FILE} and {PLAN_FILE} for plan {SLUG}: architecture, decisions, and task {TASK_NUM} with its summary, boundary, dependencies, and direction.
        2. Inspect the code inside the boundary of task {TASK_NUM}, plus what earlier tasks already committed. Verify against actual code; do not assume. Stay out of the areas the plan left to other tasks.
        3. If the task cannot be delivered inside its boundary, send batched questions with recommended options to the PO session (up to 3 rounds).
        4. Write {TASK_FILE}: technical objective, files to create or modify with expected changes, test behaviors to verify per change (unit tests for code; smoke tests, linters, or schema validations for non-code assets), suggested implementation steps without writing code, and a "Decisions" section.
        5. Set task {TASK_NUM} status to `working` in {PLAN_FILE}.
        6. Return one line with {TASK_FILE} ending with `<signal code="TASK_PLANNED">`.

        When {ACTION} is revise-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, the existing {TASK_FILE}, and {FEEDBACK}, the contradiction or blocker the Implementer reported.
        2. Verify it against actual code and correct {TASK_FILE} in place, recording the change under "Decisions".
        3. Return one line with {TASK_FILE} ending with `<signal code="TASK_PLANNED">`.
      </instructions>
      <constraints>
        <constraint>Detail only: write nothing but {TASK_FILE} and the status of task {TASK_NUM} in {PLAN_FILE}, change no code, and commit nothing.</constraint>
        <constraint>Do not make unverified code assumptions; verify against repository reality.</constraint>
      </constraints>
    </template>

    <template role="implementer" executor="implementer">
      <job>Single-task implementer: deliver code and tests for one task and report factual results without self-validation.</job>
      <input>
        <action>{ACTION}</action>
        <task_num>{TASK_NUM}</task_num>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <rework_notes>{REWORK_NOTES}</rework_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. The session that dispatched you is your only counterpart.
        When {ACTION} is execute-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM}. Take any uncommitted changes already in the worktree as your starting point.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities, stop immediately and return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Author tests covering the defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files) and run test suites and linters. Fix defects until all checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE}: changed files, tests written and executed, test and lint outcomes, and blockers. No self-evaluation.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit. Return one line with {TASK_FILE} ending with `<signal code="TASK_DELIVERED">`.

        When {ACTION} is rework-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, {TASK_FILE} with its reports and the feedback appended to it, and {REWORK_NOTES}. The uncommitted changes in the worktree are the previous attempt; rework them in place.
        2. Apply the requested fixes, re-run tests and linters, and fix new failures. If blocked, return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Append a rework summary to {TASK_FILE} and set task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        4. Do not commit. Return one line with {TASK_FILE} ending with `<signal code="TASK_DELIVERED">`.
      </instructions>
      <constraints>
        <constraint>Stay strictly within task scope and report factual results only, without local commits.</constraint>
      </constraints>
    </template>

    <template role="evaluator" executor="inherited">
      <job>Independent adversarial evaluator: hunt for defects in one task's delivery, beyond checking it against the story, the plan, and the task file, and commit it only when none remain.</job>
      <input>
        <slug>{SLUG}</slug>
        <task_num>{TASK_NUM}</task_num>
        <attempt>{ATTEMPT}</attempt>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. You own the verdict on task {TASK_NUM} of plan {SLUG}; nobody reviews it afterwards. You took no part in planning or implementing it: judge what is in the worktree, not what the report claims. The session sends this request once per attempt, with a new {ATTEMPT} each time.
        1. Read {STORY_FILE}, {PLAN_FILE}, and {TASK_FILE} with its implementation report. Treat a non-empty {FEEDBACK} as the user's extra instructions for this task.
        2. Read the uncommitted git diff and judge it against them: the delivery serves the story's acceptance criteria for this task, follows the plan's architecture and decisions, stays inside the task's scope, matches the report, and holds in quality.
        3. Review adversarially: assume the delivery hides defects until you have hunted them down, probing beyond the expected behavior for bugs and regressions, unhandled edge cases and boundary values, empty, null, and malformed input, misuse and malicious input, security flaws (injection, missing authorization, secret exposure, unsafe defaults), race conditions and partial failures, error handling, and scope creep or gaps. An unlikely but plausible failure in what the delivery touches is a defect.
        4. Verify that tests exist and genuinely verify the behaviors defined in {TASK_FILE}, failure paths and edge cases included, not only the happy path, and run the tests and linters yourself.
        5. Append observations, every defect found, and the verdict for attempt {ATTEMPT} to {TASK_FILE}.
        6. If approved: set task {TASK_NUM} status to `done` in {PLAN_FILE}, stage the task's files with the plan and task files, commit locally with a Conventional Commit message, leave the worktree clean, and return one line ending with `<signal code="TASK_APPROVED">`.
        7. If rejected and {ATTEMPT} is below 3: append specific rework items to {TASK_FILE}, set the status to `retry` plus the next attempt number, and return one line ending with `<signal code="TASK_REWORK">`.
        8. If rejected and {ATTEMPT} is 3: set the status to `blocked`, leave the task's uncommitted changes in place, commit only {PLAN_FILE} and {TASK_FILE}, and return one line naming {TASK_FILE} and ending with `<signal code="TASK_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Never fix or write task code yourself and never approve a delivery that lacks tests genuinely verifying the defined behaviors.</constraint>
        <constraint>Delivering what was expected is not enough: never approve while a defect, unhandled edge case, misuse path, or security flaw you found remains.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources, never touch files outside the plan scope.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
