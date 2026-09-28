---
name: campaign-ai-tools
description: >
  Run an autonomous campaign of 3-5 goals, each planned by a subagent and
  delivered by an implementer, to a pull request. Use for /campaign-ai-tools.
  Impact: creates branch campaign/{CAMPAIGN}, edits files, commits, pushes,
  and opens a pull request unattended; edits and removals can be hard to undo.
  Pre-existing history remains intact. Cloud and destructive operations require
  separate approval. Agent: session + implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Deliver a 3–5 goal campaign on branch `campaign/{CAMPAIGN}`, planning goals with an inherited subagent per `<planning_protocol>` and delivering stages per `<implementation_protocol>` to a pull request.
  </overview>

  <session_workflow>
    <step id="1" name="initialize">
      Resolve kebab-case {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS} with the user per `<rule id="grill-me">`, structuring an achievable global objective with 3–5 concrete goals. Immediately upon user approval to begin, ask {IMPLEMENTER} per `<rule id="implementer-offer">`, framed by `<implementer_job>`, as the very first action without intermediate tools or checks. Only after {IMPLEMENTER} is resolved, create branch `campaign/{CAMPAIGN}` from current branch, write `plans/campaign/{CAMPAIGN}.md` with global objective, goals with status, priorities, exclusions, {IMPLEMENTER}, and an iteration log, and commit `chore(plans): start campaign {CAMPAIGN}`. Ask nothing else afterwards.
    </step>

    <step id="2" name="iterate">
      For each goal in `plans/campaign/{CAMPAIGN}.md`: dispatch a subagent inheriting the session's model and effort via the native harness API per `<rule id="native-spawn">` to plan that goal into short stages per `<planning_protocol>`, deriving kebab-case {SLUG}. The session orchestrates stage delivery without loading the diff into session context (avoiding context bloat). For each stage of {SLUG}, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {CAMPAIGN}, {N}, {SLUG}, {STAGE}, and {PLAN} (for stage 1, the full plan or the path of a plan file saved outside the repository; else empty); the goal planner subagent (kept active across the goal's stages, falling back to a fresh inherited subagent with the plan) directly inspects the git diff and concise test summary in the repository against `plans/campaign/{N}-{SLUG}.md`, returning only the approval verdict or corrections. On a failed check, run `git reset --soft HEAD~1` before respawning the implementer once with the corrections in the brief; a second failure blocks the campaign. When the goal finishes, remove `plans/campaign/{N}-{SLUG}.md` and commit `chore(plans): complete goal {SLUG}`, update the goal's status to done in `plans/campaign/{CAMPAIGN}.md`, and commit `chore(plans): record campaign {CAMPAIGN} goal {N} ({SLUG})`.
    </step>

    <step id="3" name="finish">
      When all goals are complete: remove `plans/campaign/{CAMPAIGN}.md` and commit `chore(plans): complete campaign {CAMPAIGN}`, push branch `campaign/{CAMPAIGN}` to remote, and open a pull request against the base branch. On block: record the reason and evidence path `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md`, keep the iteration plan, and commit `chore(plans): block campaign {CAMPAIGN}`. In chat (user's language): branch, HEAD, pull request URL or blocked evidence path, and one-line outcome.
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
        <campaign>{CAMPAIGN}</campaign>
        <goal>{N}</goal>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to plans/campaign/{N}-{SLUG}.md as that stage specifies. Read plans/campaign/{N}-{SLUG}.md and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of plans/campaign/{N}-{SLUG}.md, and commit with the stage's Conventional Commit message.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Work locally on campaign/{CAMPAIGN}: no push or remote mutation.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="campaign-lifecycle">Campaign and goal plans stay on `campaign/{CAMPAIGN}`: each goal's stage 1 writes `plans/campaign/{N}-{SLUG}.md` and its last stage removes it; the finished campaign removes `plans/campaign/{CAMPAIGN}.md`, commits, pushes, and opens a pull request.</rule>
    <rule id="spawn-apis">Spawn `<template role="stage-implementer">` as {IMPLEMENTER} per `<execution_protocol>`; if it cannot be spawned, block per `<rule id="spawn-fallback">`.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
  </boundaries>
</skill>
