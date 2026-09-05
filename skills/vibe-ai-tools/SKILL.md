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
    Plan a change under dev/<slug>/ interactively with the user, then execute and deliver that plan
    unattended through dev-ai-tools, deciding in-scope implementation questions autonomously.
  </overview>

  <session_workflow>
    <step id="1" name="interactive_planning">
      Follow the planning workflow in the session directly:
      - Refine scope, architecture, and trade-offs interactively with the user in chat.
      - Dispatch `planner-ai-tools` using `<template role="planner-ai-tools">` to draft canonical plan under `dev/<slug>/` (base and stage files).
      - Skip standalone /dev-ai-tools offer once the plan is on disk.
    </step>

    <step id="2" name="unattended_execution">
      Dispatch a fresh, high-reasoning `planner-ai-tools` instance using `<template role="vibe-coordinator">` in unattended mode:
      - Coordinator creates branch `plan/<slug>` and initial commit `chore(dev): plan <slug>`.
      - Executes stages sequentially, sub-dispatching `implementer-ai-tools` and `mechanical-ai-tools`.
      - Autonomously resolves in-scope implementation questions and retry choices without interrupting the user.
      - Records each autonomous decision and trade-off in `dev/<slug>/vibe-decisions.md`.
      - Commits each stage with Conventional Commits, archives plan files, pushes branch, and opens pull request.
      - Returns: `DELIVERED <report_path> <pr_url>` or `BLOCKED <report_path> <reason>`.
    </step>

    <step id="3" name="report">
      In chat (user's language), provide the report path, a one-line outcome, and the PR URL or local review patch.
      Interrupt user during execution only for unresolvable blockers or security-reserved approvals escalated by coordinator.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="planner-ai-tools">
      <role>Planner worker: write multi-stage plan under dev/{SLUG}/.</role>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <request>{REQUEST}</request>
      </input>
      <instructions>
        Draft 0-{SLUG}.md and numbered stage files under dev/{SLUG}/.
        Do not edit product code.
      </instructions>
    </template>

    <template role="vibe-coordinator">
      <role>Vibe execution coordinator (planner-ai-tools): execute plan unattended, decide trade-offs, and deliver PR.</role>
      <input>
        <plan_path>dev/{SLUG}/0-{SLUG}.md</plan_path>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
      </input>
      <instructions>
        Read plan from {PLAN_PATH} and create work branch plan/{SLUG} from {BASE_BRANCH}.
        Commit initial plan: chore(dev): plan {SLUG}.
        Execute each stage sequentially:
          1. Sub-dispatch implementer-ai-tools using &lt;template role="implementer-ai-tools"&gt; to write code and tests.
          2. Autonomously resolve in-scope implementation questions and retry choices.
          3. Record every decision and trade-off in dev/{SLUG}/vibe-decisions.md.
          4. Sub-dispatch mechanical-ai-tools to verify test suites.
          5. Commit each accepted stage locally with Conventional Commits.
        Archive plan, stages, and decisions: copy to dev/tmp/finished/{SLUG}/, git rm -r dev/{SLUG}/.
        Commit archival: chore(dev): archive {SLUG}.
        Push branch and open pull request (or write review patch to dev/tmp/{SLUG}-review.patch).
        Write summary report to dev/tmp/{SLUG}-report.md.
        Return DELIVERED dev/tmp/{SLUG}-report.md &lt;PR_URL&gt;.
      </instructions>
      <constraints>
        <constraint>Execute unattended; do not ask user routine questions settled by code evidence.</constraint>
        <constraint>Sub-dispatch implementer-ai-tools for code changes and mechanical-ai-tools for tests.</constraint>
        <constraint>All changes land on plan/{SLUG}; preserve base branch and history.</constraint>
        <constraint>Escalate security-reserved approvals to host session.</constraint>
      </constraints>
    </template>

    <template role="implementer-ai-tools">
      <role>Implementer worker: write and edit code and unit tests for assigned stage.</role>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        Implement stage requirements, match surrounding style, write tests, and append report.
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

  <boundaries>
    <rule>Session owns user alignment, plan review, and final chat reporting.</rule>
    <rule>Planner coordinator owns unattended execution, in-scope decisions, acceptance, commits, archival, and PR.</rule>
    <rule>Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule>Log in-scope decisions to dev/<slug>/vibe-decisions.md for PR reviewer audit.</rule>
    <rule>Never bypass security approvals for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
