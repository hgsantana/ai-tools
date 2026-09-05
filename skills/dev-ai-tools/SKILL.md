---
name: dev-ai-tools
description: >
  Execute a specified plan under dev/, or list pending plans, propose an
  order, and run them; or agree one task with the user. Use for /dev-ai-tools
  or after plan acceptance. Impact: edits code, runs commands, commits each
  step on a dedicated branch, archives the plan or task, pushes, and opens a
  pull request unattended once all steps finish. Agent: planner-ai-tools.
argument-hint: "[plan paths, or the task to implement]"
---

<skill name="dev-ai-tools">
  <overview>
    Execute a specified plan under dev/{SLUG}/, a queue of pending plans, or one task agreed with the user.
    The host session manages mode selection and user alignment, then dispatches planner-ai-tools to coordinate
    execution, own acceptance, sub-dispatch implementers/mechanicals, and deliver the pull request.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_mode">
      Select mode based on input:
      - Specified (path like `dev/{SLUG}/`, `dev/{SLUG}.md`, or archived slug): run that unit.
      - Queue (empty or `dev`): find unfinished base plans (`dev/*/0-*.md`), propose execution order, run accepted list one by one.
      - Task (anything else): agree one task interactively with user in their language, write `dev/{SLUG}.md`.
      Verify repository root with `git rev-parse --show-toplevel`.
      Resolve base branch from plan base or request-time branch.
    </step>

    <step id="2" name="execution_dispatch">
      Dispatch a fresh, high-reasoning coordinator using `<template role="dev-coordinator">` from `<dispatch_templates>`,
      substituting {UNIT_PATH}, {BASE_BRANCH}, and {SLUG}.
      The coordinator owns execution, acceptance, and delivery as its template instructs, and ends with one `<signal>` from `<return_protocol>`.
    </step>

    <step id="3" name="report_and_handover">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or local review patch.
      If in Queue mode, repeat `<step id="2">` for the next accepted plan in sequence.
      Interrupt user during execution only for approvals reserved by USER-AGENTS `<security_guardrails>` and escalated by the coordinator.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="dev-coordinator" agent="planner-ai-tools">
      <job>Development execution coordinator: own plan delivery, acceptance, and sub-dispatching.</job>
      <input>
        <unit_path>{UNIT_PATH}</unit_path>
        <base_branch>{BASE_BRANCH}</base_branch>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read the unit of work ({UNIT_PATH}) and repository rules (README.md, AGENTS.md).
        Verify repo root and check out branch plan/{SLUG} from {BASE_BRANCH}.
        Create initial commit introducing unit: chore(dev): plan {SLUG} (or chore(dev): task {SLUG}).
        For each stage in dependency order, following `<status_protocol>`:
          1. Set status W, then sub-dispatch `<template role="stage-implementer">` to write code and tests.
          2. Inspect working tree diffs against stage objective, declared files, and acceptance criteria.
          3. Set status T, then sub-dispatch `<template role="stage-verifier">` to run tests and verification.
          4. If tests pass and criteria met: stage path-by-path, commit with Conventional Commits (feat: ..., fix: ...), set status F.
          5. If criteria fail: append concrete correction tasks to stage log, set status R1..R3, retry up to 3 attempts, then E.
        Archive when all stages reach terminal status:
          1. Copy locally to dev/tmp/finished/{SLUG}.
          2. Remove from repo: git rm -r dev/{SLUG} (or git rm dev/{SLUG}.md).
          3. Commit archival: chore(dev): archive {SLUG}.
        Push branch plan/{SLUG} and open pull request targeting {BASE_BRANCH} via gh pr create (or write dev/tmp/{SLUG}-review.patch).
        Write summary report to dev/tmp/{SLUG}-report.md.
        End with one `<signal>` from `<return_protocol>`.
      </instructions>
      <constraints>
        <constraint>All work stays on plan/{SLUG}; preserve base branch and pre-existing history.</constraint>
        <constraint>Sub-dispatch `<template role="stage-implementer">` for code changes and `<template role="stage-verifier">` for builds/tests.</constraint>
        <constraint>Do not modify production code directly in coordinator context; own acceptance and commits.</constraint>
        <constraint>Escalate approvals reserved by USER-AGENTS `<security_guardrails>` to the host session.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" agent="implementer-ai-tools">
      <job>Implementer worker: write and edit code and unit tests for the assigned stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read the assigned stage file of dev/{SLUG}/. Implement only that file's step.
        Match surrounding codebase style and keep edits within declared files.
        Write unit tests asserting observable behavior for delivered changes.
        Append factual implementation notes to the Implementation log of {STAGE_FILE}.
        Set status V per `<status_protocol>`, append report to {STAGE_FILE}, and return.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in working tree for coordinator audit.</constraint>
      </constraints>
    </template>

    <template role="stage-verifier" agent="mechanical-ai-tools">
      <job>Mechanical worker: run builds, tests, and collect factual evidence.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute {COMMANDS} without design decisions.
        Capture stdout and stderr to dev/tmp/{TOPIC}-output.log.
        Return facts: command, exit code, and output path.
      </instructions>
      <constraints>
        <constraint>Do not modify production or test code unless explicitly passed as a patch.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <status_protocol>
    <states>
      <state code="W">Working - implementation in progress (set by coordinator before implementer dispatch)</state>
      <state code="V">Validating - ready for review (set by implementer)</state>
      <state code="R1..R3">Rework - corrections after review (set by coordinator)</state>
      <state code="T">Testing - tests being executed (set by coordinator)</state>
      <state code="E">Exhausted - blocked or correction budget exceeded (set by coordinator)</state>
      <state code="F">Finished - accepted and committed (set by coordinator)</state>
    </states>
  </status_protocol>

  <return_protocol>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_URL}</signal>
    <signal code="BLOCKED">BLOCKED {REPORT_PATH} {REASON}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-owns-intake">Session owns intake, user alignment, and final chat reporting.</rule>
    <rule id="coordinator-owns-delivery">Planner coordinator owns acceptance, staging, commits, archival, and PR creation.</rule>
    <rule id="substance-on-disk">Subagents write substance to assigned files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
  </boundaries>
</skill>
