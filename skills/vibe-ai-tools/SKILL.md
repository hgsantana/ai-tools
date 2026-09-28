---
name: vibe-ai-tools
description: >
  Grill the user into a staged plan, then deliver it unattended, one clean
  implementer per stage, to a pull request. Use for /vibe-ai-tools. Impact:
  after the briefing, creates a branch, edits files, commits, pushes, and
  opens a pull request unattended; edits and removals can be hard to undo.
  Pre-existing history remains intact. Cloud and destructive operations
  require separate approval. Agent: session + implementer (model asked once).
argument-hint: "[the change to deliver]"
---

<skill name="vibe-ai-tools">
  <overview>
    Plan a change with the user per `<planning_protocol>`, then deliver it unattended per `<implementation_protocol>`.
  </overview>

  <session_workflow>
    <step id="1" name="plan">
      Plan the requested change per `<planning_protocol>`, deriving kebab-case {SLUG}. After the briefing, resolve {IMPLEMENTER} per `<rule id="implementer-offer">`, framed by `<implementer_job>`; ask nothing else afterwards.
    </step>

    <step id="2" name="deliver">
      Run stage 1 in the session. For each later stage, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {SLUG} and {STAGE}, then check its commit against the stage's acceptance criteria.
      Decide in-scope questions from code evidence and log each in that stage's report. On a failed check, respawn once with the corrections in the brief; on a second failure, stop as blocked without push or pull request and write evidence to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md`.
    </step>

    <step id="3" name="report">
      In chat (user's language): one-line outcome, the implementer actually used, and the pull request URL or blocked evidence path.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests, and commits. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan stage from a clean context.</job>
      <input>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read plans/{SLUG}.md and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests, set its Status to done, append a short report to the end of plans/{SLUG}.md, and commit with the stage's Conventional Commit message.
        For the last stage, also run its removal, push, and pull request against the base branch.
        Return a one-line outcome with the commit hash, test result, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Push only in the last stage.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="protocols">Planning follows user-wide `<planning_protocol>` and delivery `<implementation_protocol>`; this skill states only its specifics.</rule>
    <rule id="spawn-apis">Spawn `<template role="stage-implementer">` as {IMPLEMENTER} per `<execution_protocol>`; if it cannot be spawned, stop as blocked per `<rule id="spawn-fallback">`.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
