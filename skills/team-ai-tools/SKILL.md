---
name: team-ai-tools
description: >
  Act as product owner leading 2-5 senior reviewers (security, performance,
  UX, best practices, design) to refine a request into decisions and a plan
  or campaign, then deliver it unattended to a pull request. Use for
  /team-ai-tools. Impact: spawns reviewer subagents that consume model quota;
  after approval, creates a branch, edits files, commits, pushes, and opens a
  pull request unattended. Cloud and destructive operations require separate
  approval. Agent: session + implementer (model asked once).
argument-hint: "[the request to refine and deliver]"
---

<skill name="team-ai-tools">
  <overview>
    The session, a strong model, is product owner (PO) and orchestrator: it audits the request against repository documentation and code, refines it with 2–5 senior reviewers, settles open points with the user in batched rounds, has a plan or campaign approved, then delivers it. Working files live in {WORKDIR} = `${TMPDIR:-/tmp}/ai-tools/team/{SLUG}/`; nothing is written to the repository before approval.
  </overview>

  <session_workflow>
    <step id="1" name="po-analysis">
      Derive kebab-case {SLUG}. Read the repository documentation (README, AGENTS.md, docs) and compare it with the code the request touches. Asking the user nothing, write `{WORKDIR}/po-report.md`: request restatement, documentation-versus-code gaps, scope, ambiguities, and refinement questions each with options and a recommendation. Select 2–5 reviewer templates by relevance: `<template role="security-reviewer">`, `<template role="performance-reviewer">`, `<template role="ux-reviewer">`, `<template role="best-practices-reviewer">`, and `<template role="design-reviewer">` only when structure changes; record one line on why each skipped role was skipped.
    </step>

    <step id="2" name="team-review">
      Spawn the selected reviewers in parallel, substituting {REPORT} = `{WORKDIR}/po-report.md` and {FINDINGS} = `{WORKDIR}/{role}.md`. Read every findings file. Clarify each point with its author and route points that touch another reviewer's findings to that reviewer, so they converge on one recommended option. After 3 rounds on a point without agreement, turn it into a user question carrying the divergent options, the PO recommendation, and the recorded dissent. Keep `{WORKDIR}/decisions.md` current: point, owner role, options, recommendation, status (agreed, open, user).
    </step>

    <step id="3" name="user-round">
      Ask every open question in one batched `<user_interaction>` call, each with its own options and its recommendation first; this batch replaces one-at-a-time questioning in `<rule id="grill-me">`. The first batch ends with the implementer question per `<rule id="implementer-offer">`, framed by `<implementer_job>`; never repeat it. Record answers in `decisions.md`. When an answer departs from its recommendation and needs clarification or replanning, take it to the affected reviewers per `<step id="2">`, then ask a new batch with only the resulting questions; repeat until every point is closed.
    </step>

    <step id="4" name="approve">
      Write `{WORKDIR}/plan.md` per `<planning_protocol>`, turning agreed decisions into acceptance criteria: a plan for one cohesive delivery within about 8 short stages, or a campaign for 3–10 independently deliverable goals. Ask approval via `<user_interaction>`, stating the choice and its reason, with options approve, switch between plan and campaign, or revise; revisions return to `<step id="2">` or `<step id="3">`. Approval ends the team: release the reviewers and ask nothing else afterwards.
    </step>

    <step id="5" name="deliver">
      Plan: run vibe-ai-tools `<step id="2">` and `<step id="3">` with {IMPLEMENTER}, {SLUG}, and `{WORKDIR}/plan.md` as the stage 1 plan, spawning `<template role="stage-implementer">` with {MODE} = plan and {PLAN_FILE} = `plans/{SLUG}.md`.
      Campaign: run campaign-ai-tools `<step id="1">` from branch creation onward with {CAMPAIGN} = {SLUG} and the approved goals, then its `<step id="2">` and `<step id="3">`, planning each goal with `<template role="goal-planner">` and spawning `<template role="stage-implementer">` with {MODE} = campaign and {PLAN_FILE} = `plans/campaign/{N}-{GOAL_SLUG}.md`.
    </step>
  </session_workflow>

  <implementer_job>
    The implementer takes one stage and delivers it without supervision: it reads the plan and the code it touches, edits code and tests across several files within the stage's scope, matches repository style, runs tests reporting only a concise summary of coverage and execution, appends its stage report, sets status to done, and commits locally without validating delivery against the macro plan. It makes no architecture, planning, or user-facing decisions.
    Required capability: reliable multi-file code editing in an unfamiliar codebase, test writing and debugging, precise adherence to written acceptance criteria, and tool use for file edits and shell commands.
  </implementer_job>

  <dispatch_templates>
    <template role="security-reviewer" executor="inherited">
      <job>Senior security engineer: review the PO report and code for security risks.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess authentication and authorization, untrusted input and injection, secrets handling, data exposure, dependencies and supply chain, least privilege, and destructive operations.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="performance-reviewer" executor="inherited">
      <job>Senior performance engineer: review the PO report and code for performance risks.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess algorithmic complexity, I/O and network round trips, memory, concurrency, caching, latency and startup, scalability, and measurable budgets.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="ux-reviewer" executor="inherited">
      <job>Senior UX engineer: review the PO report and code for the experience of whoever uses the result.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess user flows and accessibility when there is an interface, otherwise CLI, API, and developer ergonomics: defaults, error messages, discoverability, documentation, and compatibility felt by users.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="best-practices-reviewer" executor="inherited">
      <job>Senior engineer for best practices: review the PO report and code for quality and conventions.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess repository conventions and rules, style, tests and coverage, maintainability, readability, error handling, observability, and documentation updates.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="design-reviewer" executor="inherited">
      <job>Senior software architect: review the PO report and code for structural design.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess module boundaries, contracts and public APIs, data modeling, dependencies, extensibility, and migration paths.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="goal-planner" executor="inherited">
      <job>Planner: plan one campaign goal from settled decisions and validate its stages.</job>
      <input>
        <campaign>{CAMPAIGN}</campaign>
        <goal>{N}</goal>
        <report>{REPORT}</report>
        <decisions>{DECISIONS}</decisions>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read plans/campaign/{CAMPAIGN}.md, {REPORT}, {DECISIONS}, the repository rules (README.md, AGENTS.md if present), and the code goal {N} touches. Plan goal {N} into short stages per `<planning_protocol>`, deriving kebab-case goal slug, with the decisions as acceptance criteria, and save the plan outside the repository.
        Stay active across the goal's stages: inspect each stage's git diff and test summary against plans/campaign/{N}-slug.md and return only the approval verdict or corrections.
        Return a one-line outcome with the goal slug and plan path.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; decide from the decisions and code evidence, logging each choice in the plan.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan stage from a clean context.</job>
      <input>
        <mode>{MODE}</mode>
        <plan_file>{PLAN_FILE}</plan_file>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to {PLAN_FILE} as that stage specifies. Read {PLAN_FILE} and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of {PLAN_FILE}, and commit with the stage's Conventional Commit message.
        When {MODE} is plan and this is the last stage, also run its removal, push, and pull request against the base branch.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Push only in the last stage of mode plan; mode campaign works locally with no push or remote mutation.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="protocols">Planning follows user-wide `<planning_protocol>` and delivery `<implementation_protocol>`; this skill states only its specifics: batched questions, the reviewer team, and delivery reuse from vibe-ai-tools and campaign-ai-tools.</rule>
    <rule id="reviewer-continuity">Keep reviewers active until approval; where the harness cannot continue a subagent, respawn its template with its findings file as context.</rule>
    <rule id="spawn-apis">Spawn templates per `<execution_protocol>`; if `<template role="stage-implementer">` cannot be spawned as {IMPLEMENTER}, stop as blocked per `<rule id="spawn-fallback">`.</rule>
    <rule id="chat-scope">Chat carries only questions, the approval, spawn announcements, a one-line outcome, and paths under {WORKDIR}; reports stay on disk.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
