---
name: vibe-ai-tools
description: >
  Plan a change under dev/, then the session delivers it with implementers
  per stage, deciding in-scope implementation questions. Use for
  /vibe-ai-tools. Impact: after the plan is on disk, edits on a dedicated
  branch, commits, pushes, and opens a pull request unattended; edits and
  removals can be hard to undo. Pre-existing history remains intact. Cloud
  and destructive operations require separate approval. Agent: session +
  implementer (model asked once).
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change under dev/{SLUG}/ interactively with the user, then the session delivers it.
    The session plans, asks the implementer model, judges each stage, commits, and opens the pull request; implementers write stage code; tests go to a default worker when that spawn works.
  </overview>

  <session_workflow>
    <step id="1" name="interactive_planning">
      Run plan-ai-tools `<step id="1">` to record {BASE_BRANCH}.
      Refine scope, architecture, and trade-offs interactively with the user in chat, and derive a kebab-case {SLUG}.
      Run plan-ai-tools `<step id="3">` to write the plan under dev/{SLUG}/ per plan-ai-tools `<plan_file_format>`.
      Skip the standalone `/dev-ai-tools` offer once the plan is on disk.
    </step>

    <step id="2" name="implementer_model">
      With the plan on disk and before execution, ask the user exactly one question through USER-AGENTS `<user_interaction>`: which model implements this plan's stages, with 1-3 options chosen per `<implementer_job>`.
      Record the answer as {IMPLEMENTER_MODEL} in dev/{SLUG}/vibe-decisions.md; ask nothing else before delivery.
    </step>

    <step id="3" name="unattended_execution">
      Read the unit of work and the repository rules (README.md, AGENTS.md if present).
      Check out `plan/{SLUG}` from {BASE_BRANCH} and commit the unit first: `chore(dev): plan {SLUG}`.
      For each unfinished stage in dependency order, following dev-ai-tools `<status_protocol>`:
        1. Set W and record Executor as implementer plus {IMPLEMENTER_MODEL} in the base plan Status table.
        2. Spawn `<template role="stage-implementer">` from `<dispatch_templates>` as executor="implementer" with {IMPLEMENTER_MODEL}, substituting {STAGE_FILE} and {SLUG}; if that spawn is rejected only for the recorded model, retry once with the harness default and use that model for remaining stages; if the spawn fails, treat the unit as `<signal code="BLOCKED">` without implementing the stage in the session.
        3. Review the working-tree diff against the stage objective, declared files, and acceptance criteria. Decide in-scope questions from code evidence; append each decision to dev/{SLUG}/vibe-decisions.md.
        4. On passing evidence and met criteria: stage path by path, commit with the stage's Conventional Commit message, and set F.
        5. Otherwise: append concrete correction tasks to the stage log, set R1..R3, and retry up to three times, then set E.
      On E: stop remaining stages, retain the work unit, and go to `<step id="4">` as blocked. Do not start a dependent stage.
      Successful completion is every required stage F. Only then: copy the unit to dev/tmp/finished/{SLUG}, remove it with `git rm -r dev/{SLUG}`, commit `chore(dev): archive {SLUG}`, push `plan/{SLUG}`, open a pull request targeting {BASE_BRANCH} with `gh pr create` or write dev/tmp/{SLUG}-review.patch when no host is available, write dev/tmp/{SLUG}-report.md, and treat the outcome as `<signal code="DELIVERED">`.
      If any required stage is E, an implementer spawn is missing, or a reserved approval is pending: retain the unit, do not archive, push, or open a pull request, write evidence to dev/tmp/{SLUG}-blocked.md, and treat the outcome as `<signal code="BLOCKED">`. Partial delivery is not authorized.
    </step>

    <step id="4" name="report">
      In chat (user's language), provide the report or evidence path, a one-line outcome, the implementer model actually used, and the PR URL or review patch path.
      Interrupt the user only for `<signal code="BLOCKED">` or an approval reserved by USER-AGENTS `<security_guardrails>`.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage file at a time and delivers it without supervision: it reads the stage and the code it touches, edits production code and tests across several files within the declared scope, matches the repository's style and conventions, writes and runs behaviour tests, and appends a factual implementation log. It makes no architecture, planning, or user-facing decisions and never commits.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
    Offer 1-3 models that the harness's native subagent API can select, by their exact harness names: the strongest coding fit first and marked recommended, then cheaper or faster options that still meet the required capability.
    When that API cannot select a model per spawn, skip the question, record `harness default` as the model, and state that in the report. When a spawn with the chosen model fails, retry once with the harness default and record that.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: write and edit code and behaviour tests for one plan stage.</job>
      <input>
        <assigned_file>{STAGE_FILE}</assigned_file>
        <slug>{SLUG}</slug>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Nested spawn payloads are assembled here per USER-AGENTS `<rule id="payload-assembly">`. Include dev-ai-tools `<template role="stage-verifier">` in the brief.
        Read {STAGE_FILE} of dev/{SLUG}/ and the repository rules (README.md, AGENTS.md if present). Implement only that stage.
        Match surrounding style, keep product and test edits within the declared files, and write behaviour tests for delivered changes.
        Spawn dev-ai-tools `<template role="stage-verifier">` as executor="default-worker" with the stage's commands and a kebab-case topic. If that spawn fails, run the commands yourself and write the same log.
        Append factual notes to the Implementation log of {STAGE_FILE}, set that stage's Status cell to V in the base plan Status table, and return a one-line outcome with the changed paths, test exit code, and log path.
      </instructions>
      <constraints>
        <constraint>Do not make architectural changes outside stage scope.</constraint>
        <constraint>Edit only the declared stage files, the Implementation log of {STAGE_FILE}, and that stage's Status cell in `dev/{SLUG}/0-{SLUG}.md`.</constraint>
        <constraint>Do not commit or push; leave changes in the working tree for session review.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="DELIVERED">DELIVERED {REPORT_PATH} {PR_OR_PATCH} {IMPLEMENTER_MODEL}</signal>
    <signal code="BLOCKED">BLOCKED {REASON} {EVIDENCE_PATH}</signal>
  </return_protocol>

  <boundaries>
    <rule id="session-owns-delivery">The session owns user alignment, planning, the implementer question, in-scope decisions, judgment, commits, archival, the pull request, and reporting from disk paths.</rule>
    <rule id="one-model-question">Ask the implementer model question once per run, after the plan is on disk; reuse the answer for every stage and rework.</rule>
    <rule id="spawn-apis">Per USER-AGENTS `<execution_protocol>`: `<template role="stage-implementer">` runs as `executor="implementer"` with the recorded {IMPLEMENTER_MODEL}; dev-ai-tools `<template role="stage-verifier">` runs as `executor="default-worker"`.</rule>
    <rule id="no-implementer-fallback">If `<template role="stage-implementer">` cannot be spawned, do not implement that stage in the session: end as `<signal code="BLOCKED">` naming the missing spawn.</rule>
    <rule id="worker-fallback">If a default-worker spawn fails, the spawning context runs those commands itself per USER-AGENTS `<rule id="spawn-fallback">`.</rule>
    <rule id="completion-is-f">Archive, push, and pull-request creation run only when every required stage is F. An E stage is BLOCKED and retains the work unit.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="log-decisions">Log in-scope decisions to dev/{SLUG}/vibe-decisions.md for PR reviewer audit.</rule>
    <rule id="reserved-approvals">Never bypass approvals reserved by USER-AGENTS `<security_guardrails>` for cloud mutations or destructive operations.</rule>
  </boundaries>
</skill>
