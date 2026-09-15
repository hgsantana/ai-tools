---
name: dev-ai-tools
description: >
  Execute a specified plan under dev/, or list pending plans, propose an
  order, and run them; or agree one task with the user. Use for /dev-ai-tools
  or after plan acceptance. Impact: edits code, runs commands, commits each
  step on a dedicated branch, archives the plan or task, pushes, and opens a
  pull request unattended once all steps finish. Agent: session.
argument-hint: "[plan paths, or the task to implement]"
---

<skill name="dev-ai-tools">
  <overview>
    Execute a specified plan under dev/{SLUG}/, a queue of pending plans, or one task agreed with the user.
    The session implements, accepts, commits, archives, and delivers the pull request itself; builds and tests go to a default worker.
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

    <step id="2" name="branch_and_record">
      Read the unit of work and the repository rules (README.md, AGENTS.md if present).
      Check out `plan/{SLUG}` from {BASE_BRANCH} and commit the unit first: `chore(dev): plan {SLUG}` (or `chore(dev): task {SLUG}`).
    </step>

    <step id="3" name="stage_loop">
      For each stage in dependency order (a task is one stage), following `<status_protocol>`:
        1. Set W and record the stage's Executor in the base plan Status table, then implement the stage: code and behaviour tests within its declared files, matching surrounding style, with factual notes in its Implementation log. Set V.
        2. Review the working-tree diff against the stage objective, declared files, and acceptance criteria.
        3. Set T and send the stage's test and verification commands to `<template role="stage-verifier">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
        4. On passing evidence and met criteria: stage path by path, commit with the stage's Conventional Commit message, and set F.
        5. Otherwise: append concrete correction tasks to the stage log, set R1..R3, and retry up to three times, then set E.
      Interrupt the user only for a blocker, a decision uncovered by implementation, or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>

    <step id="4" name="archive_and_deliver">
      When every stage is terminal: copy the unit to dev/tmp/finished/{SLUG}, remove it with `git rm -r dev/{SLUG}` (or `git rm dev/{SLUG}.md`), and commit `chore(dev): archive {SLUG}`.
      Push `plan/{SLUG}` and open a pull request targeting {BASE_BRANCH} with `gh pr create`, or write dev/tmp/{SLUG}-review.patch when no host is available.
      Write the summary report to dev/tmp/{SLUG}-report.md.
    </step>

    <step id="5" name="report_and_handover">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or review patch path.
      In Queue mode, repeat `<step id="2">`, `<step id="3">`, and `<step id="4">` for the next accepted plan.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="stage-verifier" executor="default-worker">
      <job>Default worker: run builds and tests and collect factual evidence.</job>
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
    The accepting context owns every state except V: the session in dev-ai-tools and vibe-ai-tools, the execution pass in campaign-ai-tools.
    <states>
      <state code="W">Working - set by the accepting context before implementation starts</state>
      <state code="V">Validating - set by whoever implemented the stage once it is ready for review</state>
      <state code="R1..R3">Rework - corrections after review</state>
      <state code="T">Testing - verification running</state>
      <state code="E">Exhausted - blocked or correction budget exceeded</state>
      <state code="F">Finished - accepted and committed</state>
    </states>
  </status_protocol>

  <boundaries>
    <rule id="session-owns-delivery">The session owns intake, implementation, acceptance, commits, archival, and pull-request delivery.</rule>
    <rule id="substance-on-disk">Write substance to the unit's files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`.</rule>
  </boundaries>
</skill>
