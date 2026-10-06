---
name: campaign-ai-tools
description: >
  Run an autonomous campaign of 3-10 goals, each planned by a subagent and
  delivered by an implementer, to a pull request. Use for /campaign-ai-tools.
  Impact: after approval, creates branch campaign/{CAMPAIGN}, edits files,
  commits, pushes, and opens a pull request unattended; edits and removals can
  be hard to undo. Pre-existing history remains intact. Cloud and destructive
  operations require separate approval. Agent: session + implementer (model asked once).
argument-hint: "[campaign name and optional priorities or exclusions]"
---

<skill name="campaign-ai-tools">
  <overview>
    Deliver a 3–10 goal campaign on branch `campaign/{CAMPAIGN}`, planning goals with an inherited subagent per `<planning_protocol>` and delivering stages per `<implementation_protocol>` to a pull request.
  </overview>

  <session_workflow>
    <step id="1" name="initialize">
      Resolve kebab-case {CAMPAIGN}, {PRIORITIES}, and {EXCLUSIONS} with the user per `<rule id="grill-me">`, structuring an achievable global objective with 3–10 concrete goals and framing {IMPLEMENTER} per `<implementer_job>` in the initial batch; iterate on responses until settled. Send the briefing in a chat message, then confirm approval via `<user_interaction>`. Present the complete campaign record in a chat message and obtain explicit user approval per `<rule id="present-plan">`. Upon approval, spawn `<template role="stage-implementer">` as {IMPLEMENTER} with {STAGE} = bootstrap, {N} and {SLUG} empty, and {PLAN} = the campaign record: global objective, base branch (the current branch), goals with status, priorities, exclusions, {IMPLEMENTER}, and an iteration log.
    </step>

    <step id="2" name="iterate">
      For each goal in `docs/campaign-ai-tools/{CAMPAIGN}.md`: dispatch a subagent inheriting the session's model and effort via the native harness API per `<rule id="native-spawn">` to plan that goal into short stages per `<planning_protocol>`, deriving kebab-case {SLUG}, with these campaign adaptations: stage 1 writes `docs/campaign-ai-tools/{N}-{SLUG}.md` on `campaign/{CAMPAIGN}` without creating a branch; the last stage runs `git rm` on that goal plan, sets goal {N} done and logs the iteration in `docs/campaign-ai-tools/{CAMPAIGN}.md`, and commits `chore(plans): complete goal {SLUG}`, without pushing or opening a pull request. The planner returns the plan as content, or as a path under `${TMPDIR:-/tmp}/ai-tools/` when it can write there. The session orchestrates stage delivery without loading the diff into session context (avoiding context bloat). For each stage of {SLUG}, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {CAMPAIGN}, {N}, {SLUG}, {STAGE}, and {PLAN} (for stage 1, the plan content or path; else empty); the goal planner subagent (kept active across the goal's stages, falling back to a fresh inherited subagent with the plan) directly inspects the git diff and concise test summary in the repository against `docs/campaign-ai-tools/{N}-{SLUG}.md`, returning only the approval verdict or corrections. On a failed check, run `git reset --soft HEAD~1` before respawning the implementer once with the corrections in the brief; a second failure blocks the campaign.
    </step>

    <step id="3" name="finish">
      When all goals are complete, spawn `<template role="stage-implementer">` as {IMPLEMENTER} with {STAGE} = finish and {N}, {SLUG}, and {PLAN} empty. On block, write the reason and evidence to `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md` and preserve `docs/campaign-ai-tools/`, then spawn it with {STAGE} = block, unless the implementer cannot be spawned. In chat (user's language): branch, HEAD, pull request URL or blocked evidence path, and one-line outcome.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests reporting only a concise summary of coverage and execution, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan. It also runs the campaign's bootstrap, finish, and block stages. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
  </implementer_job>

  <dispatch_templates>
    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one campaign stage from a clean context.</job>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <goal>{N}</goal>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Read the repository rules (README.md, AGENTS.md if present), then act by {STAGE}.
        Bootstrap: create branch campaign/{CAMPAIGN} from the current branch, write {PLAN} to docs/campaign-ai-tools/{CAMPAIGN}.md, and commit `chore(plans): start campaign {CAMPAIGN}`.
        Stage number: for stage 1, write {PLAN}, reading it first when it is a file path, to docs/campaign-ai-tools/{N}-{SLUG}.md as that stage specifies. Read docs/campaign-ai-tools/{N}-{SLUG}.md. Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of docs/campaign-ai-tools/{N}-{SLUG}.md, and commit with the stage's Conventional Commit message.
        Finish: read the base branch from docs/campaign-ai-tools/{CAMPAIGN}.md, remove `docs/campaign-ai-tools/` (with `git rm -r docs/campaign-ai-tools`), commit `chore(plans): complete campaign {CAMPAIGN}`, push campaign/{CAMPAIGN}, and open a pull request against the base branch.
        Block: record the reason from `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md` and that evidence path in docs/campaign-ai-tools/{CAMPAIGN}.md, preserve `docs/campaign-ai-tools/`, and commit `chore(plans): block campaign {CAMPAIGN}`.
        Return a one-line outcome with the commit hash, test summary, changed paths, and, for finish, the pull request URL.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Work on campaign/{CAMPAIGN}; push and open the pull request only in finish, with no other remote mutation.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="campaign-lifecycle">Implementers make every other repository write; the session's only one is `git reset --soft HEAD~1` on a failed check, and goal planners stay read-only, both writing files only under `${TMPDIR:-/tmp}/ai-tools/`. Bootstrap creates `campaign/{CAMPAIGN}` and `docs/campaign-ai-tools/{CAMPAIGN}.md`; each goal's stage 1 writes `docs/campaign-ai-tools/{N}-{SLUG}.md` on that branch and its last stage removes it and marks the goal done, without pushing; finish removes `docs/campaign-ai-tools/`, commits, pushes, and opens a pull request; block records the reason, preserves `docs/campaign-ai-tools/`, and commits without pushing.</rule>
    <rule id="spawn-apis">Spawn `<template role="stage-implementer">` as {IMPLEMENTER} per `<execution_protocol>`; if it cannot be spawned, block per `<rule id="spawn-fallback">`.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
  </boundaries>
</skill>
