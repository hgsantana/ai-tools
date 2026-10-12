---
name: campaign-ai-tools
description: >
  Run an unattended multi-cycle campaign over a repository. The session settles
  campaign scope and implementer with the user, commits the campaign file on a
  dedicated branch, then dispatches one clean-context Planner per cycle to scan
  the repository, plan one work point, drive single-task implementers, and
  validate and commit their deliveries, for up to 10 cycles or until nothing is
  left to do. Use for /campaign-ai-tools.
argument-hint: "[campaign goal to pursue across the repository]"
---

<skill name="campaign-ai-tools">
  <overview>
    Pursue one repository-wide goal through repeated autonomous cycles. The session settles the campaign scope and the implementer type interactively with the user, creates branch `campaign/{SLUG}` from the current local branch, and commits the campaign file. It then dispatches one Planner subagent per cycle with clean context, inheriting session model and effort. Each Planner acts as a full-stack architect: it scans the repository for one work point matching the campaign, writes and commits a plan, dispatches one clean-context Implementer per task, validates each delivery, and commits approved work. The session neither reads nor judges any delivery: it settles scope, dispatches cycles on the Planner's return signal, and makes the first and last commits of the campaign.
  </overview>

  <boundaries>
    <rule id="ubiquitous-language">Standard campaign terminology:
      - `Campaign`: Repository-wide goal recorded in `docs/campaign-ai-tools/{SLUG}/campaign-{SLUG}.md` with scope, exclusions, implementer type, and the cycle log.
      - `Cycle`: One Planner lifetime covering scan, plan, task execution, and validation of a single work point.
      - `Work point`: One cohesive spot in the repository where the campaign goal applies and has not yet been addressed.
      - `Planner`: Clean-context subagent inheriting session model and effort; full-stack architect that plans, dispatches implementers, validates, and commits.
      - `Implementer`: Clean-context agent of the campaign implementer type; lives for one task.
      - `Cycle log`: Table in the campaign file with columns `#`, `Status` (`working`, `done`, `blocked`), `Work point`, and `Plan`, maintained by Planners as the memory shared across cycles.
    </rule>

    <rule id="session-role">The session is orchestrator only:
      - It interacts with the user exclusively to settle campaign scope and implementer type, and to report the final outcome.
      - It dispatches cycles and branches solely on the Planner return signal per `<return_protocol>`.
      - It never reads plans, task files, diffs, or code, and never validates, reworks, or re-judges a delivery; validation belongs to the Planner.
      - It commits twice: the campaign file at the start and the campaign cleanup at the end.
    </rule>

    <rule id="implementer-selection">The session asks who implements the campaign per plan-ai-tools `<rule id="implementer-selection">`, recommending `mid-level` and omitting `session`, since the session never implements. The campaign file records only the resolved type name, resolved at dispatch time per `<rule id="implementer-types">`.</rule>

    <rule id="cycle-limits">Campaign termination:
      - The campaign ends after 10 productive cycles (`<signal code="CYCLE_DONE">` or `<signal code="CYCLE_BLOCKED">`).
      - A cycle returning `<signal code="CYCLE_EMPTY">` is an empty attempt and does not consume a cycle number; the session dispatches a fresh Planner for the same cycle number.
      - The campaign ends when 2 consecutive attempts return `<signal code="CYCLE_EMPTY">`; a productive cycle resets that count.
      - The campaign ends immediately on `<signal code="DISPATCH_UNAVAILABLE">`.
    </rule>

    <rule id="autonomous-decision-policy">After scope approval the campaign runs unattended. The Planner settles every technical question itself, choosing zero-cost and easily reversible options. A work point that requires financial cost, irreversible data loss, a destructive operation, or a cloud mutation is out of bounds: the Planner records it as `blocked` in the cycle log with the reason and selects another work point.</rule>

    <rule id="clean-context-lifecycle">Every Planner is spawned with clean, zeroed context and ends with its cycle; continuity across cycles lives only in the campaign file and git history. Every Implementer is spawned with clean, zeroed context for one task, stays alive for rework of that task, and is terminated once the task is accepted or blocked.</rule>

    <rule id="retry-and-blocked">A task allows up to 3 implementation attempts. When the third attempt fails validation, the Planner discards that task's uncommitted changes, sets the task status to `blocked`, skips the remaining tasks that depend on it, and closes the cycle as `blocked`.</rule>

    <rule id="transient-docs">Campaign state lives under `docs/campaign-ai-tools/{SLUG}/`: the campaign file at its root and one directory `cycle-{CYCLE}` per productive cycle holding `0-plan.md` and one numbered task file per task. Raw tool outputs and temporary data go to `${TMPDIR:-/tmp}/ai-tools`. The branch is never pushed by this skill.</rule>
  </boundaries>

  <return_protocol>
    <signal code="CYCLE_DONE">Work point planned, every task validated and committed.</signal>
    <signal code="CYCLE_BLOCKED">Work point planned and committed, at least one task blocked per `<rule id="retry-and-blocked">`.</signal>
    <signal code="CYCLE_EMPTY">No remaining work point found for the campaign; nothing written or committed.</signal>
    <signal code="DISPATCH_UNAVAILABLE">The Planner cannot dispatch an Implementer of the campaign type from its environment; nothing written or committed.</signal>
  </return_protocol>

  <session_workflow>
    <step id="1" name="scope-refinement">
      Derive kebab-case {SLUG}. Read repository documentation (README.md, AGENTS.md, docs/) without inspecting application code. Conduct clarification rounds with the user via `<user_interaction>` in batched questions, recommended option first, until the campaign goal, in-scope and out-of-scope areas, the definition of a finished work point, and constraints are settled.
    </step>

    <step id="2" name="implementer-inquiry">
      Prompt the user via `<user_interaction>` to select the {IMPLEMENTER} type per `<rule id="implementer-selection">`.
    </step>

    <step id="3" name="write-campaign">
      Write `docs/campaign-ai-tools/{SLUG}/campaign-{SLUG}.md` with the campaign goal, scope boundaries, definition of a finished work point, constraints, the selected implementer type, and an empty cycle log per `<rule id="ubiquitous-language">`.
    </step>

    <step id="4" name="campaign-approval">
      Send an atomic chat message linking the campaign file, then prompt the user via `<user_interaction>` to approve it or request modifications. Iterate `<step id="1">` to `<step id="3">` until approved. This is the last user interaction before the final outcome.
    </step>

    <step id="5" name="branch-and-commit">
      Create git branch `campaign/{SLUG}` based on the current local branch. Stage and commit only the campaign file with Conventional Commit message `chore(campaign): initialize campaign {SLUG}`.
    </step>

    <step id="6" name="dispatch-cycle">
      Set {CYCLE} to the next productive cycle number, starting at 1. Announce the spawn in one chat line. Spawn `<template role="planner">` with clean zeroed context, inheriting session model and effort, passing {SLUG}, {CYCLE}, {IMPLEMENTER}, {CAMPAIGN_FILE} = `docs/campaign-ai-tools/{SLUG}/campaign-{SLUG}.md`, and {CYCLE_DIR} = `docs/campaign-ai-tools/{SLUG}/cycle-{CYCLE}`. Append `<template role="implementer">` verbatim to the payload so the Planner can dispatch it.
    </step>

    <step id="7" name="cycle-return">
      Wait for the Planner signal and branch per `<rule id="cycle-limits">` without reading or validating anything:
      1. `<signal code="CYCLE_DONE">` or `<signal code="CYCLE_BLOCKED">`: count one productive cycle and reset the empty count. Below 10 productive cycles, return to `<step id="6">`; otherwise proceed to `<step id="8">`.
      2. `<signal code="CYCLE_EMPTY">`: count one empty attempt. On the first consecutive one, return to `<step id="6">` with the same {CYCLE}; on the second, proceed to `<step id="8">`.
      3. `<signal code="DISPATCH_UNAVAILABLE">`: proceed to `<step id="8">`.
    </step>

    <step id="8" name="final-commit">
      Remove the campaign directory via `git rm -r docs/campaign-ai-tools/{SLUG}` and commit with `chore(campaign): complete campaign {SLUG}`. Leave branch `campaign/{SLUG}` local and unpushed.
    </step>

    <step id="9" name="outcome">
      Send a one-line outcome to the user: branch `campaign/{SLUG}`, productive cycles run, cycles blocked, and the stop reason (cycle limit, nothing left to do, or dispatch unavailable).
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="planner" executor="inherited">
      <job>Full-stack architect for one campaign cycle: find one work point, plan it, dispatch single-task implementers, validate and commit their deliveries.</job>
      <input>
        <slug>{SLUG}</slug>
        <cycle>{CYCLE}</cycle>
        <implementer>{IMPLEMENTER}</implementer>
        <campaign_file>{CAMPAIGN_FILE}</campaign_file>
        <cycle_dir>{CYCLE_DIR}</cycle_dir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. You own every technical decision and every validation of cycle {CYCLE} of campaign {SLUG}; nobody reviews your work afterwards, and you never ask the user or the session anything. Decide autonomously, choosing zero-cost and easily reversible options.
        Scan:
        1. Read {CAMPAIGN_FILE}: goal, scope boundaries, definition of a finished work point, constraints, and the cycle log of work points already done or blocked.
        2. Scan the repository for one cohesive work point where the campaign goal applies, inside scope and absent from the cycle log. Verify against actual code; do not assume. Skip any work point requiring financial cost, irreversible data loss, a destructive operation, or a cloud mutation.
        3. If no work point remains, write nothing, commit nothing, and return `<signal code="CYCLE_EMPTY">`.
        4. Confirm you can dispatch an agent of type {IMPLEMENTER}, resolved per `<rule id="implementer-types">`, through the harness subagent API or the matching tier skill CLI. If you cannot, write nothing and return `<signal code="DISPATCH_UNAVAILABLE">`.
        Plan:
        5. Write `{CYCLE_DIR}/0-plan.md`: task status table with columns `#`, `Status` (blank, `working`, `validating`, `retry` plus attempt number, `blocked`, `done`), and `Task`; the work point and technical objective; Mermaid diagram of the affected components; atomic, self-contained, independently committable tasks with technical summaries and dependencies; decisions taken.
        6. Append a row for cycle {CYCLE} to the cycle log in {CAMPAIGN_FILE} with status `working`, the work point, and the plan path.
        7. Stage only those two files and commit with `chore(campaign): plan cycle {CYCLE} of {SLUG}`.
        Execute each task in order, one at a time:
        8. Write the task file in {CYCLE_DIR}, named by task number and kebab-case task slug: technical objective, files to create or modify with expected changes, test behaviors to verify per change (unit tests for code; smoke tests, linters, or schema validations for non-code assets), and suggested implementation steps without writing code. Set the task status to `working`.
        9. Spawn one fresh agent of type {IMPLEMENTER} with clean zeroed context, sending the implementer template appended to this brief with its action set to execute-task and its fields filled for this task. Answer its questions yourself.
        10. Validate the delivery against the uncommitted git diff and the task file: tests exist and genuinely verify the defined behaviors, test and lint runs pass, scope is respected, quality holds. Append observations and verdict to the task file.
        11. If approved: set the task status to `done`, stage the task's files, commit locally with a Conventional Commit message, and terminate the implementer.
        12. If rework is needed: set the status to `retry` plus attempt number, append rework items to the task file, and send them to the live implementer with action rework-task; validate again. After 3 failed attempts, discard that task's uncommitted changes, set the status to `blocked`, terminate the implementer, skip tasks that depend on it, and continue with independent ones.
        Close:
        13. Update the cycle {CYCLE} row in {CAMPAIGN_FILE} to `done`, or to `blocked` with the reason when any task was blocked or skipped. Commit remaining plan state with `chore(campaign): close cycle {CYCLE} of {SLUG}` and leave the worktree clean.
        14. Return one line ending with `<signal code="CYCLE_DONE">` or `<signal code="CYCLE_BLOCKED">`.
      </instructions>
      <constraints>
        <constraint>One work point per cycle; never repeat a work point already present in the cycle log.</constraint>
        <constraint>Never implement task code yourself and never approve a delivery that lacks tests genuinely verifying the defined behaviors.</constraint>
        <constraint>Commit locally only; never push, never mutate cloud resources, never touch files outside the campaign scope.</constraint>
      </constraints>
    </template>

    <template role="implementer" executor="implementer">
      <job>Single-task implementer: deliver code and tests for one task and report factual results without self-validation.</job>
      <input>
        <action>{ACTION}</action>
        <task_num>{TASK_NUM}</task_num>
        <campaign_file>{CAMPAIGN_FILE}</campaign_file>
        <plan_file>{PLAN_FILE}</plan_file>
        <task_file>{TASK_FILE}</task_file>
        <rework_notes>{REWORK_NOTES}</rework_notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. The Planner that dispatched you is your only counterpart.
        When {ACTION} is execute-task:
        1. Read {CAMPAIGN_FILE}, {PLAN_FILE}, and {TASK_FILE} for task {TASK_NUM}.
        2. Implement changes strictly within the scope defined in {TASK_FILE}. If blocked or if planned instructions contradict codebase realities, stop immediately and notify the Planner.
        3. Author tests covering the defined behaviors (unit tests for code; smoke tests, schema validations, or linters for non-code files) and run test suites and linters. Fix defects until all checks pass.
        4. Append a concise, factual implementation report to {TASK_FILE}: changed files, tests written and executed, test and lint outcomes, blockers, and Planner decisions applied. No self-evaluation.
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
