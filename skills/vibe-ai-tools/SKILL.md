---
name: vibe-ai-tools
description: >
  Formulate a user story interactively with the user, then autonomously execute
  architecture planning, atomic task implementation, validation, and pull request
  creation. The session acts as PO during story refinement, then takes full
  responsibility for all technical decisions—prioritizing zero-cost and easily
  reversible options—driving unattended execution through to PR delivery. Use
  for /vibe-ai-tools.
argument-hint: "[story or feature description to plan and implement]"
---

<skill name="vibe-ai-tools">
  <overview>
    Execute plan-ai-tools and implement-ai-tools sequentially with modified interaction boundaries. The session acts as Product Owner (PO) during the initial story refinement phase, clarifying scope, business rules, and acceptance criteria with the user. From story approval onward, the session assumes complete responsibility for all technical and architectural decisions—strictly prioritizing zero-cost and easily reversible choices for critical matters—operating autonomously through planning, task breakdown, code execution, validation, git cleanup, and pull request creation.
  </overview>

  <boundaries>
    <rule id="autonomous-decision-policy">Autonomous decision authority and escalation threshold:
      - Following user story approval in plan-ai-tools `<step id="6">`, the session assumes total responsibility for all subsequent technical and architectural decisions.
      - For all questions, trade-offs, or doubts raised by the Architect or Specialists, the session decides autonomously without consulting the user.
      - Core decision criterion: prioritize options that carry zero financial cost and ensure easy backup and reversibility for critical issues.
      - Escalation threshold: the session pauses to query the user via `<user_interaction>` only if neither zero-cost nor easily reversible options are possible (e.g., unavoidable paid third-party services, irreversible data loss, or destructive infrastructure actions).
      - All autonomous decisions and settled trade-offs are explicitly recorded in the "Decisions" section of `0-{SLUG}.md`.
    </rule>

    <rule id="autonomous-workflow-integration">Workflow chaining across plan-ai-tools and implement-ai-tools:
      - Start execution following plan-ai-tools `<session_workflow>`.
      - Settle PO clarification and story approval interactively with the user (plan-ai-tools `<step id="1">` through plan-ai-tools `<step id="6">`).
      - Once the story is approved, execute plan-ai-tools `<step id="7">` through plan-ai-tools `<step id="15">` autonomously under `<rule id="autonomous-decision-policy">`.
      - In plan-ai-tools `<step id="16">`, bypass the interactive offer prompt and automatically launch implement-ai-tools `<session_workflow>`.
      - Execute implement-ai-tools `<step id="1">` through implement-ai-tools `<step id="9">` autonomously, resolving any specialist or implementer queries under `<rule id="autonomous-decision-policy">`.
      - On blocked tasks under implement-ai-tools `<rule id="retry-and-blocked">`, pause for user interaction via `<user_interaction>` only if autonomous zero-cost/reversible recovery is impossible.
      - Conclude with git cleanup and pull request creation per implement-ai-tools `<rule id="finalization-and-pr">`.
    </rule>
  </boundaries>

  <session_workflow>
    <step id="1" name="interactive-story-refinement">
      Execute plan-ai-tools `<step id="1">` through plan-ai-tools `<step id="6">`: act as PO to settle implementer choice, review repository documentation without inspecting application code, clarify ambiguities and acceptance criteria with the user via `<user_interaction>`, write `docs/plan-ai-tools/{SLUG}/story-{SLUG}.md`, announce the story link, and collect user story approval.
    </step>

    <step id="2" name="autonomous-planning">
      Execute plan-ai-tools `<step id="7">` through plan-ai-tools `<step id="15">` with autonomous decision-making per `<rule id="autonomous-decision-policy">`:
      1. Spawn Architect to inspect repository code and draft `docs/plan-ai-tools/{SLUG}/0-{SLUG}.md`.
      2. When the Architect sends clarification questions in plan-ai-tools `<step id="9">`, answer directly on the user's behalf, selecting zero-cost and easily reversible options. Pause for user input via `<user_interaction>` only if zero-cost or reversible options are impossible.
      3. In plan-ai-tools `<step id="12">`, autonomously validate and approve the plan against the story without user prompt.
      4. In plan-ai-tools `<step id="14">`, create branch `plan/{SLUG}` and commit story and macro plan.
    </step>

    <step id="3" name="autonomous-implementation-and-pr">
      In plan-ai-tools `<step id="16">`, bypass the interactive prompt and immediately transition into implement-ai-tools `<session_workflow>`. Execute implement-ai-tools `<step id="1">` through implement-ai-tools `<step id="9">` autonomously:
      1. Settle specialist task planning, implementer execution, and validation stage-by-stage.
      2. Answer any specialist or implementer questions autonomously per `<rule id="autonomous-decision-policy">`.
      3. If a task becomes blocked under implement-ai-tools `<rule id="retry-and-blocked">`, attempt autonomous recovery first; pause for user input via `<user_interaction>` only if impossible.
      4. Conclude with plan artifact cleanup and pull request creation per implement-ai-tools `<rule id="finalization-and-pr">`.
    </step>
  </session_workflow>

  <dispatch_templates>
  </dispatch_templates>
</skill>
