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
    Execute a specified plan under dev/<slug>/, a queue of pending plans, or one task agreed with the user.
    The host session manages mode selection and user alignment, then dispatches planner-ai-tools to coordinate
    execution, own acceptance, sub-dispatch implementers/mechanicals, and deliver the pull request.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_mode">
      Select mode based on input:
      - Specified (path like `dev/<slug>/`, `dev/<slug>.md`, or archived slug): run that unit.
      - Queue (empty or `dev`): find unfinished base plans (`dev/*/0-*.md`), propose execution order, run accepted list one by one.
      - Task (anything else): agree one task interactively with user in their language, write `dev/<slug>.md`.
      Verify repository root with `git rev-parse --show-toplevel`.
      Resolve base branch from plan base or request-time branch.
    </step>

    <step id="2" name="execution_dispatch">
      Dispatch a fresh, high-reasoning `planner-ai-tools` instance using `<template role="dev-coordinator">` from `<dispatch_templates>`.
      The planner coordinator owns execution, acceptance, and delivery:
      - Checks out dedicated work branch `plan/<slug>` from base branch.
      - Commits the unit of work: `chore(dev): plan <slug>` or `chore(dev): task <slug>`.
      - Executes stages sequentially, sub-dispatching `implementer-ai-tools` and `mechanical-ai-tools`.
      - Audits code against acceptance criteria and commits each stage with Conventional Commits.
      - Archives plan files to `dev/tmp/finished/<slug>/`, commits `chore(dev): archive <slug>`.
      - Pushes `plan/<slug>` and opens pull request (or writes review patch).
      - Returns: `DELIVERED <report_path> <pr_url>` or `BLOCKED <report_path> <reason>`.
    </step>

    <step id="3" name="report_and_handover">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or local review patch.
      If in Queue mode, proceed to next accepted plan in sequence.
      Interrupt user during execution only for security-reserved approvals escalated by the planner coordinator.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="dev-coordinator">
      <role>Development execution coordinator (planner-ai-tools): own plan delivery, acceptance, and sub-dispatching.</role>
      <input>
        <unit_path>{UNIT_PATH}</unit_path>
        <base_branch>{BASE_BRANCH}</base_branch>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read the unit of work ({UNIT_PATH}) and repository rules (README.md, AGENTS.md).
        Verify repo root and check out branch plan/{SLUG} from {BASE_BRANCH}.
        Create initial commit introducing unit: chore(dev): plan {SLUG} (or chore(dev): task {SLUG}).
        For each stage in dependency order:
          1. Sub-dispatch implementer-ai-tools using &lt;template role="implementer-ai-tools"&gt; to write code and tests.
          2. Inspect working tree diffs against stage objective, declared files, and acceptance criteria.
          3. Sub-dispatch mechanical-ai-tools using &lt;template role="mechanical-ai-tools"&gt; to run tests and verification.
          4. If tests pass and criteria met: stage path-by-path and commit with Conventional Commits (feat: ..., fix: ...).
          5. If criteria fail: append concrete correction tasks to stage log, retry up to 3 attempts.
        Archive when all stages reach terminal status:
          1. Copy locally to dev/tmp/finished/{SLUG}.
          2. Remove from repo: git rm -r dev/{SLUG} (or git rm dev/{SLUG}.md).
          3. Commit archival: chore(dev): archive {SLUG}.
        Push branch plan/{SLUG} and open pull request targeting {BASE_BRANCH} via gh pr create (or write dev/tmp/{SLUG}-review.patch).
        Write summary report to dev/tmp/{SLUG}-report.md.
        Return DELIVERED dev/tmp/{SLUG}-report.md &lt;PR_URL&gt; (or BLOCKED dev/tmp/{SLUG}-report.md with blocker).
      </instructions>
      <constraints>
        <constraint>All work stays on plan/{SLUG}; preserve base branch and pre-existing history.</constraint>
        <constraint>Sub-dispatch implementer-ai-tools for code changes and mechanical-ai-tools for builds/tests.</constraint>
        <constraint>Do not modify production code directly in coordinator context; own acceptance and commits.</constraint>
        <constraint>Escalate security-reserved approvals (cloud mutation, destructive action) to host session.</constraint>
      </constraints>
    </template>

    <template role="implementer-ai-tools">
      <role>Implementer worker: write and edit code and unit tests for the assigned stage.</role>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Read the assigned stage file. Implement only that file's step.
        Match surrounding codebase style and keep edits within declared files.
        Write unit tests asserting observable behavior for delivered changes.
        Append factual implementation notes to the Implementation log of {STAGE_FILE}.
        Set status V upon completion, append report to {STAGE_FILE}, and return.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Do not edit files outside declared stage files.</constraint>
        <constraint>Do not commit or push; leave changes in working tree for coordinator audit.</constraint>
      </constraints>
    </template>

    <template role="mechanical-ai-tools">
      <role>Mechanical worker: run builds, tests, and collect factual evidence.</role>
      <instructions>
        Execute the specified build and test commands without design decisions.
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
      <state code="W">Working - implementation in progress (set before implementer dispatch)</state>
      <state code="V">Validating - ready for review (set by implementer)</state>
      <state code="R1..R3">Rework - corrections after review (set by coordinator)</state>
      <state code="T">Testing - tests being executed (set by coordinator)</state>
      <state code="E">Exhausted - blocked or correction budget exceeded (set by coordinator)</state>
      <state code="F">Finished - accepted and committed (set by coordinator)</state>
    </states>
  </status_protocol>

  <boundaries>
    <rule>Session owns intake, user alignment, and final chat reporting.</rule>
    <rule>Planner coordinator owns acceptance, staging, commits, archival, and PR creation.</rule>
    <rule>Subagents write substance to assigned files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule>Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule>Mutations to cloud resources or destructive operations require explicit user approval.</rule>
  </boundaries>
</skill>
