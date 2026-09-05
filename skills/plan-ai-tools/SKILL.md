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
    Explore a change and write its canonical multi-file implementation plan under dev/{SLUG}/.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_branch">
      Verify the repository root with `git rev-parse --show-toplevel`.
      Record the currently checked-out branch by name as {BASE_BRANCH} and keep it checked out throughout analysis.
      If HEAD is detached, ask the user to choose and check out a branch before continuing.
    </step>
    <step id="2" name="user_alignment">
      In the user's language, clarify scope boundaries, present trade-offs and alternative approaches,
      and resolve open architectural questions before drafting the plan structure.
      Route a change small enough for one commit by running dev-ai-tools in Task mode instead.
      Derive a kebab-case {SLUG}.
    </step>
    <step id="3" name="plan_dispatch">
      Dispatch `<template role="plan-author">` from `<dispatch_templates>`,
      substituting {SLUG}, {BASE_BRANCH}, and {USER_REQUEST}.
      The planner drafts `dev/{SLUG}/0-{SLUG}.md` and one numbered stage file per commit per `<plan_file_format>`.
    </step>
    <step id="4" name="report_and_handover">
      The plan itself is the report. In the user's language, chat gives the base path
      (opened where supported), a one-line outcome, and numbered open questions.
      Then offer `/dev-ai-tools` against that saved slug, stating its Impact and Agent from the skill description.
      On user acceptance, invoke `/dev-ai-tools` against the plan without re-entering USER-AGENTS `<routing_gate>`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="plan-author" agent="planner-ai-tools">
      <job>Planner worker: design approach, commit boundaries, and multi-stage delivery graph.</job>
      <input>
        <slug>{SLUG}</slug>
        <base_branch>{BASE_BRANCH}</base_branch>
        <user_request>{USER_REQUEST}</user_request>
      </input>
      <instructions>
        Plan {USER_REQUEST} against {BASE_BRANCH}.
        Read repository README.md, AGENTS.md, docs, and relevant code paths.
        Structure delivery into isolated stages where each stage defines a Conventional Commit boundary.
        Write base plan `dev/{SLUG}/0-{SLUG}.md` containing Goal, Base branch, Execution graph, and Stages index.
        Write each numbered stage file (1-{SLUG}.md, 2-{SLUG}.md, ...) under dev/{SLUG}/ containing Objective, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, and Commit message.
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
  {SLUG}/
    0-{SLUG}.md       # Base plan (Goal, Base branch, Execution graph, Stages table)
    1-{SLUG}.md       # Stage 1 (Single Conventional Commit boundary)
    2-{SLUG}.md       # Stage 2
    F1-{SLUG}.md      # Fix file (added during corrections if needed)
  tmp/
    finished/{SLUG}/  # Local archive copy (made once terminal)
    </structure>
  </plan_file_format>

  <boundaries>
    <rule id="write-under-slug">Write only under dev/{SLUG}/; dev-ai-tools owns dev/tmp/finished/.</rule>
    <rule id="planning-only">Limit this workflow to planning: leave product code and builds unchanged.</rule>
    <rule id="plan-is-deliverable">Treat the saved plan as the deliverable until the user accepts the /dev-ai-tools offer.</rule>
  </boundaries>
</skill>
