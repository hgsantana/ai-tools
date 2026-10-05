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
      Derive kebab-case {SLUG}. Spawn `<template role="baseline-runner">` with {BASELINE} = `{WORKDIR}/baseline.md`. Read the repository documentation (README, AGENTS.md, docs) and compare it with the code the request touches. Asking the user nothing, write `{WORKDIR}/po-report.md`: request restatement, a baseline summary from {BASELINE}, documentation-versus-code gaps, scope, ambiguities, and refinement questions each with options and a recommendation. Select 2–8 reviewer templates by relevance: `<template role="security-reviewer">`, `<template role="performance-reviewer">`, `<template role="ux-reviewer">`, `<template role="best-practices-reviewer">`, `<template role="design-reviewer">` only when structure changes, and `<template role="devops-reviewer">` only when the request touches CI, static analysis, build, deploy, infrastructure, or cost, `<template role="docs-reviewer">` only when it changes behaviour or documentation, and `<template role="test-reviewer">` only when it changes code; record one line on why each skipped role was skipped.
    </step>

    <step id="2" name="team-review">
      Spawn the selected reviewers in parallel, substituting {REPORT} = `{WORKDIR}/po-report.md` and {FINDINGS} = `{WORKDIR}/{role}.md`. Read every findings file. Clarify each point with its author and route points that touch another reviewer's findings to that reviewer, so they converge on one recommended option. After 3 rounds on a point without agreement, turn it into a user question carrying the divergent options, the PO recommendation, and the recorded dissent. Keep `{WORKDIR}/decisions.md` current: point, owner role, options, recommendation, status (agreed, open, user).
    </step>

    <step id="3" name="user-round">
      Ask every open question in one batched `<user_interaction>` call, each with its own options and its recommendation first; this batch replaces one-at-a-time questioning in `<rule id="grill-me">`. The first batch ends with the implementer question per `<rule id="implementer-offer">`, framed by `<implementer_job>`; never repeat it. Record answers in `decisions.md`. When an answer departs from its recommendation and needs clarification or replanning, take it to the affected reviewers per `<step id="2">`, then ask a new batch with only the resulting questions; repeat until every point is closed.
    </step>

    <step id="4" name="approve">
      Write `{WORKDIR}/plan.md` per `<planning_protocol>`, each stage per `<rule id="stage-format">`, with a baseline section from {BASELINE}, turning agreed decisions into acceptance criteria: a plan for one cohesive delivery within about 8 short stages, or a campaign for 3–10 independently deliverable goals. Send `plan.md` to the active reviewers for one sign-off round reporting blockers only; fold their blockers into the plan, and carry each unresolved blocker into the approval question with the PO recommendation. Ask approval via `<user_interaction>`, stating the choice and its reason, with options approve, switch between plan and campaign, or revise; revisions return to `<step id="2">` or `<step id="3">`. Approval ends the team: release the reviewers and ask nothing else afterwards.
    </step>

    <step id="5" name="deliver">
      Record {BASE_BRANCH} = the current branch and {DECISIONS} = `{WORKDIR}/decisions.md`. Implementers make every repository write; the session's only one is `git reset --soft HEAD~1` on a failed check, and planners stay read-only, both writing files only under `${TMPDIR:-/tmp}/ai-tools/`. Template inputs not set below are passed empty; {CAMPAIGN} is empty in plan mode.
      Plan: run vibe-ai-tools `<step id="2">` and `<step id="3">` with {IMPLEMENTER} and {SLUG}, the session as planner, spawning `<template role="stage-implementer">` with {MODE} = plan, {PLAN_FILE} = `docs/team-ai-tools/{SLUG}.md`, and {PLAN} = `{WORKDIR}/plan.md` for stage 1; run the final audit before the last stage and the CI report after it returns.
      Campaign: per campaign-ai-tools `<rule id="campaign-lifecycle">`, with {CAMPAIGN} = {SLUG}, every `<template role="stage-implementer">` spawn carrying {MODE} = campaign and {CAMPAIGN}. Bootstrap: spawn it with {STAGE} = bootstrap, {PLAN_FILE} = `docs/campaign-ai-tools/{CAMPAIGN}.md`, and {PLAN} = the campaign record: global objective, {BASE_BRANCH}, the approved goals each with {N}, a kebab-case {GOAL_SLUG}, and status, priorities, exclusions, {IMPLEMENTER}, and an iteration log. Goals: for each goal, spawn `<template role="goal-planner">` with {CAMPAIGN}, {N}, {GOAL_SLUG}, {REPORT} = `{WORKDIR}/po-report.md`, {DECISIONS}, and {FINDINGS_DIR} = {WORKDIR}, keeping it active across the goal's stages as its planner, else respawning it with its plan; for each stage spawn the implementer with {PLAN_FILE} = `docs/campaign-ai-tools/{N}-{GOAL_SLUG}.md`, {STAGE}, and, for stage 1, {PLAN} = the returned plan content or `{WORKDIR}/goal-{N}.md`. Finish: after the last goal, run the final audit once with {PLAN_FILE} = `docs/campaign-ai-tools/{CAMPAIGN}.md`, then spawn the implementer with {STAGE} = finish and that {PLAN_FILE}, and run the CI report after it returns.
      Stage validation: for each stage that changes code or tests, skipping plan-only, documentation-only, final-audit, and closing stages, spawn `<template role="test-validator">` with {PLAN_FILE}, {STAGE}, {BASELINE} = `{WORKDIR}/baseline.md`, and {VERDICTS} = `{WORKDIR}/verdicts/{N}-{STAGE}.md` (N = 0 in plan mode) before the planner's check, keeping one per plan or goal active across stages, else spawning a fresh one. On `<signal code="TESTS_OK">`, the planner's check proceeds. On `<signal code="TESTS_FIX">`, skip the planner's check and set {NOTES} = that stage's {VERDICTS}; on a failed planner check, write its corrections to `{WORKDIR}/corrections/{N}-{STAGE}.md` and set {NOTES} to that file. Then run `git reset --soft HEAD~1` and respawn the implementer once with {NOTES}; the retry passes the test-validator, when the stage changes code or tests, then the planner's check, and a second failure of either blocks. On block, write the evidence to `${TMPDIR:-/tmp}/ai-tools/{SLUG}-blocked.md` and preserve `docs/team-ai-tools/` or `docs/campaign-ai-tools/` respectively, with no push or pull request; in campaign mode, then spawn the implementer with {STAGE} = block and {PLAN_FILE} = `docs/campaign-ai-tools/{CAMPAIGN}.md`, unless it cannot be spawned.
      Final audit: spawn `<template role="final-auditor">` with {BASE_BRANCH}, {DECISIONS}, {BASELINE} = `{WORKDIR}/baseline.md`, and {AUDIT} = `{WORKDIR}/final-audit.md`. On `<signal code="AUDIT_FIX">`, spawn `<template role="stage-implementer">` with {STAGE} = final-audit and {NOTES} = {AUDIT}, then validate its diff against {AUDIT} once; write corrections it left unresolved to `{WORKDIR}/followups.md`, blockers first and highlighted, and pass that path as {FOLLOWUPS} to the plan's last stage or the campaign finish, without blocking delivery.
      CI report: once the pull request is open, run `gh pr checks --watch` with a timeout of about 15 minutes, write failing check output to `{WORKDIR}/ci.md`, state the CI status (passed, failed, or pending at timeout) in the closing chat line, and attempt no automatic fix.
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

    <template role="final-auditor" executor="inherited">
      <job>Senior reviewer: audit the integrated delivery against the decisions before the pull request.</job>
      <input>
        <base_branch>{BASE_BRANCH}</base_branch>
        <decisions>{DECISIONS}</decisions>
        <baseline>{BASELINE}</baseline>
        <audit>{AUDIT}</audit>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read the repository rules (README.md, AGENTS.md if present), the plan files under docs/, {DECISIONS}, {BASELINE}, the diff from {BASE_BRANCH} to HEAD, and the documentation tree. Run the full test, lint, and build commands, attributing failures already recorded in {BASELINE} to the baseline. Validate the acceptance criteria across stages, security regressions, and documentation organization and placement, separation of concerns between documents, structure and navigation, duplication against a single source of truth, accuracy against the delivered code, and consistent terminology.
        Write {AUDIT}: per correction the path, the exact change, severity (blocker, high, medium, low), and rationale, each executable without further decisions.
        End with `<signal code="AUDIT_OK">` when {AUDIT} lists no correction, else `<signal code="AUDIT_FIX">`.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; leave tracked files, the index, and history untouched, writing only {AUDIT}.</constraint>
        <constraint>Ask the user nothing; judge from the decisions and code evidence.</constraint>
      </constraints>
    </template>

    <template role="baseline-runner" executor="default-worker">
      <job>Default worker: record the repository's test, lint, and build baseline before any change.</job>
      <input>
        <baseline>{BASELINE}</baseline>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Discover the repository's existing test, lint, and build commands from its rules (README.md, AGENTS.md if present), scripts, and CI files, and run each.
        Write {BASELINE}: per command the command line, exit code, and known failures with their evidence.
        Return a one-line outcome with the path and command count.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; leave tracked files, the index, and history untouched, writing only {BASELINE}.</constraint>
        <constraint>Ask the user nothing; record a missing command as absent.</constraint>
      </constraints>
    </template>

    <template role="test-validator" executor="inherited">
      <job>Senior test engineer: validate the tests of one delivered stage before the planner's check.</job>
      <input>
        <plan_file>{PLAN_FILE}</plan_file>
        <stage>{STAGE}</stage>
        <baseline>{BASELINE}</baseline>
        <verdicts>{VERDICTS}</verdicts>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read {PLAN_FILE}, its stage {STAGE} acceptance criteria, {BASELINE}, the repository rules (README.md, AGENTS.md if present), and the diff of HEAD. Judge whether the tests assert behaviour rather than implementation, cover the required variations, use meaningful assertions, and avoid mocks that hide behaviour. Run the test suite, attributing failures already recorded in {BASELINE} to the baseline rather than the stage; in a disposable git worktree or local clone under the OS temp directory, break each targeted behaviour and confirm a test fails, then remove that copy.
        Append to {VERDICTS}, this stage's verdicts file, the verdict and per correction the path, the missing or wrong test, and the expected assertion, each executable without further decisions.
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
        <goal_slug>{GOAL_SLUG}</goal_slug>
        <report>{REPORT}</report>
        <decisions>{DECISIONS}</decisions>
        <findings_dir>{FINDINGS_DIR}</findings_dir>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files.
        Read docs/campaign-ai-tools/{CAMPAIGN}.md, {REPORT}, {DECISIONS}, the reviewer findings files in {FINDINGS_DIR}, the repository rules (README.md, AGENTS.md if present), and the code goal {N} touches. Plan goal {N} into short stages per `<planning_protocol>`, with the decisions as acceptance criteria and these campaign adaptations: stage 1 writes docs/campaign-ai-tools/{N}-{GOAL_SLUG}.md on campaign/{CAMPAIGN} without creating a branch; the last stage runs `git rm` on that goal plan, sets goal {N} done and logs the iteration in docs/campaign-ai-tools/{CAMPAIGN}.md, and commits `chore(plans): complete goal {GOAL_SLUG}`, without pushing or opening a pull request. Return the plan as content, or write it to {FINDINGS_DIR}/goal-{N}.md when you can write there.
        Stay active across the goal's stages: inspect each stage's git diff and test summary against docs/campaign-ai-tools/{N}-{GOAL_SLUG}.md and return only the approval verdict or corrections.
        Return the plan content, or a one-line outcome with its path.
      </instructions>
      <constraints>
        <constraint>Read-only on the repository; write only {FINDINGS_DIR}/goal-{N}.md.</constraint>
        <constraint>Ask the user nothing; decide from the decisions and code evidence, logging each choice in the plan.</constraint>
      </constraints>
    </template>

    <template role="stage-implementer" executor="implementer">
      <job>Implementer: deliver one plan or campaign stage from a clean context.</job>
      <input>
        <mode>{MODE}</mode>
        <campaign>{CAMPAIGN}</campaign>
        <plan_file>{PLAN_FILE}</plan_file>
        <stage>{STAGE}</stage>
        <plan>{PLAN}</plan>
        <notes>{NOTES}</notes>
        <followups>{FOLLOWUPS}</followups>
      </input>
      <instructions>
        This payload is the brief; do not read sibling skill files. Read the repository rules (README.md, AGENTS.md if present), then act by {STAGE}. {NOTES} is an optional session file of corrections from a failed check; {FOLLOWUPS} an optional session file of follow-ups for the pull request body.
        Bootstrap: create branch campaign/{CAMPAIGN} from the current branch, write {PLAN} to {PLAN_FILE}, and commit `chore(plans): start campaign {CAMPAIGN}`.
        Stage number: for stage 1, write {PLAN}, reading it first when it is a file path, to {PLAN_FILE} as that stage specifies. Read {PLAN_FILE}. Deliver only stage {STAGE}: match surrounding style, write and run its tests reporting only a concise summary of coverage and execution, set its Status to done, append a short report to the end of {PLAN_FILE}, and commit with the stage's Conventional Commit message. When {NOTES} is set, this is a retry: the previous attempt is staged after `git reset --soft HEAD~1`; fix it in place by applying {NOTES}. When {MODE} is plan and this is the last stage, run removal of `docs/team-ai-tools/` (with `git rm -r docs/team-ai-tools`), push, and pull request against the base branch, adding {FOLLOWUPS} to its body.
        Final-audit: record a final-audit entry with status done in {PLAN_FILE}, apply the corrections in {NOTES}, run the tests reporting only a concise summary, and commit `fix: apply final audit`, or a more fitting Conventional Commit type.
        Finish: read the base branch from {PLAN_FILE}, remove `docs/campaign-ai-tools/` (with `git rm -r docs/campaign-ai-tools`), commit `chore(plans): complete campaign {CAMPAIGN}`, push campaign/{CAMPAIGN}, and open a pull request against the base branch, adding {FOLLOWUPS} to its body.
        Block: record the reason from `${TMPDIR:-/tmp}/ai-tools/{CAMPAIGN}-blocked.md` and that evidence path in {PLAN_FILE}, preserve the docs directory (`docs/team-ai-tools/` or `docs/campaign-ai-tools/`), and commit `chore(plans): block campaign {CAMPAIGN}`.
        Return a one-line outcome with the commit hash, test summary, changed paths, and any pull request URL.
      </instructions>
      <constraints>
        <constraint>Stay within the stage's scope.</constraint>
        <constraint>Do not validate delivery against the macro plan; run tests, commit locally, and return outcome.</constraint>
        <constraint>Push and open a pull request only in the last stage of mode plan or in finish, with no other remote mutation; mode campaign works on campaign/{CAMPAIGN}.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <return_protocol>
    <signal code="AUDIT_OK">The integrated delivery needs no correction; continue delivery.</signal>
    <signal code="AUDIT_FIX">The audit file lists corrections for one final-audit stage.</signal>
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
