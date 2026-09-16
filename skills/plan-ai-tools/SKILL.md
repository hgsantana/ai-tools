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
      When the change is small enough for one commit, present `dev-ai-tools` Task mode: state its Impact and Agent from that skill description and obtain acceptance before invoking `/dev-ai-tools` in Task mode. Apply that handoff without re-entering USER-AGENTS `<routing_gate>`. On refusal, end with a short planning assessment and write no plan files.
      Derive a kebab-case {SLUG}.
    </step>
    <step id="3" name="plan_writing">
      Read the repository README.md, AGENTS.md if present, docs, and relevant code paths.
      Send broad read-only discovery to `<template role="repo-discovery">` from `<dispatch_templates>`, substituting {QUESTIONS} and {TOPIC}; read or grep directly for pinpoint lookups.
      Split delivery into isolated stages, one Conventional Commit per stage, and write `dev/{SLUG}/0-{SLUG}.md` plus one numbered stage file per stage per `<plan_file_format>`.
      Write the plan only under dev/{SLUG}/, leave product and test code unchanged, and leave the Status table's Status and Executor cells empty.
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
        <constraint>Leave product, test, and plan files unchanged; do not commit or change branches.</constraint>
        <constraint>The sole write is the report file dev/tmp/{TOPIC}.md.</constraint>
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
    finished/{SLUG}/  # Local archive copy (made once every required stage is F)
    </structure>
    Base plan sections: Status table (Stage, Status, Executor), Goal, Base branch, Execution graph, Stages index, and Open questions and risks when any.
    Stage file sections: Objective, Files (Create/Modify/Remove), Steps, Tests, Acceptance criteria, Commit message, Dependencies, Implementation log.
  </plan_file_format>

  <boundaries>
    <rule id="write-under-slug">Write the plan only under dev/{SLUG}/; the discovery report may write only dev/tmp/{TOPIC}.md; dev-ai-tools owns dev/tmp/finished/.</rule>
    <rule id="planning-only">Limit this workflow to planning: leave product code and builds unchanged.</rule>
    <rule id="plan-is-deliverable">Treat the saved plan as the deliverable until the user accepts the /dev-ai-tools offer.</rule>
    <rule id="task-mode-acceptance">A one-commit route into dev-ai-tools Task mode requires stating that skill's Impact and Agent and obtaining acceptance first; refusal ends this skill with a short planning assessment.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
