---
name: plan-ai-tools
description: >
  Explore the repository and write a multi-file implementation plan under
  dev/. Use for /plan-ai-tools or when a non-trivial change needs planning
  first. Impact: writes only planning files under dev/; product code, commits,
  and remote state remain unchanged. Agent: session.
argument-hint: "[description of the change, feature, or fix to plan]"
---

<skill name="plan-ai-tools">
  <overview>
    Explore a change and write its canonical multi-file implementation plan under dev/{SLUG}/.
    The session aligns with the user, designs, and writes the plan itself; broad discovery goes to a default worker.
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
    <step id="3" name="plan_writing">
      Read the repository README.md, AGENTS.md if present, docs, and relevant code paths.
      Send broad read-only discovery to `<template role="repo-discovery">` from `<dispatch_templates>`, substituting {QUESTIONS} and {TOPIC}; read or grep directly for pinpoint lookups.
      Split delivery into isolated stages, one Conventional Commit per stage, and write `dev/{SLUG}/0-{SLUG}.md` plus one numbered stage file per stage per `<plan_file_format>`.
      Write only under dev/{SLUG}/, leave product and test code unchanged, and leave the Status table's Status and Executor cells empty.
    </step>
    <step id="4" name="report_and_handover">
      The plan itself is the report. In the user's language, chat gives the base path
      (opened where supported), a one-line outcome, and numbered open questions.
      Then offer `/dev-ai-tools` against that saved slug, stating its Impact and Agent from the skill description.
      On user acceptance, invoke `/dev-ai-tools` against the plan without re-entering USER-AGENTS `<routing_gate>`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="repo-discovery" executor="default-worker">
      <job>Default worker: collect read-only repository facts for planning.</job>
      <input>
        <questions>{QUESTIONS}</questions>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Answer {QUESTIONS} from the working tree with read-only searches, file reads, and commands.
        Write file paths, line references, and command outputs to dev/tmp/{TOPIC}.md.
        Return the output path and a one-line summary.
      </instructions>
      <constraints>
        <constraint>Read-only: do not edit files, commit, or change branches.</constraint>
        <constraint>Report facts; leave design decisions to the caller.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <plan_file_format>
    <structure>
dev/
  {SLUG}/
    0-{SLUG}.md       # Base plan
    1-{SLUG}.md       # Stage 1 (Single Conventional Commit boundary)
    2-{SLUG}.md       # Stage 2
    F1-{SLUG}.md      # Fix file (added during corrections if needed)
  tmp/
    finished/{SLUG}/  # Local archive copy (made once terminal)
    </structure>
    Base plan sections: Status table (Stage, Status, Executor), Goal, Base branch, Execution graph, Stages index, and Open questions and risks when any.
    Stage file sections: Objective, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, Commit message, Dependencies, Implementation log.
  </plan_file_format>

  <boundaries>
    <rule id="write-under-slug">Write only under dev/{SLUG}/; dev-ai-tools owns dev/tmp/finished/.</rule>
    <rule id="planning-only">Limit this workflow to planning: leave product code and builds unchanged.</rule>
    <rule id="plan-is-deliverable">Treat the saved plan as the deliverable until the user accepts the /dev-ai-tools offer.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` through the harness's native subagent API (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent) with its default agent type and model, passing the populated payload and file paths, never conversation context. Builds, test suites, script runs, and bulk fact collection go there; a single pinpoint command the session needs for its next decision runs in the session. If spawning fails, run the payload in the session and state that in the report. Campaign-ai-tools passes never take this fallback: a pass that cannot spawn ends with BLOCKED.</rule>
  </boundaries>
</skill>
