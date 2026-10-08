---
name: ui-ai-tools
description: >
  Evaluate app routes by screenshots and code into an illustrated report, then
  plan and deliver a UI modernization to a pull request. Use for /ui-ai-tools.
  Impact: evaluators consume model quota; may start and stop a local dev
  server; writes screenshots and reports to OS temp; after approval,
  creates a branch, edits files, commits, pushes, and opens a pull request
  unattended. Cloud and destructive operations require separate approval.
  Agent: session + implementer (model asked once).
argument-hint: "[routes] [base URL] [auth state path or env var names]"
---

<skill name="ui-ai-tools">
  <overview>
    Evaluate routes by rendered image and source code, consolidate an illustrated report, plan the modernization per plan-ai-tools `<planning_protocol>`, and deliver it per implement-ai-tools `<implementation_protocol>`.
  </overview>

  <session_workflow>
    <step id="1" name="setup">
      Derive kebab-case {SLUG} and {WORKDIR} = `${TMPDIR:-/tmp}/ai-tools/ui/{SLUG}`. Parse the routes, base URL, and auth source (storage-state path or env var names, never values).
    </step>

    <step id="2" name="discover">
      Only when no route is named: spawn `<template role="route-mapper">`, present `{WORKDIR}/routes.md`, and confirm the route list and example params with the user via `<user_interaction>` before any evaluator spawns.
    </step>

    <step id="3" name="serve">
      Only without a base URL: spawn `<template role="dev-server">` with {ACTION} = start; record the returned {BASE_URL} and stop handle.
    </step>

    <step id="4" name="evaluate">
      Spawn one `<template role="route-evaluator">` per route, at most 4 in parallel, in waves, substituting {ROUTE}, {BASE_URL}, {AUTH} (the auth source, else empty), and {ROUTE_DIR} = `{WORKDIR}/routes/{ROUTE_SLUG}` with kebab-case {ROUTE_SLUG}.
    </step>

    <step id="5" name="consolidate">
      After every evaluator returns, spawn `<template role="dev-server">` with {ACTION} = stop when `<step id="3">` started it. Read every route report and view its images, then write `{WORKDIR}/report.md`: summary, cross-route patterns, prioritized opportunities including creative ones, per-route sections embedding image paths and linking route reports, and not-captured routes. Show only its path in chat.
    </step>

    <step id="6" name="plan">
      Plan the modernization from the report per plan-ai-tools `<planning_protocol>`; grill-me covers design direction (brand constraints, design system or CSS stack, scope, priorities, appetite for creative change), framing {IMPLEMENTER} per `<implementer_job>` in the initial batch, and iterates until settled. Save the plan outside the repository at `{WORKDIR}/plan.md`. Send the briefing in a chat message, then confirm approval via `<user_interaction>`; present the plan in a chat message linking to `{WORKDIR}/plan.md` per plan-ai-tools `<rule id="present-plan">` and obtain explicit approval before delivery. Every stage that changes UI lists, in its verification, recapture of the affected routes at the three viewports into `{WORKDIR}/after/stage-{STAGE}/`.
    </step>

    <step id="7" name="deliver">
      For each stage, spawn `<template role="stage-implementer">` as {IMPLEMENTER}, substituting {SLUG}, {STAGE}, {WORKDIR}, and {PLAN} (`{WORKDIR}/plan.md` for stage 1; else empty); validate its delivery by reviewing the git diff, the concise test summary, and before/after images against the plan and stage acceptance criteria.
      Decide in-scope questions from code evidence and log each in that stage's report. On a failed check, run `git reset --soft HEAD~1` before respawning once with the corrections in the brief; on a second failure, stop as blocked without push or pull request, write evidence to `{WORKDIR}/blocked.md`, and preserve `docs/ui-ai-tools/`.
    </step>

    <step id="8" name="report">
      In chat (user's language): one-line outcome, the implementer actually used, the report path, and the pull request URL or blocked evidence path.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests reporting only a concise summary of coverage and execution, starts the app when needed and recaptures affected routes at the three viewports with the same capture method, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file frontend and UI code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits, shell commands, and browser screenshots.
  </implementer_job>

  <dispatch_templates>
    <template role="route-mapper" executor="default-worker">
      <job>Default worker: map the application's routes.</job>
      <input>
        <workdir>{WORKDIR}</workdir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Map routes from the router configuration and file conventions (Next.js pages or app, React Router, Angular, Vue Router, SvelteKit, Remix, and others). Mark dynamic routes with example params and protected routes.
        Write {WORKDIR}/routes.md: per route the path, source file, dynamic params, and protection.
        Return a one-line outcome with the path and route count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; write only under {WORKDIR}.</constraint>
      </constraints>
    </template>

    <template role="dev-server" executor="default-worker">
      <job>Default worker: start or stop the local dev server.</job>
      <input>
        <action>{ACTION}</action>
        <workdir>{WORKDIR}</workdir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        When {ACTION} is start: detect the dev command (package.json scripts, framework config), start it in the background logging to {WORKDIR}/dev-server.log, wait until it responds, and return its URL and stop handle (PID). When {ACTION} is stop: stop that process.
        Return a one-line outcome.
      </instructions>
      <constraints>
        <constraint>Local only: never deploy or touch remote resources.</constraint>
        <constraint>Leave tracked files untouched; write only under {WORKDIR}.</constraint>
      </constraints>
    </template>

    <template role="route-evaluator" executor="inherited">
      <job>Senior UI designer and frontend engineer: evaluate one route by image and code.</job>
      <input>
        <route>{ROUTE}</route>
        <base_url>{BASE_URL}</base_url>
        <auth>{AUTH}</auth>
        <route_dir>{ROUTE_DIR}</route_dir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Capture {ROUTE} at {BASE_URL} full-page at desktop 1440x900, tablet 768x1024, and mobile 390x844 to {ROUTE_DIR}/desktop.png, tablet.png, and mobile.png with the harness browser or browser MCP tool, else `npx playwright screenshot --full-page --viewport-size=W,H`, authenticating with {AUTH} when given (storage-state path, or env var names read at runtime). View each image; locate and read the route's source and styles.
        Evaluate visual hierarchy, typography, spacing and grid, color and contrast, component consistency, responsiveness, accessibility, states (empty, error, loading), and UI code debt (legacy CSS, inline styles, duplicated components, obsolete libraries), each finding with severity (high, medium, low) and evidence (image path or file:line). This checklist is a floor: then propose bold, creative modernization ideas beyond it (layout, interaction, motion, visual language). When capture fails, evaluate by code only and mark the route "not captured" with the reason.
        Write {ROUTE_DIR}/report.md.
        Return a one-line outcome with the path and finding count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; write only under {ROUTE_DIR}.</constraint>
        <constraint>Never write credential or cookie values anywhere.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan stage from a clean context.</job>
      <input>
        <slug>{SLUG}</slug>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
        <workdir>{WORKDIR}</workdir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to docs/ui-ai-tools/{SLUG}.md as that stage specifies. Read docs/ui-ai-tools/{SLUG}.md and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of docs/ui-ai-tools/{SLUG}.md, and commit with the stage's Conventional Commit message.
        When the stage changes UI, start the app if needed and recapture the affected routes full-page at 1440x900, 768x1024, and 390x844 into {WORKDIR}/after/stage-{STAGE}/ with the same capture method as the evaluation (harness browser or browser MCP tool, else `npx playwright screenshot --full-page`), and list those paths in the outcome.
        For the last stage, remove `docs/ui-ai-tools/` (with `git rm -r docs/ui-ai-tools`), commit the removal with the stage's commit message, and run push and pull request against the base branch.
        Return a one-line outcome with the commit hash, test summary, changed paths, and recapture paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Push only in the last stage.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="protocols">Planning follows plan-ai-tools `<planning_protocol>` and delivery implement-ai-tools `<implementation_protocol>`; this skill states only its specifics: route evaluation, the illustrated report, and before/after recapture.</rule>
    <rule id="spawn-apis">Spawn templates per implement-ai-tools `<harness_agents>`; if `<template role="stage-implementer">` cannot be spawned as {IMPLEMENTER}, stop as blocked per implement-ai-tools `<rule id="spawn-fallback">`.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="evaluators-read-only">Steps 1–5 write only under {WORKDIR}; the repository stays untouched until delivery.</rule>
    <rule id="secrets">Auth values never reach disk, chat, or briefs; pass only paths or env var names.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
