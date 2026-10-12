---
name: vibe-ai-tools
description: >
  Formulate a user story interactively with the user, then autonomously execute
  planning, atomic task implementation, validation, and pull request creation.
  The session acts as PO during story refinement, then takes full
  responsibility for all technical decisions—prioritizing zero-cost and easily
  reversible options—driving unattended execution through to PR delivery. Use
  for /vibe-ai-tools.
argument-hint: "[story or feature description to plan and implement]"
---

<skill name="vibe-ai-tools">
  <overview>
    Refine one story with the user, then deliver it unattended. The session acts as Product Owner (PO) during story refinement, clarifying scope, business rules, and acceptance criteria with the user and settling the implementer choice. From story approval onward the session is an autonomous orchestrator that owns every technical decision, strictly prioritizing zero-cost and easily reversible choices. Planning, execution, and validation belong to subagents: one Planner with clean context, inheriting session model and effort, inspects the code and writes a plan of atomic tasks, which the session checks against the story and approves itself; one Tech Lead with clean context then writes each task file, dispatches one clean-context Implementer of the story type, validates the delivery against the uncommitted git diff, and commits approved work. Once every task is done, the session removes the plan directory, pushes the branch, and creates a pull request.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard project domain terminology:
      - `Story` (User Story): Business-level structuring of the user request written to `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md` by the PO session, recording the implementer type.
      - `Plan`: Technical artifact written to `docs/vibe-ai-tools/{SLUG}/0-{SLUG}.md` by the Planner, decomposed into atomic tasks, with the task status table.
      - `Task`: Technical specification for a single atomic unit of work located at `docs/vibe-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md`, written by the Tech Lead.
      - `User`: Person interacting with the session.
      - `PO` (Product Owner): The interactive session during story refinement. Focuses exclusively on repository documentation and business domain requirements without reading application code.
      - `Planner`: Clean-context subagent inheriting session model and effort; full-stack architect that inspects the code and writes the plan.
      - `Tech Lead`: Clean-context subagent inheriting session model and effort; full-stack architect that details tasks, dispatches implementers, validates, and commits.
      - `Implementer`: Clean-context agent of the story implementer type, resolved per `<rule id="implementer-types">`; lives for one task.
    </rule>

    <rule id="session-role">The session is PO, then autonomous orchestrator:
      - As PO it never reads application source code; it evaluates the user request against repository documentation (README.md, AGENTS.md, docs/) and resolves scope boundaries, business logic, user-facing behavior, and ambiguities with the user.
      - If documentation is missing, outdated, or requires adjustments, the PO includes documentation adequacy as a mandatory story requirement.
      - As orchestrator it dispatches the Planner and the Tech Lead and branches solely on their returns per `<return_protocol>`; it writes no plan and no task file.
      - It never reads diffs or code to validate, rework, or re-judge a delivery; validation belongs to the Tech Lead.
    </rule>

    <rule id="autonomous-decision-policy">Autonomous decision authority and escalation threshold:
      - Following user story approval in `<step id="5">`, the session assumes total responsibility for all subsequent technical decisions.
      - For all questions, trade-offs, or doubts raised by the Planner, the session decides autonomously without consulting the user.
      - Core decision criterion: prioritize options that carry zero financial cost and ensure easy backup and reversibility for critical issues.
      - Escalation threshold: the session pauses to query the user via `<user_interaction>` only if neither zero-cost nor easily reversible options are possible (e.g., unavoidable paid third-party services, irreversible data loss, or destructive infrastructure actions).
      - All autonomous decisions and settled trade-offs are explicitly recorded in the "Decisions" section of `0-{SLUG}.md`.
    </rule>

    <rule id="transient-docs">Story, plan, task files, and decisions belong under `docs/vibe-ai-tools/{SLUG}/`. Raw tool outputs, binary caches, and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. In-repo plan files are committed along the workflow.</rule>

    <rule id="clean-context-lifecycle">Planner and Tech Lead are spawned with clean, zeroed context; continuity between them lives only in the plan directory and git history. Every Implementer is spawned with clean, zeroed context for one task, stays alive for rework of that task, and is terminated once the task is accepted or blocked.</rule>

    <rule id="retry-and-blocked">A task allows up to 3 implementation attempts. When the third attempt fails validation, the Tech Lead sets the task status to `blocked`, leaves that task's uncommitted changes in place for inspection, commits only the plan and task files, and returns `<signal code="PLAN_BLOCKED">`. The session first attempts one autonomous recovery: it reads the blocked task file, writes extra instructions per `<rule id="autonomous-decision-policy">`, and re-dispatches the Tech Lead with 3 additional attempts. If the task blocks again or recovery is impossible, the session sends an atomic chat message linking the task file, then prompts the user via `<user_interaction>` to provide extra instructions for 3 additional attempts or abort.</rule>

    <rule id="finalization-and-pr">Upon `<signal code="PLAN_DONE">`:
      - The session removes the plan directory (`git rm -r docs/vibe-ai-tools/{SLUG}`) and commits with `chore(vibe): complete {SLUG} delivery`.
      - The session pushes branch `vibe/{SLUG}` to remote.
      - The session inspects `git log` difference against the base branch and creates a pull request formatted with a business overview followed by technical change highlights.
    </rule>
  </boundaries>

  <return_protocol>
    <signal code="PLAN_DONE">Every task in the plan validated and committed; worktree clean.</signal>
    <signal code="PLAN_BLOCKED">One task exhausted its attempts per `<rule id="retry-and-blocked">`; the line names its task file.</signal>
    <signal code="DISPATCH_UNAVAILABLE">The Tech Lead cannot dispatch an Implementer of the story type from its environment; nothing written or committed.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="implementer-inquiry">
      Derive kebab-case {SLUG}. Prompt the user via `<user_interaction>` to select the {IMPLEMENTER} type per `<rule id="implementer-selection">`.
    </step>

    <step id="2" name="po-doc-analysis">
      Session acts as PO per `<rule id="session-role">`: read repository documentation (README.md, AGENTS.md, docs/). Do not inspect application code. Evaluate user request feasibility from a business perspective. If documentation is lacking or outdated, mark documentation updates as a mandatory requirement.
    </step>

    <step id="3" name="po-clarification">
      Conduct clarification rounds with the user via `<user_interaction>` in batched questions (each with a recommended option first). Resolve ambiguities, business rules, acceptance criteria, edge cases, and scope trade-offs. Repeat until all points are settled.
    </step>

    <step id="4" name="write-story">
      Write the finalized user story to `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md`. Include business context, scope boundaries, acceptance criteria, documentation requirements, and the selected implementer type (as a type identifier, not a specific model).
    </step>

    <step id="5" name="story-approval">
      Send an atomic chat message linking the story file, then prompt the user via `<user_interaction>` to approve it or request modifications. Iterate `<step id="3">` and `<step id="4">` until approved. Barring an escalation per `<rule id="autonomous-decision-policy">` or `<rule id="retry-and-blocked">`, this is the last user interaction before the final outcome.
    </step>

    <step id="6" name="dispatch-planner">
      Announce the spawn in one chat line. Spawn `<template role="planner">` with clean zeroed context, inheriting session model and effort, with {ACTION} = plan, passing {SLUG}, {STORY_FILE} = `docs/vibe-ai-tools/{SLUG}/story-{SLUG}.md`, {PLAN_FILE} = `docs/vibe-ai-tools/{SLUG}/0-{SLUG}.md`, and empty {FEEDBACK}.
    </step>

    <step id="7" name="planner-clarifications">
      Answer the Planner's batched questions on the user's behalf per `<rule id="autonomous-decision-policy">`, until the Planner returns the plan path.
    </step>

    <step id="8" name="plan-validation">
      Read the plan and check it against the story: every acceptance criterion and documentation requirement is covered by a task, and nothing exceeds the scope boundaries. On gaps, dispatch the live Planner with {ACTION} = re-plan and {FEEDBACK} listing them, and repeat this step. Approve the plan without prompting the user.
    </step>

    <step id="9" name="branch-and-commit">
      Create git branch `vibe/{SLUG}` based on the current branch. Stage and commit only the story and plan files with Conventional Commit message `chore(vibe): initialize plan and story for {SLUG}`. Terminate the Planner.
    </step>

    <step id="10" name="dispatch-tech-lead">
      Announce the spawn in one chat line. Spawn `<template role="tech-lead">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {IMPLEMENTER}, {STORY_FILE}, {PLAN_FILE}, {PLAN_DIR} = `docs/vibe-ai-tools/{SLUG}`, and {FEEDBACK} empty on the first dispatch. Append `<template role="implementer">` verbatim to the payload so the Tech Lead can dispatch it.
    </step>

    <step id="11" name="tech-lead-return">
      Wait for the Tech Lead signal and branch per `<rule id="session-role">`:
      1. `<signal code="PLAN_DONE">`: proceed to `<step id="13">`.
      2. `<signal code="PLAN_BLOCKED">`: proceed to `<step id="12">`.
      3. `<signal code="DISPATCH_UNAVAILABLE">`: report it to the user in one line and conclude, leaving the branch untouched.
    </step>

    <step id="12" name="blocked-recovery">
      Recover or escalate per `<rule id="retry-and-blocked">`. With extra instructions, whether the session's own or the user's, return to `<step id="10">` with {FEEDBACK} set to them. On abort, leave branch `vibe/{SLUG}` and the plan directory in place for inspection and report the blocked task in one line.
    </step>

    <step id="13" name="plan-cleanup">
      Remove the plan directory via `git rm -r docs/vibe-ai-tools/{SLUG}` and commit with `chore(vibe): complete {SLUG} delivery` per `<rule id="finalization-and-pr">`.
    </step>

    <step id="14" name="push-and-pr">
      Push branch `vibe/{SLUG}` to remote. Inspect git log diff against base branch and open a pull request formatted with a business overview followed by technical change highlights per `<rule id="finalization-and-pr">`. Send a one-line outcome with the pull request link.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="planner" executor="inherited">
      <job>Full-stack architect: inspect the code in scope and decompose one story into a plan of atomic, independently committable tasks.</job>
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
        3. If major discrepancies with {STORY_FILE} appear, send batched questions with recommended options to the session (up to 3 rounds), flagging any option that carries financial cost, irreversible data loss, or a destructive operation.
        4. Write {PLAN_FILE}: task status table with columns `#`, `Status` (blank, `working`, `validating`, `retry` plus attempt number, `blocked`, `done`), and `Task`; technical objective; Mermaid diagram of the affected components; atomic, self-contained, independently committable tasks with technical summaries and dependencies; a "Decisions" section recording resolved questions and choices.
        5. Return a one-line outcome with {PLAN_FILE}.

        When {ACTION} is re-plan:
        1. Read {STORY_FILE}, the existing {PLAN_FILE}, and {FEEDBACK}.
        2. Adjust the diagram, task breakdown, and decisions in {PLAN_FILE}.
        3. Return a one-line outcome with {PLAN_FILE}.
      </instructions>
      <constraints>
        <constraint>Plan only: write nothing but {PLAN_FILE}, change no code, and commit nothing.</constraint>
        <constraint>Do not make unverified code assumptions; verify against repository reality.</constraint>
      </constraints>
    </template>

    <template role="tech-lead" executor="inherited">
      <job>Full-stack architect executing one approved plan: detail each task, dispatch single-task implementers, validate and commit their deliveries.</job>
      <input>
        <slug>{SLUG}</slug>
        <implementer>{IMPLEMENTER}</implementer>
        <story_file>{STORY_FILE}</story_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <plan_dir>{PLAN_DIR}</plan_dir>
        <feedback>{FEEDBACK}</feedback>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. You own every task specification and every validation of plan {SLUG}; nobody reviews your work afterwards, and you never ask the user or the session anything. Keep the plan as written: settle task-level questions yourself, choosing zero-cost and easily reversible options, and change no scope.
        Intake:
        1. Read {STORY_FILE} and {PLAN_FILE}: scope, acceptance criteria, decisions, and the task status table.
        2. Confirm you can dispatch an agent of type {IMPLEMENTER}, resolved per `<rule id="implementer-types">`, through the harness subagent API or the matching tier skill CLI. If you cannot, write nothing and return `<signal code="DISPATCH_UNAVAILABLE">`.
        3. Resume at the first task whose status is not `done`. When that task is `blocked`, apply {FEEDBACK} as the user's extra instructions, keep its existing task file and uncommitted changes as the starting point, and grant it 3 new attempts.
        Execute each remaining task in order, one at a time:
        4. Write the task file in {PLAN_DIR}, named by task number and kebab-case task slug: technical objective, files to create or modify with expected changes, test behaviors to verify per change (unit tests for code; smoke tests, linters, or schema validations for non-code assets), and suggested implementation steps without writing code. Verify against actual code; do not assume. Set the task status to `working`.
        5. Spawn one fresh agent of type {IMPLEMENTER} with clean zeroed context, sending the implementer template appended to this brief with its action set to execute-task and its fields filled for this task. Answer its questions yourself.
        6. Validate the delivery against the uncommitted git diff and the task file: tests exist and genuinely verify the defined behaviors, test and lint runs pass, scope is respected, quality holds. Append observations and verdict to the task file.
        7. If approved: set the task status to `done`, stage the task's files with the plan and task files, commit locally with a Conventional Commit message, and terminate the implementer.
        8. If rework is needed: set the status to `retry` plus attempt number, append rework items to the task file, and send them to the live implementer with action rework-task; validate again. After 3 failed attempts, set the status to `blocked`, terminate the implementer, leave the task's uncommitted changes in place, commit only {PLAN_FILE} and the task file, and return one line naming the task file and ending with `<signal code="PLAN_BLOCKED">`.
        Close:
        9. When every task is `done`, leave the worktree clean and return one line ending with `<signal code="PLAN_DONE">`.
      </instructions>
      <constraints>
        <constraint>Never implement task code yourself and never approve a delivery that lacks tests genuinely verifying the defined behaviors.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources, never touch files outside the plan scope.</constraint>
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
        This payload is the brief; do not read sibling skill files. The Tech Lead that dispatched you is your only counterpart.
        When {ACTION} is execute-task:
        1. Read {STORY_FILE}, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM}.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities, stop immediately and notify the Tech Lead.
        3. Author tests covering the defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files) and run test suites and linters. Fix defects until all checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE}: changed files, tests written and executed, test and lint outcomes, blockers, and Tech Lead decisions applied. No self-evaluation.
        5. Update task {TASK_NUM} status to `validating` in {PLAN_FILE}.
        6. Do not commit. Return a concise outcome with {TASK_FILE}.

        When {ACTION} is rework-task:
        1. Read {REWORK_NOTES} and the feedback appended to {TASK_FILE}.
        2. Apply the requested fixes in place, re-run tests and linters, and fix new failures.
        3. Append a rework summary to {TASK_FILE} and keep task {TASK_NUM} status `validating` in {PLAN_FILE}.
        4. Do not commit. Return a concise outcome with {TASK_FILE}.
      </instructions>
      <constraints>
        <constraint>Stay strictly within task scope and report factual results only, without local commits.</constraint>
      </constraints>
    </template>
  </dispatch_templates>
</skill>
