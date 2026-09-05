---
name: plan-ai-tools
description: >
  Explore the repository and write a multi-file implementation plan under
  dev/. Use for /plan-ai-tools or when a non-trivial change needs planning
  first. Impact: writes only planning files under dev/; product code, commits,
  and remote state remain unchanged. Agent: planner-ai-tools.
argument-hint: "[description of the change, feature, or fix to plan]"
---

<skill name="plan-ai-tools">
  <overview>
    Explore a change and write its canonical multi-file implementation plan under dev/<slug>/.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_branch">
      Verify the repository root with `git rev-parse --show-toplevel`.
      Record the currently checked-out branch by name as base and keep it checked out throughout analysis.
      If HEAD is detached, ask the user to choose and check out a branch before continuing.
    </step>
    <step id="2" name="user_alignment">
      In the user's language, clarify scope boundaries, present trade-offs and alternative approaches,
      and resolve open architectural questions before drafting the plan structure.
      Route a change small enough for one commit by running dev-ai-tools in Task mode instead.
      Derive a kebab-case slug.
    </step>
    <step id="3" name="plan_dispatch">
      Dispatch `planner-ai-tools` using `<template role="planner-ai-tools">` from `<dispatch_templates>`,
      substituting {SLUG}, {BASE_BRANCH}, and {USER_REQUEST}.
      The planner drafts `dev/<slug>/0-<slug>.md` and each stage file `dev/<slug>/<n>-<slug>.md`.
    </step>
    <step id="4" name="report_and_handover">
      The plan itself is the report. In the user's language, chat gives the base path
      (opened where supported), a one-line outcome, and numbered open questions.
      Then offer `/dev-ai-tools` against that saved slug, stating its Impact and Agent from the skill description.
      On user acceptance, invoke `/dev-ai-tools` against the plan without re-entering `<routing_gate>`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="planner-ai-tools">
      <role>Planner worker: design approach, commit boundaries, and multi-stage delivery graph.</role>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <user_request>{USER_REQUEST}</user_request>
      </input>
      <instructions>
        Read repository README.md, AGENTS.md, docs, and relevant code paths.
        Structure delivery into isolated stages where each stage defines a Conventional Commit boundary.
        Write base plan `dev/{SLUG}/0-{SLUG}.md` containing Goal, Base branch, Execution graph, and Stages index.
        Write each stage file `dev/{SLUG}/<n>-{SLUG}.md` containing Objective, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, and Commit message.
      </instructions>
      <constraints>
        <constraint>Write only under dev/{SLUG}/.</constraint>
        <constraint>Do not edit product or test code files.</constraint>
        <constraint>Leave Status and Agent empty in the base plan (dev-ai-tools owns execution status).</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <plan_file_format>
    <structure>
dev/
  <slug>/
    0-<slug>.md       # Base plan (Goal, Base branch, Execution graph, Stages table)
    1-<slug>.md       # Stage 1 (Single Conventional Commit boundary)
    2-<slug>.md       # Stage 2
    F1-<slug>.md      # Fix file (added during corrections if needed)
  tmp/
    finished/<slug>/  # Local archive copy (made once terminal)
    </structure>
  </plan_file_format>

  <boundaries>
    <boundary>Write only under dev/<slug>/; dev-ai-tools owns dev/tmp/finished/.</boundary>
    <boundary>Limit this workflow to planning: leave product code and builds unchanged.</boundary>
    <boundary>Treat the saved plan as the deliverable until the user accepts the /dev-ai-tools offer.</boundary>
  </boundaries>
</skill>
