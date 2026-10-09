---
name: vibe-ai-tools
description: >
  Grill the user into a staged plan, then deliver it unattended, one clean
  implementer per stage, to a pull request. Use for /vibe-ai-tools.
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change with the user per plan-ai-tools `<planning_protocol>`, then deliver it unattended per implement-ai-tools `<implementation_protocol>`.
  </overview>

  <session_workflow>
    <step id="1" name="plan">
      Plan the requested change per plan-ai-tools `<planning_protocol>`, deriving kebab-case {SLUG}: probe assumptions and scope per plan-ai-tools `<rule id="grill-me">`, framing {IMPLEMENTER} per `<implementer_job>` in the initial batch, and iterate on responses until settled; send the briefing in a chat message, then confirm approval via `<user_interaction>`; present the plan in a chat message (linking to it when on disk) and obtain explicit approval per plan-ai-tools `<rule id="present-plan">` before delivery.
    </step>

    <step id="2" name="deliver">
      For each stage, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {SLUG}, {STAGE}, and {PLAN} (for stage 1, the full plan or the path of a plan file saved outside the repository; else empty); the session validates the implementer's delivery by reviewing the git diff and concise test summary against the plan and stage acceptance criteria.
      Decide in-scope questions from code evidence and log each in that stage's report. On a failed check, run `git reset --soft HEAD~1` before respawning once with the corrections in the brief; on a second failure, stop as blocked without push or pull request, write evidence to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md`, and preserve `docs/vibe-ai-tools/`.
    </step>

    <step id="3" name="report">
      In chat (user's language): one-line outcome, the implementer actually used, and the pull request URL or blocked evidence path.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests reporting only a concise summary of coverage and execution, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan stage from a clean context.</job>
      <input>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to docs/vibe-ai-tools/{SLUG}.md as that stage specifies. Read docs/vibe-ai-tools/{SLUG}.md and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of docs/vibe-ai-tools/{SLUG}.md, and commit with the stage's Conventional Commit message.
        For the last stage, remove `docs/vibe-ai-tools/` (with `git rm -r docs/vibe-ai-tools`), commit the removal with the stage's commit message, and run push and pull request against the base branch.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Push only in the last stage.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="protocols">Planning follows plan-ai-tools `<planning_protocol>` and delivery implement-ai-tools `<implementation_protocol>`; this skill states only its specifics.</rule>
    <rule id="spawn-apis">Spawn `<template role="stage-implementer">` as {IMPLEMENTER} per implement-ai-tools `<harness_agents>`; if it cannot be spawned, stop as blocked per implement-ai-tools `<rule id="spawn-fallback">`.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
