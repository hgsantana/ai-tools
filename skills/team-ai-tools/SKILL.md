---
name: team-ai-tools
description: >
  Act as product owner leading 2-8 senior reviewers (security, performance,
  UX, best practices, design, DevOps, docs, tests) to refine a request into a
  plan or campaign, then deliver it unattended to a pull request. Use for
  /team-ai-tools. Impact: reviewer subagents consume model quota;
  after approval, creates a branch, edits files, commits, pushes, and opens a
  pull request unattended. Cloud and destructive operations require separate
  approval. Agent: session + implementer (model asked once).
argument-hint: "[the request to refine and deliver]"
---

<skill name="team-ai-tools">
  <overview>
    The session, a strong model, is product owner (PO) and orchestrator: it audits the request against repository documentation and code, refines it with 2–8 senior reviewers, settles open points with the user in batched rounds, has a plan or campaign approved, then delivers it. Working files live in {WORKDIR} = `${TMPDIR:-/tmp}/ai-tools/team/{SLUG}/`; nothing is written to the repository before approval.
  </overview>

  <session_workflow>
    <step id="1" name="po-analysis">
      Derive kebab-case {SLUG}. Read the repository documentation (README, AGENTS.md, docs) and compare it with the code the request touches. Asking the user nothing, write `{WORKDIR}/po-report.md`: request restatement, documentation-versus-code gaps, scope, ambiguities, and refinement questions each with options and a recommendation. Select 2–8 reviewer templates by relevance: `<template role="security-reviewer">`, `<template role="performance-reviewer">`, `<template role="ux-reviewer">`, `<template role="best-practices-reviewer">`, `<template role="design-reviewer">` only when structure changes, and `<template role="devops-reviewer">` only when the request touches CI, static analysis, build, deploy, infrastructure, or cost, `<template role="docs-reviewer">` only when it changes behaviour or documentation, and `<template role="test-reviewer">` only when it changes code; record one line on why each skipped role was skipped.
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
      Plan: run vibe-ai-tools `<step id="2">` and `<step id="3">` with {IMPLEMENTER}, {SLUG}, and `{WORKDIR}/plan.md` as the stage 1 plan, spawning `<template role="stage-implementer">` with {MODE} = plan and {PLAN_FILE} = `plans/{SLUG}.md`; run the docs audit before the last stage.
      Campaign: run campaign-ai-tools `<step id="1">` from branch creation onward with {CAMPAIGN} = {SLUG} and the approved goals, then its `<step id="2">` and `<step id="3">`, planning each goal with `<template role="goal-planner">` and spawning `<template role="stage-implementer">` with {MODE} = campaign and {PLAN_FILE} = `plans/campaign/{N}-{GOAL_SLUG}.md`; run the docs audit once, before its `<step id="3">`, with {PLAN_FILE} = `plans/campaign/{CAMPAIGN}.md`.
      Stage validation: for each stage that changes code or tests, skipping plan-only, documentation-only (including docs-audit), and closing stages, spawn `<template role="test-validator">` with {PLAN_FILE}, {STAGE}, and {VERDICTS} = `{WORKDIR}/test-verdicts.md` before the planner's check, keeping one per plan or goal active across stages, else respawning it with {VERDICTS}. On `<signal code="TESTS_FIX">`, skip the planner's check, run `git reset --soft HEAD~1`, and respawn the implementer once with {NOTES} = {VERDICTS}; the retry passes both checks or blocks. On `<signal code="TESTS_OK">`, the planner's check proceeds.
      Docs audit: spawn `<template role="docs-auditor">` with {BASE_BRANCH} and {AUDIT} = `{WORKDIR}/docs-audit.md`. On `<signal code="DOCS_FIX">`, spawn `<template role="stage-implementer">` with {STAGE} = docs-audit and {NOTES} = {AUDIT}, then validate its diff against {AUDIT} once; write corrections it left unresolved to `{WORKDIR}/docs-followups.md` and pass that path as {NOTES} to the plan's last stage, or add it to the campaign pull request body, without blocking delivery.
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
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope. Assess repository conventions and rules, style, maintainability, readability, and error handling and logging; pipelines, analysis tooling, and operational monitoring belong to the DevOps role, documentation to the docs role, and tests to the tests role.
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

    <template role="devops-reviewer" executor="inherited">
      <job>Senior DevOps engineer: review the PO report and code for delivery efficiency, cost, and operability.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), and the code in scope, including pipelines, build files, containers, and infrastructure as code. Assess CI speed, caching, and flakiness; static analysis and lint gates; build and packaging; deploy resources and rollback; cloud cost and sizing; operational monitoring; and pipeline maintainability.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; run no cloud CLI. Where live cost or resource data is needed, recommend a query through az-ai-tools or gc-ai-tools.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="docs-reviewer" executor="inherited">
      <job>Senior documentation engineer: review the PO report and documentation the request affects.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), the documentation tree, and the code in scope. Assess which documents must change, organization and placement, separation of concerns between documents, structure and navigation, duplication against a single source of truth, accuracy against code, audience fit, and consistent terminology.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="test-reviewer" executor="inherited">
      <job>Senior test engineer: review the PO report and code to define the test strategy.</job>
      <input>
        <report>{REPORT}</report>
        <findings>{FINDINGS}</findings>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {REPORT}, the repository rules (README.md, AGENTS.md if present), the existing tests, and the code in scope. Define the behaviours each change must prove, the variations to cover (edge cases, invalid input, error paths, boundaries, state and ordering), test levels, fixtures, and where mocks would hide behaviour; these become stage acceptance criteria.
        Write {FINDINGS}: per point an id, evidence (path:line), severity, options, the recommended option with rationale, and links to other roles it affects. Answer follow-ups from the session, updating {FINDINGS}.
        Return a one-line outcome with the path and point count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; return questions to the session.</constraint>
      </constraints>
    </template>

    <template role="docs-auditor" executor="inherited">
      <job>Senior documentation engineer: audit the delivered documentation before the pull request.</job>
      <input>
        <base_branch>{BASE_BRANCH}</base_branch>
        <audit>{AUDIT}</audit>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read the repository rules (README.md, AGENTS.md if present), the plan files under plans/, the diff from {BASE_BRANCH} to HEAD, and the documentation tree. Validate organization and placement, separation of concerns between documents, structure and navigation, duplication against a single source of truth, accuracy against the delivered code, and consistent terminology.
        Write {AUDIT}: per correction the path, the exact change, severity, and rationale, each executable without further decisions.
        End with `<signal code="DOCS_OK">` when {AUDIT} lists no correction, else `<signal code="DOCS_FIX">`.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository.</constraint>
        <constraint>Ask the user nothing; scope corrections to documentation.</constraint>
      </constraints>
    </template>

    <template role="test-validator" executor="inherited">
      <job>Senior test engineer: validate the tests of one delivered stage before the planner's check.</job>
      <input>
        <plan_file>{PLAN_FILE}</plan_file>
        <stage>{STAGE}</stage>
        <verdicts>{VERDICTS}</verdicts>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {PLAN_FILE}, its stage {STAGE} acceptance criteria, the repository rules (README.md, AGENTS.md if present), and the diff of HEAD. Judge whether the tests assert behaviour rather than implementation, cover the required variations, use meaningful assertions, and avoid mocks that hide behaviour. Run the test suite; in a disposable git worktree or local clone under the OS temp directory, break each targeted behaviour and confirm a test fails, then remove that copy.
        Append to {VERDICTS} the stage, the verdict, and per correction the path, the missing or wrong test, and the expected assertion, each executable without further decisions.
        End with `<signal code="TESTS_OK">` when the stage needs no test correction, else `<signal code="TESTS_FIX">`.
      </instructions>
      <constraints>
        <constraint>Leave the repository working tree, index, and history untouched; mutate only the disposable copy.</constraint>
        <constraint>Ask the user nothing; judge from the plan and code evidence.</constraint>
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
        <notes>{NOTES}</notes>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        For stage 1, write {PLAN}, reading it first when it is a file path, to {PLAN_FILE} as that stage specifies. Read {PLAN_FILE} and the repository rules (README.md, AGENTS.md if present). Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of {PLAN_FILE}, and commit with the stage's Conventional Commit message. Apply {NOTES}, an optional session file, when it lists corrections from a failed check.
        When {STAGE} is docs-audit, record a docs-audit entry with status done in {PLAN_FILE}, apply the corrections in {NOTES}, and commit `docs: apply documentation audit`.
        When {MODE} is plan and this is the last stage, also run its removal, push, and pull request against the base branch, adding the follow-ups in {NOTES} to the pull request body.
        Return a one-line outcome with the commit hash, test summary, and changed paths.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Push only in the last stage of mode plan; mode campaign works locally with no push or remote mutation.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="DOCS_OK">The delivered documentation needs no correction; continue delivery.</signal>
    <signal code="DOCS_FIX">The audit file lists documentation corrections for one docs-audit stage.</signal>
    <signal code="TESTS_OK">The stage's tests prove its behaviour; the planner's check proceeds.</signal>
    <signal code="TESTS_FIX">The verdicts file lists test corrections; the implementer retries before the planner's check.</signal>
  </return_protocol>

  <boundaries>
    <rule id="protocols">Planning follows user-wide `<planning_protocol>` and delivery `<implementation_protocol>`; this skill states only its specifics: batched questions, the reviewer team, and delivery reuse from vibe-ai-tools and campaign-ai-tools.</rule>
    <rule id="reviewer-continuity">Keep planning reviewers active until approval; where the harness cannot continue a subagent, respawn its template with its findings file as context.</rule>
    <rule id="spawn-apis">Spawn templates per `<execution_protocol>`; if `<template role="stage-implementer">` cannot be spawned as {IMPLEMENTER}, stop as blocked per `<rule id="spawn-fallback">`.</rule>
    <rule id="chat-scope">Chat carries only questions, the approval, spawn announcements, a one-line outcome, and paths under {WORKDIR}; reports stay on disk.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="stay-in-repo">Stay inside the working repository. Preserve pre-existing commit history.</rule>
  </boundaries>
</skill>
