---
name: plan-ai-tools
description: >
  Probe assumptions, edge cases, trade-offs, and scope with the user, then
  formulate and present a staged plan. Use for /plan-ai-tools or as the
  planning protocol for multi-stage delivery. Impact: writes plan files to
  disk; no repository code is modified during planning. Agent: session.
argument-hint: "[the change to plan]"
---

<skill name="plan-ai-tools">
  <overview>
    Probe assumptions and scope per `<planning_protocol>`, formulate short testable stages, and present the plan to the user for explicit approval before delivery.
  </overview>

  <session_workflow>
    <step id="1" name="probe">
      Derive kebab-case {SLUG}. Explore the codebase, probe assumptions, edge cases, trade-offs, and scope per `<rule id="grill-me">`, offering {IMPLEMENTER} per implement-ai-tools `<rule id="implementer-offer">` in the initial batch. Iterate on answers until settled.
    </step>

    <step id="2" name="brief">
      Send one chat message containing the briefing of settled scope and decisions, then confirm approval via `<user_interaction>`.
    </step>

    <step id="3" name="formulate">
      Formulate the plan into short stages per `<rule id="short-stages">` and `<rule id="stage-format">`, saving it to `${TMPDIR:-/tmp}/ai-tools/{SLUG}.md`. Include `<rule id="first-stage">`, `<rule id="docs-stage">`, and `<rule id="last-stage">`.
    </step>

    <step id="4" name="present">
      Present the plan in a chat message linking to `${TMPDIR:-/tmp}/ai-tools/{SLUG}.md` per `<rule id="present-plan">` and obtain explicit approval via `<user_interaction>`. When approved, proceed to delivery.
    </step>
  </session_workflow>

  <planning_protocol>
    Adds to the harness default planning protocol, never replaces, the harness's own planning in every planning flow; the planner applies each rule where it fits. Planning writes nothing to disk until approved.
    <rule id="grill-me">Explore the codebase, then probe assumptions, edge cases, trade-offs, and scope. Ask all open questions at once in a batched `<user_interaction>` call, each with options and recommendation first, ending with a mandatory question offering {IMPLEMENTER} per implement-ai-tools `<rule id="implementer-offer">`. Analyze answers (by session, planner, architect, or reviewers per skill); ask follow-up batched rounds when open points, ambiguities, or new scope questions remain. Repeat until all points are settled. When everything is settled, send one chat message with the briefing, then another to confirm approval via `<user_interaction>`.</rule>
    <rule id="short-stages">Split the plan into short stages, each testable and committable on its own.</rule>
    <rule id="stage-format">Each stage lists files in scope, out-of-scope items, testable acceptance criteria, required tests, verification commands, and its Conventional Commit message.</rule>
    <rule id="stage-commit">Each delivered stage ends with one Conventional Commit.</rule>
    <rule id="first-stage">Stage 1 creates branch `plan/{SLUG}` from the current branch and writes the whole plan to `docs/<skill>/{SLUG}.md` (or `docs/plan/{SLUG}.md` when no skill is named), opened by a status table (Stage, Title, Status, Implementer).</rule>
    <rule id="stage-report">Each implementer appends a short report of its stage to the end of the plan file in `docs/<skill>/` (or `docs/plan/`).</rule>
    <rule id="docs-stage">When features or behaviour change, a stage updates the documentation.</rule>
    <rule id="last-stage">The last stage removes `docs/<skill>/` (or `docs/plan/{SLUG}/`), commits the removal, pushes the branch, and opens a pull request.</rule>
    <rule id="transient-docs">Save all plan files, reports, decisions, and transient docs in `docs/<full-skill-name>/*` (subfolders allowed; `docs/plan/{SLUG}/*` without a skill). Remaining artifacts (tool outputs, binaries like screenshots, caches) stay in harness temp (`${TMPDIR:-/tmp}/ai-tools/`). Any skill writing to `docs/<skill>/*` deletes the entire skill directory upon delivery (`git rm -r docs/<skill>`), keeping the merged repo clean. On blocked execution, `docs/<skill>/*` is preserved on the branch for inspection.</rule>
    <rule id="present-plan">After briefing approval and {IMPLEMENTER} resolution, formulate the plan and present it with its stages and {IMPLEMENTER} in a concise chat message linking to the plan file on disk (in the harness temp dir); obtain explicit user approval via `<user_interaction>` before dispatching delivery.</rule>
  </planning_protocol>

  <dispatch_templates>
  </dispatch_templates>

  <boundaries>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`, and dispatch agents per implement-ai-tools `<harness_agents>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="transient-planning">Planning writes nothing to repository code; save plan files in `docs/<skill>/{SLUG}.md` (or `docs/plan/{SLUG}.md`), and temp artifacts in `${TMPDIR:-/tmp}/ai-tools/`.</rule>
  </boundaries>
</skill>
