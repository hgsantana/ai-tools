---
name: plan-ai-tools
description: >
  Probe assumptions, edge cases, trade-offs, and scope with the user, then
  formulate and present a staged plan. Use for /plan-ai-tools or as the
  planning protocol for multi-stage delivery.
argument-hint: "[the change to plan]"
---

<skill name="plan-ai-tools">
  <overview>
    Probe assumptions and scope per `<planning_protocol>`, where the session embodies all specialist roles (PO, architect, domain specialists) sequentially to clarify business requirements, design macro and micro architecture, detail tasks into separate task files under `plans/plan-ai-tools/{SLUG}/*`, and present the staged plan for explicit approval before recommending implementation via implement-ai-tools.
  </overview>

  <session_workflow>
    <step id="1" name="po-clarification">
      Derive kebab-case {SLUG}. Session acts as PO: read project business documentation (README, AGENTS.md, docs) to understand business intent, rules, and principles. Probe assumptions, trade-offs, and scope per `<rule id="grill-me">`, offering {IMPLEMENTER} per implement-ai-tools `<rule id="implementer-offer">` in the initial batch. Synthesize business scope into `plans/plan-ai-tools/{SLUG}/po-report.md`.
    </step>

    <step id="2" name="architect-exploration">
      Session acts as Architect: scan codebase across macro and micro architecture (services, dependencies, package structures, dependency inversion, interfaces, classes). Settle technical trade-offs with user. Write architectural findings into `plans/plan-ai-tools/{SLUG}/architect-findings.md`.
    </step>

    <step id="3" name="macro-plan">
      Session formulates macro plan in `plans/plan-ai-tools/{SLUG}/0-{SLUG}.md` per `<rule id="short-stages">` and `<rule id="stage-format">`: clear objective, Mermaid target architecture diagram, summary table (#, Status, Name, Primary Validator, Extra Validators), and task list complying with `<rule id="first-stage">`, `<rule id="docs-stage">`, and `<rule id="last-stage">`.
    </step>

    <step id="4" name="task-expansion">
      Session acts as domain specialists (sec-eng, devops-eng, back-eng, front-eng, data-eng, qa-eng, techwriter, ux-designer) to detail each task into `plans/plan-ai-tools/{SLUG}/{N}-{TASK_SLUG}.md`: files in scope, out-of-scope, domain requirements, testable acceptance criteria, verification commands, and Conventional Commit message.
    </step>

    <step id="5" name="present">
      Present the plan in chat linking to `plans/plan-ai-tools/{SLUG}/0-{SLUG}.md` per `<rule id="present-plan">` and obtain explicit approval via `<user_interaction>`. When approved, recommend invoking /implement-ai-tools (where the session acts as orchestrator and validator) or /team-ai-tools.
    </step>
  </session_workflow>

  <planning_protocol>
    <rule id="grill-me">Explore the codebase, then probe assumptions, edge cases, trade-offs, and scope. Ask all open questions at once in a batched `<user_interaction>` call, each with options and recommendation first, ending with a mandatory question offering {IMPLEMENTER} per implement-ai-tools `<rule id="implementer-offer">`. Analyze answers (by session, planner, architect, or reviewers per skill); ask follow-up batched rounds when open points, ambiguities, or new scope questions remain. Repeat until all points are settled. When everything is settled, send one chat message with the briefing, then another to confirm approval via `<user_interaction>`.</rule>
    <rule id="short-stages">Split the plan into short stages, each testable and committable on its own.</rule>
    <rule id="stage-format">Each stage lists files in scope, out-of-scope items, testable acceptance criteria, required tests, verification commands, and its Conventional Commit message.</rule>
    <rule id="stage-commit">Each delivered stage ends with one Conventional Commit.</rule>
    <rule id="first-stage">Stage 1 creates branch `plan/{SLUG}` from the current branch and writes the plan files to `plans/<skill>/{SLUG}/` (or `plans/plan-ai-tools/{SLUG}/` or `docs/<skill>/{SLUG}.md`), opened by a status table (Stage, Title, Status, Implementer).</rule>
    <rule id="stage-report">Each implementer appends a short report of its stage to the end of the plan file or task file in `plans/<skill>/{SLUG}/` (or `docs/<skill>/`).</rule>
    <rule id="docs-stage">When features or behaviour change, a stage updates the documentation, detailing HOW to verify changes and HOW to document.</rule>
    <rule id="last-stage">The last stage removes `plans/<skill>/{SLUG}/` (or `docs/<skill>/`), commits the removal, pushes the branch, and opens a pull request.</rule>
    <rule id="transient-docs">Save all plan files, reports, decisions, and transient docs in `plans/<full-skill-name>/{SLUG}/*` or `docs/<full-skill-name>/*` (subfolders allowed; `docs/plan/{SLUG}/*` without a skill). Remaining artifacts (tool outputs, binaries like screenshots, caches) stay in harness temp (`${TMPDIR:-/tmp}/ai-tools/`). Any skill writing to `plans/<skill>/` or `docs/<skill>/*` deletes the entire skill plan directory upon delivery (`git rm -r plans/<skill>/{SLUG}` or `git rm -r docs/<skill>`), keeping the merged repo clean. On blocked execution, plans and docs are preserved on the branch for inspection.</rule>
    <rule id="present-plan">After briefing approval and {IMPLEMENTER} resolution, formulate the plan and present it with its stages and {IMPLEMENTER} in a concise chat message linking to the plan file on disk (in `plans/<skill>/{SLUG}/0-{SLUG}.md` or the harness temp dir); obtain explicit user approval via `<user_interaction>` before dispatching delivery.</rule>
  </planning_protocol>
</skill>
