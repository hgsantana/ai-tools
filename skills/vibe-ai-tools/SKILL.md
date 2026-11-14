---
name: vibe-ai-tools
description: >
  Formulate a story interactively, spec first, then deliver it unattended. The
  session, as PO, writes the requirements into the spec and the story with the
  user, then owns every technical decision, prioritizing zero-cost and easily
  reversible options, and orchestrates a Planner, then per task a Task Planner,
  an Implementer, and an Evaluator that judges against the spec and commits. An
  Acceptor checks the whole branch against the spec before the PR. Use for
  /vibe-ai-tools.
argument-hint: "[story or feature description to plan and implement]"
---

<skill name="vibe-ai-tools">
  <overview>
    Refine one story with the user, then deliver it unattended, spec first. The session acts as Product Owner (PO) during story refinement, clarifying scope, business rules, and requirements with the user, writing the requirements into the spec and the change into the story, and resolving the implementer. From story approval onward the session is an autonomous orchestrator that owns every technical decision, strictly prioritizing zero-cost and easily reversible choices. Planning, execution, and validation belong to subagents, each dispatched by the session with clean context. One Planner, inheriting session model and effort, inspects the code in scope, questions what the spec leaves unverifiable, and writes the general plan: the overall architecture, the constraints and verification commands, the separation into atomic, independently committable tasks, and the coverage of every requirement by a task, with enough direction for each task to be detailed later. The session checks that plan against the story and the spec and approves it itself, commits story, spec, and plan together to a dedicated branch, and the Planner ends. For each task in order, the session dispatches one Task Planner to write the task file within the boundary the plan gave that task, then one Implementer of the story type to deliver code and tests, then one Evaluator, inheriting session model and effort, to judge the diff scenario by scenario against the spec, the plan, and the task file and the implementation report, and commit approved work. Each Implementer lives for one delivery attempt, so rework goes to a fresh one; the Evaluator ends with its task. Once every task is done, an Acceptor judges the whole branch against the spec and sends gaps back through the task loop; the session then removes the plan directory, keeps the spec, pushes the branch, and creates a pull request carrying the acceptance table and every amendment.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `Spec`: Requirements and scenarios, the authority on behavior, in `{SPEC_DIR}/{CAPABILITY}.md` per `<rule id="spec-format">`, written by the PO session.
      - `Story` (User Story): The change, in `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, written by the PO session: context, the requirement IDs it adds, changes, or removes, scope, and the implementer type.
      - `Plan`: General technical artifact written to `docs/vibe-ai-tools/{SLUG}/0-{SLUG}.md` by the Planner: overall architecture and task separation, with the task status table.
      - `Task`: Technical specification for a single atomic unit of work located at `docs/vibe-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md`, written by the Task Planner.
      - `User`: Person interacting with the session.
      - `PO` (Product Owner): The interactive session during story refinement. Focuses exclusively on repository documentation and business domain requirements without reading application code.
      - `Planner`: Clean-context subagent inheriting session model and effort; full-stack architect that inspects the code and writes the general plan.
      - `Task Planner`: Clean-context subagent inheriting session model and effort; details one task inside the boundary the plan gave it.
      - `Implementer`: Clean-context agent of the story implementer type, resolved per `<rule id="implementer-selection">`; lives for one delivery attempt per `<rule id="implementer-lifecycle">`.
      - `Evaluator`: Clean-context subagent inheriting session model and effort; adversarially reviews one task's delivery for defects and commits it when approved.
      - `Acceptor`: Clean-context subagent inheriting session model and effort; judges the whole branch against the spec before the pull request.
    </rule>

    <rule id="spec-format">Requirements live in spec files, the authority on behavior:
      - {SPEC_DIR} is the spec directory the repository keeps: `docs/specs`, or its own, in the format and identifiers already used there. When the repository keeps none, a spec policy its documentation settles is followed; otherwise the PO asks the user once during story refinement whether to keep one at `docs/specs`. Without a kept spec, {SPEC_DIR} is `docs/vibe-ai-tools/{SLUG}/specs`, removed with the plan directory.
      - One file per capability, a kebab-case area of behavior, `{SPEC_DIR}/{CAPABILITY}.md`, states current behavior: a one-paragraph purpose, then one `### R{N}. {NAME}` heading per requirement holding one sentence of observable behavior ("The system must ...") and its scenarios as `- R{N}.S{M} Given ..., when ..., then ...` lines, with a failure scenario wherever failure is possible.
      - IDs are unique within a file and never renumbered or reused; outside its file an ID carries the capability: `{CAPABILITY}/R{N}.S{M}`.
      - A story edits these files in place, so the diff of {SPEC_DIR} against the base branch is the change. Existing behavior the change must not break, when no requirement states it yet, is written as a requirement too. Every requirement of a touched file that the story leaves unchanged is preserved behavior.
      - Spec files state behavior only, free of implementation detail and vague qualifiers; an unsettled point is marked `[NEEDS CLARIFICATION: question]` until settled.
    </rule>

    <rule id="story-format">The story states one change, in these sections:
      - `Context and goal`: who needs what, and why.
      - `Requirements`: per spec file, its repository-relative path and the IDs this story adds, changes, or removes, marking `existing` an added requirement that documents current behavior.
      - `Out of scope`: explicit non-goals.
      - `Delivery`: the {IMPLEMENTER} type per `<rule id="implementer-selection">` and {BASE_BRANCH}, the branch current when the story is written.
      - When they apply: `Constraints` (imposed limits and measurable thresholds), `Documentation` (durable documents other than the spec that must reflect the change), `Assumptions and clarifications` (defaults assumed and questions settled with the user), and `Amendments` (changes after approval per `<rule id="spec-authority">`: what, why, and who decided, the session or the user).
    </rule>

    <rule id="story-quality">Before each approval request the PO verifies and corrects until all hold: every requirement the story adds or changes states one observable behavior and has at least one scenario; the story is one independently deliverable outcome, else the PO proposes a split to the user; no `[NEEDS CLARIFICATION]` marker remains.</rule>

    <rule id="spec-authority">The spec is the authority on behavior and the story on the scope of this change, after approval too:
      - A decision that adds, changes, or removes observable behavior is an amendment, whatever raised it: a Planner or Task Planner question, a blocked task, or an acceptance gap. The session decides it per `<rule id="autonomous-decision-policy">`, edits the spec files, updates `Requirements` in the story, and logs it under `Amendments` as a deviation from what the user approved. The pull request lists every amendment.
      - When an amendment changes which requirements need a task, the session has the Planner re-plan with {ACTION} = re-plan and the amendment as its feedback: the live Planner before the plan is committed, afterwards a fresh `<template role="planner">` that ends on its return.
      - When branch `vibe/{SLUG}` exists, the session then commits only the spec files, the story, and the plan with `docs(spec): amend {SLUG}`.
      - A decision that leaves behavior unchanged stays in the "Decisions" section of the plan or of the task file.
    </rule>

    <rule id="session-role">The session is PO, then autonomous orchestrator:
      - As PO it never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps) and resolves scope boundaries, business logic, user-facing behavior, and ambiguities with the user.
      - If documentation is missing, outdated, or requires adjustments, the PO includes its update as a mandatory `Documentation` item of the story.
      - As orchestrator it dispatches every subagent itself and branches solely on their returns per `<return_protocol>`; no subagent dispatches another. It writes no plan and no task file.
      - It reads the plan to approve it against the story and the spec and to pick the next task, a blocked task file to recover it, and the acceptance sections to recover a blocked story and to write the pull request. It never reads diffs or code to validate, rework, or re-judge a delivery; validation belongs to the Evaluator and the Acceptor.
    </rule>

    <rule id="autonomous-decision-policy">Autonomous decision authority and escalation threshold:
      - Following user story approval in `<step id="5">`, the session assumes total responsibility for all subsequent technical decisions.
      - For all questions, trade-offs, or doubts raised by the Planner or a Task Planner, the session decides autonomously without consulting the user.
      - Core decision criterion: prioritize options that carry zero financial cost and ensure easy backup and reversibility for critical issues.
      - Escalation threshold: the session pauses to query the user via `<user_interaction>` only if neither zero-cost nor easily reversible options are possible (e.g., unavoidable paid third-party services, irreversible data loss, or destructive infrastructure actions).
      - Technical decisions and settled trade-offs are explicitly recorded in the "Decisions" section of `0-{SLUG}.md` or of the task file, by the subagent that asked; decisions that change behavior follow `<rule id="spec-authority">`.
    </rule>

    <rule id="transient-docs">Story, plan, task files, and decisions belong under `docs/vibe-ai-tools/{SLUG}/`. A kept spec lives in {SPEC_DIR}, outside that directory, and survives its removal. Raw tool outputs, binary caches, and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. In-repo plan files are committed along the workflow.</rule>

    <rule id="clean-context-lifecycle">Every subagent is spawned with clean, zeroed context; continuity between them lives only in the plan directory and git history. The Planner ends once the plan is approved and committed. A Task Planner ends once it returns its task file. Every Implementer follows `<rule id="implementer-lifecycle">`: it ends on its return, and rework or a retry goes to a fresh one. The Evaluator of a task stays alive through its rework and its blocked recovery and is terminated once the task is approved or aborted; the next task gets a fresh one. Each acceptance round gets a fresh Acceptor, which ends on its return.</rule>

    <rule id="retry-and-blocked">A task allows up to 3 implementation attempts: the first delivery plus 2 reworks. When the third attempt fails validation, the Evaluator sets the task status to `blocked`, leaves that task's uncommitted changes in place for inspection, commits only the plan and task files, and returns `<signal code="TASK_BLOCKED">`. The session first attempts one autonomous recovery per task: it reads the blocked task file, writes extra instructions per `<rule id="autonomous-decision-policy">`, and grants 3 additional attempts. If the task blocks again or recovery is impossible, the session sends an atomic chat message linking the task file, then prompts the user via `<user_interaction>` to provide extra instructions for 3 additional attempts or abort. A task whose Implementer stops 3 times is recovered or escalated the same way.</rule>

    <rule id="story-acceptance">Once every task is `done`, a fresh Acceptor judges the whole branch against the spec and the story. On gaps it appends convergence tasks to the plan and the session runs them through the task loop, for at most 2 convergence rounds. When the third acceptance still finds a gap, the Acceptor returns `<signal code="STORY_BLOCKED">`. The session first attempts one autonomous recovery per story: it reads the last acceptance section of the plan, writes extra instructions per `<rule id="autonomous-decision-policy">`, amending the spec per `<rule id="spec-authority">` when a requirement cannot hold, and grants 3 more acceptance rounds. If the story blocks again, the session sends an atomic chat message linking the plan, then prompts the user via `<user_interaction>` to provide extra instructions for 3 more acceptance rounds or abort.</rule>

    <rule id="finalization-and-pr">Once the story is accepted:
      - The session copies the last acceptance table and the "Decisions" of the plan and the `Amendments` of the story to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`.
      - The session removes the plan directory (`git rm -r docs/vibe-ai-tools/{SLUG}`) and commits with `chore(vibe): complete {SLUG} delivery`; a kept spec stays.
      - The session pushes branch `vibe/{SLUG}` to remote.
      - The session inspects `git log` difference against {BASE_BRANCH} and creates a pull request formatted with a business overview, the acceptance table, the amendments, marking those the session decided as deviations from the approved story, the decisions, and technical change highlights.
    </rule>
  </boundaries>

  <return_protocol>
    <signal code="TASK_PLANNED">Task Planner: task file written or revised; task status `working`.</signal>
    <signal code="TASK_DELIVERED">Implementer: changes and tests in the worktree, report appended to the task file; task status `validating`.</signal>
    <signal code="TASK_STOPPED">Implementer: the task file contradicts the codebase or the spec, or a blocker prevents delivery; the line states it.</signal>
    <signal code="TASK_APPROVED">Evaluator: delivery approved and committed; task status `done`; worktree clean.</signal>
    <signal code="TASK_REWORK">Evaluator: delivery rejected with rework items appended to the task file; task status `retry` plus the next attempt number.</signal>
    <signal code="TASK_BLOCKED">Evaluator: third attempt rejected per `<rule id="retry-and-blocked">`; task status `blocked`.</signal>
    <signal code="STORY_ACCEPTED">Acceptor: every check met on the whole branch; acceptance table committed in the plan.</signal>
    <signal code="STORY_GAPS">Acceptor: unmet checks appended to the plan as convergence tasks and committed.</signal>
    <signal code="STORY_BLOCKED">Acceptor: third acceptance still unmet per `<rule id="story-acceptance">`.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="resolve-implementer">
      Derive kebab-case {SLUG}. Set the {IMPLEMENTER} type per `<rule id="implementer-selection">`: `harness-default` unless the user's request names another.
    </step>

    <step id="2" name="po-doc-analysis">
      Session acts as PO per `<rule id="session-role">`: read repository documentation (README.md, AGENTS.md, docs/, and the spec directory the repository keeps). Do not inspect application code. Evaluate user request feasibility from a business perspective and against the requirements already specified. If documentation is lacking or outdated, make its update a mandatory `Documentation` item of the story.
    </step>

    <step id="3" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first), including the spec directory question of `<rule id="spec-format">` when it applies. Resolve ambiguities, business rules, requirements and their scenarios, edge cases, and scope trade-offs. Repeat until all points are settled, recording a gap too small to ask about as an assumption.
    </step>

    <step id="4" name="write-story">
      Write the requirements into the spec files under {SPEC_DIR} per `<rule id="spec-format">`, editing existing files in place, and the story to `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md` per `<rule id="story-format">`, recording the {IMPLEMENTER} type and the current branch as {BASE_BRANCH}. Verify both per `<rule id="story-quality">`.
    </step>

    <step id="5" name="story-approval">
      Send an atomic chat message linking the story file and the spec files it touches, then prompt the user via `<user_interaction>` to approve them or request modifications. Iterate `<step id="3">` and `<step id="4">` until approved. If the user abandons the story instead, undo the spec edits and remove `docs/vibe-ai-tools/{SLUG}`. Barring an escalation per `<rule id="autonomous-decision-policy">`, `<rule id="retry-and-blocked">`, or `<rule id="story-acceptance">`, or coverage gaps left after `<step id="8">`, this is the last user interaction before the final outcome.
    </step>

    <step id="6" name="dispatch-planner">
      Announce the spawn in one chat line. Spawn `<template role="planner">` with clean zeroed context, inheriting session model and effort, with {ACTION} = plan, passing {SLUG}, {STORY_FILE} = `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md`, {PLAN_FILE} = `docs/vibe-ai-tools/{SLUG}/0-{SLUG}.md`, and empty {FEEDBACK}.
    </step>

    <step id="7" name="planner-clarifications">
      Answer the Planner's batched questions on the user's behalf per `<rule id="autonomous-decision-policy">`, applying amendments per `<rule id="spec-authority">`, until the Planner returns the plan path.
    </step>

    <step id="8" name="plan-validation">
      Read the plan and check it against the story and the spec: the coverage table names a task for every requirement the story adds, changes, or removes and for every `Documentation` item, or, for a requirement marked `existing`, the tests that already verify it, and nothing exceeds `Out of scope`. On gaps, dispatch the live Planner with {ACTION} = re-plan and the gaps as its feedback, and repeat this step, up to 3 times; gaps that remain are escalated to the user via `<user_interaction>`. Approve the plan without prompting the user.
    </step>

    <step id="9" name="branch-and-commit">
      Create git branch `vibe/{SLUG}` based on {BASE_BRANCH}. Stage and commit only the story, spec, and plan files with Conventional Commit message `chore(vibe): initialize plan and story for {SLUG}`. Terminate the Planner.
    </step>

    <step id="10" name="resolve-task">
      Read the task status table from the plan. When every task is `done`, proceed to `<step id="16">`. Otherwise take the first task whose status is not `done` as {TASK_NUM} with its {TASK_SLUG}, set {TASK_FILE} = `docs/vibe-ai-tools/{SLUG}/{TASK_NUM}-{TASK_SLUG}.md`, {ATTEMPT} = 1, and empty {FEEDBACK} and {REWORK_NOTES}.
    </step>

    <step id="11" name="dispatch-task-planner">
      Announce the spawn in one chat line. Spawn `<template role="task-planner">` with clean zeroed context, inheriting session model and effort, with {ACTION} = detail-task, passing {SLUG}, {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and empty {FEEDBACK}. Answer its questions on the user's behalf per `<rule id="autonomous-decision-policy">`. On `<signal code="TASK_PLANNED">`, terminate the Task Planner.
    </step>

    <step id="12" name="dispatch-implementer">
      Announce the spawn in one chat line. Spawn `<template role="implementer">` as one fresh agent of type {IMPLEMENTER}, resolved per `<rule id="implementer-selection">`, with clean zeroed context and {ACTION} = execute-task, or rework-task when {REWORK_NOTES} is non-empty, passing {TASK_NUM}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and {REWORK_NOTES}. When that type cannot be dispatched from this environment, report it to the user in one line and conclude, leaving the branch untouched. The Implementer ends on its return per `<rule id="implementer-lifecycle">`; branch on it:
      1. `<signal code="TASK_DELIVERED">`: proceed to `<step id="13">`.
      2. `<signal code="TASK_STOPPED">`: on the third stop of the same task, proceed to `<step id="15">`. Otherwise spawn a fresh `<template role="task-planner">` with {ACTION} = revise-task and the Implementer's line as its feedback, answer its questions on the user's behalf per `<rule id="autonomous-decision-policy">`, terminate it on `<signal code="TASK_PLANNED">`, then repeat this step with a fresh Implementer and the same {REWORK_NOTES}.
    </step>

    <step id="13" name="dispatch-evaluator">
      When the Evaluator of this task is alive, send it a new validation request with the current {ATTEMPT} and {FEEDBACK}. Otherwise announce the spawn in one chat line and spawn `<template role="evaluator">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {TASK_NUM}, {ATTEMPT}, {STORY_FILE}, {PLAN_FILE}, {TASK_FILE}, and {FEEDBACK}.
    </step>

    <step id="14" name="evaluator-verdict">
      Wait for the Evaluator signal and branch per `<rule id="session-role">` without reading or validating anything:
      1. `<signal code="TASK_APPROVED">`: terminate the Evaluator per `<rule id="clean-context-lifecycle">` and return to `<step id="10">`.
      2. `<signal code="TASK_REWORK">`: increment {ATTEMPT}, set {REWORK_NOTES} pointing at the rework items in {TASK_FILE}, and return to `<step id="12">`.
      3. `<signal code="TASK_BLOCKED">`: proceed to `<step id="15">`.
    </step>

    <step id="15" name="blocked-recovery">
      Recover or escalate per `<rule id="retry-and-blocked">`. With extra instructions, whether the session's own or the user's, apply any amendment they carry per `<rule id="spec-authority">`, set {FEEDBACK} to them, {ATTEMPT} = 1, and {REWORK_NOTES} = {FEEDBACK}, and return to `<step id="12">`. On abort, terminate the Evaluator when one is alive, leave branch `vibe/{SLUG}` and the plan directory in place for inspection, and report the blocked task in one line.
    </step>

    <step id="16" name="story-acceptance">
      When {ROUND} is unset, set {ROUND} = 1 and empty {ACCEPTANCE_NOTES}. Announce the spawn in one chat line. Spawn `<template role="acceptor">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {ROUND}, {BASE_BRANCH}, {STORY_FILE}, {PLAN_FILE}, and {ACCEPTANCE_NOTES}. It ends on its return; branch per `<rule id="story-acceptance">` without reading or validating anything:
      1. `<signal code="STORY_ACCEPTED">`: proceed to `<step id="17">`.
      2. `<signal code="STORY_GAPS">`: increment {ROUND} and return to `<step id="10">`.
      3. `<signal code="STORY_BLOCKED">`: recover or escalate per `<rule id="story-acceptance">`. With extra instructions, the session's own or the user's, set {ACCEPTANCE_NOTES} to them and {ROUND} = 1, and repeat this step; after an amendment set {ROUND} = 1 and return to `<step id="10">` instead. On abort, leave branch `vibe/{SLUG}` and the plan directory in place for inspection, and report the unmet checks in one line.
    </step>

    <step id="17" name="plan-cleanup">
      Copy the acceptance table, decisions, and amendments to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-pr.md`, then remove the plan directory via `git rm -r docs/vibe-ai-tools/{SLUG}` and commit with `chore(vibe): complete {SLUG} delivery`, per `<rule id="finalization-and-pr">`.
    </step>

    <step id="18" name="push-and-pr">
      Push branch `vibe/{SLUG}` to remote. Inspect git log diff against {BASE_BRANCH} and open a pull request formatted per `<rule id="finalization-and-pr">`. Send a one-line outcome with the pull request link.
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
        1. Read the story for {SLUG} from {STORY_FILE} and every spec file it names: the requirements it adds, changes, or removes, and the unchanged ones of the same files, which are preserved behavior.
        2. Inspect the files, modules, and dependencies in scope. Verify against actual code; do not assume. Identify existing points of extension and new components needed.
        3. Send batched questions with recommended options to the session (up to 3 rounds) on any requirement you cannot turn into a verifiable check, requirements that contradict each other, and major discrepancies between the spec and the code, flagging any option that carries financial cost, irreversible data loss, or a destructive operation.
        4. Write {PLAN_FILE} as a general plan: task status table with columns `#`, `Status` (blank, `working`, `validating`, `retry` plus attempt number, `blocked`, `done`), and `Task`; technical objective; overall architecture with a Mermaid diagram of the affected components; "Constraints and verification", the story's `Constraints`, the repository rules and invariants that bind the design (AGENTS.md, README.md, ADRs, CI), and the exact build, lint, typecheck, and test commands; the tasks, each atomic, self-contained, and independently committable; "Coverage", a table from each requirement the story adds, changes, or removes and each `Documentation` item to the tasks that deliver it, or, for a requirement marked `existing`, to the tests that already verify it or the task that adds them, marking `enabling` a task that serves none; a "Decisions" section recording resolved questions and choices, where a decision that changes the documented architecture also gets a documentation task.
        5. Give each task what a Task Planner with no other context needs to detail it: a technical summary, the requirement and scenario IDs it delivers, its boundary (modules and areas inside it, and what is left to other tasks), its dependencies on earlier tasks, and the architectural direction to follow. Leave file-level changes, test behaviors, and implementation steps to the Task Planner.
        6. Return a one-line outcome with {PLAN_FILE}.

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, the spec files it names, the existing {PLAN_FILE}, and {FEEDBACK}.
        2. Inspect the code the change touches, then adjust the architecture, diagram, task separation, coverage, and decisions in {PLAN_FILE}, giving each new or changed task the entry a planned task gets and leaving every task whose status is not blank as it is.
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
        This payload is the brief; do not read sibling skill files. Keep the plan as written: settle task-level questions yourself, choosing zero-cost and easily reversible options, and change no scope.
        When {ACTION} is detail-task:
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE} for plan {SLUG}: architecture, constraints and verification, decisions, and task {TASK_NUM} with its summary, requirement and scenario IDs, boundary, dependencies, and direction.
        2. Inspect the code inside the boundary of task {TASK_NUM}, plus what earlier tasks already committed. Verify against actual code; do not assume. Stay out of the areas the plan left to other tasks.
        3. If the task cannot be delivered inside its boundary, send batched questions with recommended options to the session (up to 3 rounds), flagging any option that carries financial cost, irreversible data loss, or a destructive operation.
        4. Write {TASK_FILE}: technical objective, the scenario IDs in scope, files to create or modify with expected changes, test behaviors to verify, at least one per scenario ID and each naming the ID it verifies, plus those the code needs beyond the spec (unit tests for code; smoke tests, linters, or schema validations for non-code assets), the verification commands of the plan that apply, suggested implementation steps without writing code, and a "Decisions" section.
        5. Set task {TASK_NUM} status to `working` in {PLAN_FILE}.
        6. Return one line with {TASK_FILE} ending with `<signal code="TASK_PLANNED">`.

        When {ACTION} is revise-task:
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, the existing {TASK_FILE}, and {FEEDBACK}, the contradiction or blocker the Implementer reported.
        2. Verify it against actual code and the spec and correct {TASK_FILE} in place, recording the change under "Decisions". When only a change to the spec resolves it, send that as a batched question to the session first, flagging any option that carries financial cost, irreversible data loss, or a destructive operation.
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
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM}. Take any uncommitted changes already in the worktree as your starting point.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities or the spec, stop immediately and return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Author tests covering the defined behaviors, named by the behavior they verify with the scenario IDs staying in the report (unit tests for code; smoke tests, schema validations, or linters for non-code files) and run the verification commands of {TASK_FILE}. Fix defects until all checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE}: changed files, a table from each scenario ID to its test and result, other tests written and executed, command outcomes, and blockers. No self-evaluation.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit. Return one line with {TASK_FILE} ending with `<signal code="TASK_DELIVERED">`.

        When {ACTION} is rework-task:
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, {TASK_FILE} with its reports and the feedback appended to it, and {REWORK_NOTES}. The uncommitted changes in the worktree are the previous attempt; rework them in place.
        2. Apply the requested fixes, re-run the verification commands of {TASK_FILE}, and fix new failures. If blocked, return one line stating it, ending with `<signal code="TASK_STOPPED">`.
        3. Append a rework summary to {TASK_FILE} and set task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        4. Do not commit. Return one line with {TASK_FILE} ending with `<signal code="TASK_DELIVERED">`.
      </instructions>
      <constraints>
        <constraint>Stay strictly within task scope, leave the spec files and the story untouched, and report factual results only, without local commits.</constraint>
      </constraints>
    </template>

    <template role="evaluator" executor="inherited">
      <job>Independent adversarial evaluator: hunt for defects in one task's delivery, beyond checking it against the spec, the plan, and the task file, and commit it only when none remain.</job>
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
        This payload is the brief; do not read sibling skill files. You own the verdict on task {TASK_NUM} of plan {SLUG}; nobody reviews it afterwards, and you never ask the user or the session anything. You took no part in planning or implementing it: judge what is in the worktree, not what the report claims. The session sends this request once per attempt, with a new {ATTEMPT} each time.
        1. Read {STORY_FILE}, the spec files it names, {PLAN_FILE}, and {TASK_FILE} with its implementation report. Treat a non-empty {FEEDBACK} as extra instructions for this task, granted after it blocked.
        2. Read the uncommitted git diff and judge it scenario by scenario: for each scenario ID the plan assigns to task {TASK_NUM}, the behavior is delivered as its spec file states it and a test that would fail without it verifies it; a {TASK_FILE} that omits one of those IDs is a defect. Then judge that the delivery adds no behavior the spec does not ask for, leaves every other requirement of the touched spec files holding, follows the plan's architecture, constraints, and decisions, stays inside the task's scope, matches the report, and holds in quality.
        3. Review adversarially: assume the delivery hides defects until you have hunted them down, probing beyond the expected behavior for bugs and regressions, unhandled edge cases and boundary values, empty, null, and malformed input, misuse and malicious input, security flaws (injection, missing authorization, secret exposure, unsafe defaults), race conditions and partial failures, error handling, and scope creep or gaps. An unlikely but plausible failure in what the delivery touches is a defect.
        4. Verify that tests exist and genuinely verify the behaviors defined in {TASK_FILE}, failure paths and edge cases included, not only the happy path, and run the verification commands of {TASK_FILE} yourself.
        5. Append to {TASK_FILE} the compliance table for attempt {ATTEMPT}, each scenario ID with `met` or `unmet` and its evidence, then observations, every defect found, and the verdict.
        6. If approved: set task {TASK_NUM} status to `done` in {PLAN_FILE}, stage the task's files with the plan and task files, commit locally with a Conventional Commit message, leave the worktree clean, and return one line ending with `<signal code="TASK_APPROVED">`.
        7. If rejected and {ATTEMPT} is below 3: append specific rework items to {TASK_FILE}, set the status to `retry` plus the next attempt number, and return one line ending with `<signal code="TASK_REWORK">`.
        8. If rejected and {ATTEMPT} is 3: set the status to `blocked`, leave the task's uncommitted changes in place, commit only {PLAN_FILE} and {TASK_FILE}, and return one line naming {TASK_FILE} and ending with `<signal code="TASK_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Never fix or write task code yourself and never approve a delivery with an `unmet` scenario or without tests genuinely verifying the defined behaviors.</constraint>
        <constraint>Delivering what was expected is not enough: never approve while a defect, unhandled edge case, misuse path, or security flaw you found remains.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources, never touch files outside the plan scope.</constraint>
      </constraints>
    </template>

    <template role="acceptor" executor="inherited">
      <job>Independent acceptance judge: check the whole branch of one story against every requirement of its spec before the pull request.</job>
      <input>
        <slug>{SLUG}</slug>
        <round>{ROUND}</round>
        <base_branch>{BASE_BRANCH}</base_branch>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <acceptance_notes>{ACCEPTANCE_NOTES}</acceptance_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. You own the acceptance of story {SLUG}; nobody reviews it afterwards, and you never ask the user or the session anything. You took no part in planning, implementing, or evaluating it: judge what is on the branch, not what the reports claim.
        1. Read {STORY_FILE}, the spec files it names, and {PLAN_FILE}: constraints and verification, coverage, and decisions. Treat a non-empty {ACCEPTANCE_NOTES} as extra instructions, granted after the story blocked.
        2. Read the diff of the branch against {BASE_BRANCH}, the plan directory aside, and run every verification command of the plan.
        3. Judge each check: every requirement the story adds or changes is delivered, scenario by scenario, and verified by tests that would fail without it; every requirement it removes is gone with its tests; every other requirement of the touched spec files still holds; every `Documentation` item is reflected in its document; every `Constraints` item of the story is respected; every verification command passes; the spec files changed only in the requirements the story lists, and their text matches the delivered behavior.
        4. Append to {PLAN_FILE} an "Acceptance" section, numbered after those already there: a table with columns `Check`, `Verdict` (`met` or `unmet`), and `Evidence` (the test, the command output, or the diff location), with one row per requirement the story adds, changes, or removes, per `Documentation` item, per `Constraints` item, and per verification command, one row for the other requirements of the touched spec files, and one for the spec diff.
        5. If every row is `met`: commit only {PLAN_FILE} with `chore(vibe): accept {SLUG}` and return one line ending with `<signal code="STORY_ACCEPTED">`.
        6. If a row is `unmet` and {ROUND} is below 3: append one convergence task per `unmet` row to {PLAN_FILE}, as a blank-status row in the task status table and an entry with technical summary, requirement and scenario IDs, boundary, dependencies, and direction, update the coverage table, commit only {PLAN_FILE} with `chore(vibe): record acceptance gaps for {SLUG}`, and return one line ending with `<signal code="STORY_GAPS">`.
        7. If a row is `unmet` and {ROUND} is 3: commit only {PLAN_FILE} with that same message and return one line naming the unmet checks and ending with `<signal code="STORY_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>Never fix code, tests, the spec, or the story yourself; write nothing but {PLAN_FILE}.</constraint>
        <constraint>Never accept while a scenario the story adds or changes lacks a test that genuinely verifies it or a verification command fails.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
