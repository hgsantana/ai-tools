---
name: campaign-ai-tools
description: >
  Run an autonomous local campaign that repeatedly plans a user-directed
  improvement and delivers it, one clean implementer per stage. Use for
  /campaign-ai-tools. Impact: creates or resumes a campaign branch, edits or
  removes files, runs commands and tests, and makes multiple local commits.
  It never pushes or writes outside the repository. Agent: session +
  implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Iterate plan-and-deliver cycles on local branch `improve/{CAMPAIGN}`, planning per `<planning_protocol>` and delivering per `<implementation_protocol>`, with the local overrides of `<rule id="local-lifecycle">`.
  </overview>

  <session_workflow>
    <step id="1" name="initialize">
      Resolve kebab-case {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS} with the user per `<rule id="grill-me">`. If `plans/improve/{CAMPAIGN}.md` exists on `improve/{CAMPAIGN}`, resume it with its recorded {IMPLEMENTER}. Otherwise create `improve/{CAMPAIGN}` from the current branch, resolve {IMPLEMENTER} per `<rule id="implementer-offer">`, framed by `<implementer_job>`, and write `plans/improve/{CAMPAIGN}.md` with goals, priorities, exclusions, {IMPLEMENTER}, status, and an iteration log.
      Commit `chore(plans): start campaign {CAMPAIGN}` or `chore(plans): resume campaign {CAMPAIGN}`. Ask nothing else afterwards.
    </step>

    <step id="2" name="iterate">
      Plan the next cohesive improvement matching {PRIORITIES} and skipping {EXCLUSIONS}, deriving kebab-case {SLUG}; resolve grill-me questions with your own recommendations. When nothing is worth planning, record NONE in the iteration log.
      Otherwise run stage 1 in the session; for each later stage, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {SLUG} and {STAGE}, then check its commit against the stage's acceptance criteria. On a failed check, respawn once with the corrections in the brief; a second failure blocks the campaign.
      Append the iteration outcome to the iteration log and commit `chore(plans): record campaign {CAMPAIGN} iteration {N}`. Repeat until two consecutive NONE, a halt, budget exhaustion, or a block.
    </step>

    <step id="3" name="finish">
      On two consecutive NONE: remove `plans/improve/{CAMPAIGN}.md` and commit `chore(plans): complete campaign {CAMPAIGN}`.
      On halt or budget exhaustion: set status paused and commit `chore(plans): pause campaign {CAMPAIGN}`.
      On block: record the reason and evidence path `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md`, keep the iteration plan, and commit `chore(plans): block campaign {CAMPAIGN}`.
      In chat (user's language): branch, HEAD, one-line outcome, and paths.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests, and commits locally. It makes no architecture, planning, or user-facing decisions.
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
        Return a one-line outcome with the commit hash, test result, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Work locally: no push, pull request, or remote mutation.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="local-lifecycle">Iteration plans stay on `improve/{CAMPAIGN}`: stage 1 writes `plans/{SLUG}.md` without a new branch, and the last stage removes it and commits without push or pull request.</rule>
    <rule id="spawn-apis">Spawn `<template role="stage-implementer">` as {IMPLEMENTER} per `<execution_protocol>`; if it cannot be spawned, block per `<rule id="spawn-fallback">`.</rule>
    <rule id="strictly-local">No push, fetch, pull request, deployment, or remote mutation; work needing one blocks instead.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
  </boundaries>
</skill>
