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
      Verify repository root with `git rev-parse --show-toplevel`.
      Select mode based on input:
      - Specified (path like `dev/{SLUG}/`, `dev/{SLUG}.md`, or archived slug): before any mutation, locate the unit as `dev/{SLUG}/` or `dev/{SLUG}.md` if present; else look up `dev/tmp/finished/{SLUG}/` and the archive commit in Git history. Record {BASE_BRANCH} from the plan base or the request-time branch. If `plan/{SLUG}` already exists with accepted F stages, treat as resume: preserve those commits and skip initialization already completed. An archived slug with no recoverable branch or unit returns `<signal code="BLOCKED">` without spawning. Otherwise spawn a fresh `<template role="plan-executor">` from `<dispatch_templates>`, substituting {SLUG}, {BASE_BRANCH}, and {PLAN_PATH}. Record only the `<signal>` from `<return_protocol>`.
      - Queue (empty or `dev`): find unfinished base plans (`dev/*/0-*.md`), propose execution order, then spawn a fresh `<template role="plan-executor">` for each accepted plan; record only the `<signal>`; continue on `<signal code="DELIVERED">`; stop on `<signal code="BLOCKED">` and do not advance the queue.
      - Task (anything else): agree one task interactively with user in their language, write `dev/{SLUG}.md`, then run `<step id="2">`, `<step id="3">`, and `<step id="4">` in this session.
    </step>

    <step id="2" name="branch_and_record">
      Read the unit of work and the repository rules (README.md, AGENTS.md if present).
      On a new unit: check out `plan/{SLUG}` from {BASE_BRANCH} and commit the unit first: `chore(dev): plan {SLUG}` (or `chore(dev): task {SLUG}`).
      On resume: stay on `plan/{SLUG}`, preserve accepted commits, and skip that first plan or task commit.
    </step>

    <step id="3" name="stage_loop">
      For each unfinished stage in dependency order (a task is one stage), following `<status_protocol>`:
        1. Set W and record the stage's Executor in the base plan Status table, then implement the stage: code and behaviour tests within its declared files, matching surrounding style, with factual notes in its Implementation log. Set V.
        2. Review the working-tree diff against the stage objective, declared files, and acceptance criteria.
        3. Set T and send the stage's test and verification commands to `<template role="stage-verifier">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
        4. On passing evidence and met criteria: stage path by path, commit with the stage's Conventional Commit message, and set F.
        5. Otherwise: append concrete correction tasks to the stage log, set R1..R3, and retry up to three times, then set E.
      On E: stop remaining stages, retain the work unit, and go to `<step id="4">` as blocked. Do not start a dependent stage.
      Interrupt the user only for a blocker, a decision uncovered by implementation, or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>

    <step id="4" name="archive_and_deliver">
      Successful completion is every required stage F. Only then: copy the unit to dev/tmp/finished/{SLUG}, remove it with `git rm -r dev/{SLUG}` (or `git rm dev/{SLUG}.md`), commit `chore(dev): archive {SLUG}`, push `plan/{SLUG}`, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write dev/tmp/{SLUG}-review.patch when no host is available, write dev/tmp/{SLUG}-report.md, and treat the outcome as `<signal code="DELIVERED">`.
      If any required stage is E, or a reserved approval is pending: retain the unit, do not archive, push, or open a pull request, write evidence to dev/tmp/{SLUG}-blocked.md, and treat the outcome as `<signal code="BLOCKED">`. Partial delivery is not authorized.
    </step>

    <step id="5" name="report_and_handover">
      In chat (user's language), provide the report or evidence path, a one-line outcome, and the PR URL or review patch path from the `<signal>` fields.
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
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`.
        If `plan/{SLUG}` already exists with accepted F stages, resume it: preserve those commits and skip the first plan or task commit. Otherwise check out plan/{SLUG} from {BASE_BRANCH} and commit {PLAN_PATH} first: `chore(dev): plan {SLUG}` (or `chore(dev): task {SLUG}` for a task file).
        For each unfinished stage in dependency order (a task is one stage), own every status except V: set W and record Executor in the base plan Status table; implement code and behaviour tests within declared files, matching surrounding style, with factual notes in the stage Implementation log; set V on that stage; review the working-tree diff against objective, declared files, and acceptance; set T and spawn `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic (it writes logs under dev/tmp/ and returns command, exit code, and path); on pass, commit with the stage's Conventional Commit message and set F; else append corrections, set R1..R3, retry up to three times, then set E.
        Successful completion is every required stage F. Only then: copy the unit to dev/tmp/finished/{SLUG}, git rm it, commit `chore(dev): archive {SLUG}`, push plan/{SLUG}, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write dev/tmp/{SLUG}-review.patch, write dev/tmp/{SLUG}-report.md, and end with `<signal code="DELIVERED">`.
        If any required stage is E, a nested spawn is missing, or a reserved approval is pending: retain the unit, do not archive, push, or open a pull request, write evidence to dev/tmp/{SLUG}-blocked.md, and end with `<signal code="BLOCKED">`. Do not start a dependent stage after E. Partial delivery is not authorized.
      </instructions>
      <constraints>
        <constraint>Leave builds and tests to default workers; own implementation, review, acceptance, commits, and the pull request.</constraint>
        <constraint>When a default worker cannot be spawned, do not run verification yourself: end with `<signal code="BLOCKED">` naming the missing nested-spawn capability.</constraint>
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
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_OR_PATCH}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <status_protocol>
    The accepting context owns every state except V: the session in Task mode; otherwise the execution pass (dev-ai-tools `<template role="plan-executor">`, vibe-ai-tools `<template role="vibe-executor">`, or campaign-ai-tools `<template role="campaign-executor">`).
    Successful completion requires every required stage F. E is a blocked outcome: retain the unit, skip archive and delivery, stop dependent stages, and return `<signal code="BLOCKED">`. Queue mode does not advance on E.
    <states>
      <state code="W">Working - set by the accepting context before implementation starts</state>
      <state code="V">Validating - set by whoever implemented the stage once it is ready for review</state>
      <state code="R1..R3">Rework - corrections after review</state>
      <state code="T">Testing - verification running</state>
      <state code="E">Exhausted - correction budget exceeded; maps to BLOCKED, never to delivery</state>
      <state code="F">Finished - accepted and committed</state>
    </states>
  </status_protocol>

  <boundaries>
    <rule id="session-owns-intake">The session owns intake, Task-mode delivery, and reporting from the `<signal>`; each specified or queued plan runs in a fresh `<template role="plan-executor">`.</rule>
    <rule id="signals-only">After spawning `<template role="plan-executor">`, the session stores only the `<signal>` line and its fields. It does not read the plan or the report body.</rule>
    <rule id="no-host-fallback">If `<template role="plan-executor">` cannot be spawned, do not run that plan's delivery in the session: report the missing capability.</rule>
    <rule id="no-nested-fallback">If `<template role="stage-verifier">` cannot be spawned, the execution pass does not run verification itself: it ends with `<signal code="BLOCKED">` naming the missing nested-spawn capability. Specified and queued passes never take USER-AGENTS `<rule id="spawn-fallback">`.</rule>
    <rule id="completion-is-f">Archive, push, and pull-request creation run only when every required stage is F. An E stage is BLOCKED and retains the work unit.</rule>
    <rule id="substance-on-disk">Write substance to the unit's files or dev/tmp/; chat carries paths and outcomes.</rule>
    <rule id="preserve-history">Preserve history predating this work; never force-push or rebase pre-existing commits.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="reserved-approvals">Mutations to cloud resources or destructive operations require explicit user approval per USER-AGENTS `<security_guardrails>`.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>`: `<template role="plan-executor">` runs as `executor="session-subagent"` on the session's own model; `<template role="stage-verifier">` runs as `executor="default-worker"`.</rule>
  </boundaries>
</skill>
