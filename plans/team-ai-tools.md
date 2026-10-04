# Plan: team-ai-tools

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Branch and plan file | done | self (flash) |
| 2 | `inherited` executor and stray `</rule>` fix | todo | self (flash) |
| 3 | `skills/team-ai-tools/SKILL.md` and lint registration | todo | self (flash) |
| 4 | Documentation (README, USAGE, 3–10 goal drift) | todo | self (flash) |
| 5 | Remove plan, push, pull request | todo | self (flash) |

## Goal

Add skill `team-ai-tools`: the session (strong model) acts as product owner (PO) and orchestrator. It audits the request against repository docs and code, writes a PO report without talking to the user, spawns 2–5 senior reviewers (security, performance, UX, best practices, design) that inherit its model and effort, converges their findings (max 3 rounds per point, cross-routing points between reviewers), asks the user every open question in one batched round (implementer question last), iterates reviewers + user until closed, presents a plan or campaign for approval, then delivers it by reusing `vibe-ai-tools` / `campaign-ai-tools` delivery steps.

## Decisions (from briefing)

- D1: New executor `inherited` in USER-AGENTS `<execution_protocol>` (subagent inheriting session model and effort, else closest), registered in `scripts/lint.sh` `valid_executors` and the README grammar.
- D2: `design` reviewer = software architecture (modules, contracts, APIs, data modeling), only when structure changes. `best-practices` = style, tests, maintainability, repository conventions.
- D3: PO picks 2–5 reviewers by relevance and records in the report why each skipped role was skipped.
- D4: Up to 3 clarification/debate rounds per point between PO and reviewers; unresolved points become user questions with divergent options, PO recommendation, and recorded dissent.
- D5: Delivery reuses by citation: plan → `vibe-ai-tools` `<step id="2">`/`<step id="3">`; campaign → `campaign-ai-tools` `<step id="1">` (from branch creation on), `<step id="2">`, `<step id="3">`, skipping their grill and implementer offer. Team skill defines its own `stage-implementer` template (lint requires it) parameterized by plan file and mode, plus a `goal-planner` template (executor `inherited`) briefed with report and decisions.
- D6: PO decides plan (one cohesive delivery, up to ~8 short stages) vs campaign (3–10 independently deliverable goals); approval states choice and reason; user may switch there.
- D7: Reviewers end at approval; per-stage validation follows vibe/campaign; reviewer decisions become acceptance criteria.
- D8: Remove the stray `</rule>` at USER-AGENTS.md line 20 (lint currently warns); align README/USAGE "3–5 goals" with campaign's "3–10".
- One template per reviewer type (explicit user request); templates are self-contained payloads, so the shared review method is duplicated in each.
- Working files: `${TMPDIR:-/tmp}/ai-tools/team/{SLUG}/` (`po-report.md`, `<role>.md` findings, `decisions.md`, `plan.md`). Nothing is written to the repository before approval.

## Stage 1 — Branch and plan file

- Create branch `plan/team-ai-tools` from `master`.
- Write this whole plan to `plans/team-ai-tools.md` (status table first; replace `{IMPLEMENTER}` with the actual implementer name given in the brief, or leave as given).
- Commit: `chore(plans): start team-ai-tools plan`.
- Acceptance: branch exists, file committed, nothing else changed.

## Stage 2 — `inherited` executor and stray `</rule>` fix

- `USER-AGENTS.md`:
  - Delete the stray line 20 `</rule>` (the line after `<rule id="implementer-offer">…</rule>`).
  - In `<execution_protocol>`, after `<rule id="implementer">`, add:
    `<rule id="inherited">`executor="inherited"`: subagent spawned per `<rule id="native-spawn">` with the session's model and effort, else the closest available, for review and planning.</rule>`
  - Stay under 8,000 characters (currently ~6,084).
- `scripts/lint.sh` `valid_executors`: accept `inherited` alongside `default-worker` and `implementer` (loop list and comments: "three known executor kinds"). Update the xml-grammar comment/help text near line 66 if it says "two".
- `README.md`:
  - Semantic XML grammar "Executors" bullet: three valid `executor` values, adding `inherited` (subagent inheriting the session's model and effort, else closest, for review and planning).
  - Development checks "xml grammar" bullet: "one of the three USER-AGENTS `<execution_protocol>` defines".
  - Bump version line to `0.0.66-ALPHA` (once for this PR).
- Tests: `scripts/lint.sh` → 0 warnings; `scripts/test.sh` passes.
- Commit: `feat(protocols): add inherited executor and fix stray rule tag`.

## Stage 3 — Skill and lint registration

- Create `skills/team-ai-tools/SKILL.md` with the content below (adjust only to satisfy lint; keep meaning).
- `scripts/lint.sh`: add `team-ai-tools` to `gated` in `check_skill_layout` and to `IMPLEMENTER_SKILLS`; update the help/comment text that lists implementer skills (around line 36–37).
- Tests: `scripts/lint.sh` → 0 warnings (description ≤ 500 chars, placeholder parity, references resolve including qualified `vibe-ai-tools`/`campaign-ai-tools` step references); `scripts/test.sh` passes. If lint cannot resolve a qualified step reference, fix the wording to a form lint resolves rather than changing lint semantics, and log it in the stage report.
- Commit: `feat(team-ai-tools): add PO-led senior review team skill`.

### SKILL.md content

```markdown
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
```

Notes for the implementer:
- `goal-planner` uses only declared placeholders; "goal slug" and "plans/campaign/{N}-slug.md" are prose to avoid undeclared placeholders. Keep placeholder parity.
- If lint rejects `{WORKDIR}`/`{GOAL_SLUG}`/`{role}` in session steps (outside templates), keep them (steps are not subject to parity) unless lint flags them; then adjust wording.

## Stage 4 — Documentation

- `README.md`:
  - Overview item 4: mention `team-ai-tools` (PO session + 2–5 inherited senior reviewers, batched questions, plan or campaign, delivery reusing vibe/campaign) and fix "3–5 goals" → "3–10 goals".
  - Rule 5: add `team-ai-tools` to the skills that cite `<planning_protocol>`/`<implementation_protocol>` and resolve the implementer through the offer.
  - Rule 6: add `team-ai-tools` to the `session + implementer (model asked once)` list.
  - Rule 24 last sentence: `vibe-ai-tools`, `campaign-ai-tools`, and `team-ai-tools` deliver to a pull request.
  - Development checks "agent field" bullet: add `team-ai-tools`.
- `docs/USAGE.md`:
  - Skills table row: `/team-ai-tools` | Refine a request with a PO-led team of senior reviewers, then deliver a plan or campaign to a pull request | `/team-ai-tools add rate limiting to the public API`.
  - New section "Team review" after "Delivery workflows": PO analysis report, 2–5 reviewers chosen by relevance (security, performance, UX, best practices, design = architecture when structure changes), up to 3 debate rounds per point, one batched question round ending with the implementer question, re-iteration on divergent answers, plan vs campaign approval, delivery via vibe/campaign steps; working files under `${TMPDIR:-/tmp}/ai-tools/team/<slug>/`.
  - Campaign section: "3–5 goal" → "3–10 goal".
- Tests: `scripts/lint.sh` (0 warnings, rule citations valid).
- Commit: `docs: document team-ai-tools and align campaign goal range`.

## Stage 5 — Finish

- `git rm plans/team-ai-tools.md`, commit `chore(plans): complete team-ai-tools plan`.
- Run `scripts/lint.sh --base master` (version bump check must pass).
- Push `plan/team-ai-tools` and open a pull request against `master` summarizing the stages.

# Stage reports

### Stage 1: Branch and plan file
- Created branch `plan/team-ai-tools` from `master`.
- Initialized plan in `plans/team-ai-tools.md` with status table tracking all 5 stages.
- Replaced `{IMPLEMENTER}` with `self (flash)` and marked Stage 1 status as done.
