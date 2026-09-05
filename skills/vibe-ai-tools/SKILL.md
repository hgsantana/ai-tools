---
name: vibe-ai-tools
description: >
  Plan a change under dev/, then execute that plan through dev-ai-tools,
  deciding in-scope implementation questions. Use for /vibe-ai-tools.
  Impact: after the plan is on disk, edits on a dedicated branch, commits,
  pushes, and opens a pull request unattended; edits and removals can be hard
  to undo. Pre-existing history remains intact. Cloud and destructive
  operations require separate approval. Agent: planner-ai-tools.
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change under dev/{SLUG}/ interactively with the user, then execute and deliver that plan
    unattended through dev-ai-tools mechanics, deciding in-scope implementation questions autonomously.
  </overview>

  <session_workflow>
    <step id="1" name="interactive_planning">
      Refine scope, architecture, and trade-offs interactively with the user in chat.
      Dispatch `<template role="plan-author">` from `<dispatch_templates>`, substituting {SLUG}, {BASE_BRANCH}, and {REQUEST},
      to draft the canonical plan under `dev/{SLUG}/` (base and stage files).
      Skip the standalone `/dev-ai-tools` offer once the plan is on disk.
    </step>

    <step id="2" name="unattended_execution">
      Dispatch a fresh, high-reasoning coordinator using `<template role="vibe-coordinator">` from `<dispatch_templates>`,
      substituting {PLAN_PATH}, {SLUG}, and {BASE_BRANCH}.
      The coordinator executes unattended as its template instructs and ends with one `<signal>` from `<return_protocol>`.
    </step>

    <step id="3" name="report">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or local review patch.
      Interrupt user during execution only for unresolvable blockers or approvals reserved by USER-AGENTS `<security_guardrails>` and escalated by the coordinator.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="plan-author" agent="planner-ai-tools">
      <job>Planner worker: write the multi-stage plan under dev/{SLUG}/.</job>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <request>{REQUEST}</request>
      </input>
      <instructions>
        Plan {REQUEST} against {BASE_BRANCH}.
        Draft 0-{SLUG}.md and numbered stage files under dev/{SLUG}/ in the plan-ai-tools `<plan_file_format>`.
        Do not edit product code.
      </instructions>
    </template>

    <template role="vibe-coordinator" agent="planner-ai-tools">
      <job>Vibe execution coordinator: execute plan unattended, decide trade-offs, and deliver PR.</job>
      <input>
        <plan_path>{PLAN_PATH}</plan_path>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
      </input>
      <instructions>
        Read plan from {PLAN_PATH} and create work branch plan/{SLUG} from {BASE_BRANCH}.
        Commit initial plan: chore(dev): plan {SLUG}.
        Execute each stage sequentially, following dev-ai-tools `<status_protocol>`:
          1. Sub-dispatch `<template role="stage-implementer">` to write code and tests.
          2. Autonomously resolve in-scope implementation questions and retry choices.
          3. Record every decision and trade-off in dev/{SLUG}/vibe-decisions.md.
          4. Sub-dispatch `<template role="stage-verifier">` to verify test suites.
          5. Commit each accepted stage locally with Conventional Commits.
        Archive plan, stages, and decisions: copy to dev/tmp/finished/{SLUG}/, git rm -r dev/{SLUG}/.
        Commit archival: chore(dev): archive {SLUG}.
        Push branch and open pull request (or write review patch to dev/tmp/{SLUG}-review.patch).
        Write summary report to dev/tmp/{SLUG}-report.md.
        End with one `<signal>` from `<return_protocol>`.
      </instructions>
      <constraints>
        <constraint>Execute unattended; do not ask user routine questions settled by code evidence.</constraint>
        <constraint>Sub-dispatch `<template role="stage-implementer">` for code changes and `<template role="stage-verifier">` for tests.</constraint>
        <constraint>All changes land on plan/{SLUG}; preserve base branch and history.</constraint>
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
        Implement the stage in {STAGE_FILE} for dev/{SLUG}/: match surrounding style, write tests, append report.
        Set status V per dev-ai-tools `<status_protocol>`.
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

  <return_protocol>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_URL}</signal>
    <signal code="BLOCKED">BLOCKED {REPORT_PATH} {REASON}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-owns-alignment">Session owns user alignment, plan review, and final chat reporting.</rule>
    <rule id="coordinator-owns-execution">Planner coordinator owns unattended execution, in-scope decisions, acceptance, commits, archival, and PR.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="log-decisions">Log in-scope decisions to dev/{SLUG}/vibe-decisions.md for PR reviewer audit.</rule>
    <rule id="reserved-approvals">Never bypass approvals reserved by USER-AGENTS `<security_guardrails>` for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
