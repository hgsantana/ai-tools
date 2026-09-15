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
    Task mode: the session implements the single stage. Specified and queue: a fresh session-subagent per plan implements, accepts, commits, and opens the pull request. Builds and tests go to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_mode">
      Select mode based on input:
      - Specified (path like `dev/{SLUG}/`, `dev/{SLUG}.md`, or archived slug): spawn a fresh `<template role="plan-executor">` from `<dispatch_templates>`, substituting {SLUG}, {BASE_BRANCH}, and {PLAN_PATH}. Record only the `<signal>` from `<return_protocol>`.
      - Queue (empty or `dev`): find unfinished base plans (`dev/*/0-*.md`), propose execution order, then spawn a fresh `<template role="plan-executor">` for each accepted plan; record only the `<signal>`; continue on `<signal code="DELIVERED">`; stop on `<signal code="BLOCKED">`.
      - Task (anything else): agree one task interactively with user in their language, write `dev/{SLUG}.md`, then run `<step id="2">`, `<step id="3">`, and `<step id="4">` in this session.
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
      After a `<template role="plan-executor">` spawn, report from the `<signal>` only: do not open the report body or plan files.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="plan-executor" executor="session-subagent">
      <job>Execution pass: deliver one plan or task file on plan/{SLUG} and open the pull request.</job>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <plan_path>{PLAN_PATH}</plan_path>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are stated here.
        Check out plan/{SLUG} from {BASE_BRANCH} and commit {PLAN_PATH} first: `chore(dev): plan {SLUG}` (or `chore(dev): task {SLUG}` for a task file).
        For each stage in dependency order (a task is one stage), own every status except V: set W and record Executor; implement code and behaviour tests within declared files; set V; review the working-tree diff against objective, declared files, and acceptance; set T and spawn `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic (it writes logs under dev/tmp/ and returns command, exit code, and path); on pass, commit with the stage's Conventional Commit message and set F; else append corrections, set R1..R3, retry up to three times, then set E.
        When every stage is terminal: copy the unit to dev/tmp/finished/{SLUG}, git rm it, commit `chore(dev): archive {SLUG}`, push plan/{SLUG}, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write dev/tmp/{SLUG}-review.patch, and write dev/tmp/{SLUG}-report.md.
        End with one `<signal>` from `<return_protocol>`: DELIVERED or BLOCKED.
      </instructions>
      <constraints>
        <constraint>Leave builds and tests to default workers; own implementation, review, acceptance, commits, and the pull request.</constraint>
        <constraint>Preserve pre-existing commit history.</constraint>
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
        Capture stdout and stderr to dev/tmp/{TOPIC}-output.log.
        Return facts: command, exit code, and output path.
      </instructions>
      <constraints>
        <constraint>Do not modify production or test code unless explicitly passed as a patch.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH}</signal>
    <signal code="BLOCKED">BLOCKED {REASON}</signal>
  </return_protocol>

  <status_protocol>
    The accepting context owns every state except V: the session in Task mode; otherwise the execution pass (dev-ai-tools `<template role="plan-executor">`, vibe-ai-tools `<template role="vibe-executor">`, or campaign-ai-tools `<template role="campaign-executor">`).
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
    <rule id="session-owns-intake">The session owns intake, Task-mode delivery, and reporting from the `<signal>`; each specified or queued plan runs in a fresh `<template role="plan-executor">`.</rule>
    <rule id="signals-only">After spawning `<template role="plan-executor">`, the session stores only the `<signal>` line and paths. It does not read the plan or the report body.</rule>
    <rule id="no-host-fallback">If `<template role="plan-executor">` cannot be spawned, do not run that plan's delivery in the session: report the missing capability.</rule>
    <rule id="substance-on-disk">Write substance to the unit's files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>`: `<template role="plan-executor">` runs as `executor="session-subagent"` on the session's own model; `<template role="stage-verifier">` runs as `executor="default-worker"`.</rule>
  </boundaries>
</skill>
