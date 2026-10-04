# Plan: ui-ai-tools

| Stage | Title | Status | Implementer |
|---|---|---|---|
| 1 | Branch and plan file | done | session subagent (Claude Opus 5.5, High) |
| 2 | Add `ui-ai-tools` skill and lint registration | pending | session subagent (Claude Opus 5.5, High) |
| 3 | Documentation and version bump | pending | session subagent (Claude Opus 5.5, High) |
| 4 | Remove plan, push, pull request | pending | session subagent (Claude Opus 5.5, High) |

## Goal

Ship a new skill `ui-ai-tools` (slash `/ui-ai-tools`) for UI modernization:

1. Evaluate the routes the user names, or every discovered route when none is named, with one subagent per route, producing screenshots and a per-route report.
2. Each evaluation combines the rendered images (to see real design flaws and opportunities) with the route's source code.
3. The session consolidates an illustrated final report (referencing the images) and uses it to plan the modernization.
4. The session then plans and delivers per user-wide `<planning_protocol>` and `<implementation_protocol>`, reusing the vibe-ai-tools delivery shape, to a pull request.

## Decisions (from the grill-me interview)

- **Name**: `ui-ai-tools`.
- **Rendered app**: use the base URL given in the argument; without one, a default worker detects the dev command (package.json scripts, framework config), starts the server, returns the URL, and stops it after capture.
- **Capture**: the harness's own browser or browser MCP tool (e.g. Chrome DevTools MCP) first; fallback headless Playwright via `npx playwright screenshot --full-page --viewport-size=W,H` (nothing installed into the project).
- **Viewports**: full-page captures at desktop 1440x900, tablet 768x1024, mobile 390x844.
- **Evaluators**: one `executor="inherited"` subagent per route; it captures the three images, views them, reads the route's code, and writes the route report. At most 4 evaluators run in parallel (waves).
- **Discovery (no routes named)**: a default worker maps routes from the router (Next.js pages/app, React Router, Angular, Vue Router, SvelteKit, Remix, etc.), flagging dynamic routes (with example params) and protected routes; the session confirms the list with the user before spawning evaluators.
- **Protected routes**: the user supplies a storage-state/cookies file path or env var names holding test credentials; values never appear in reports, plans, or logs (`no-secrets`). Without access, the route is evaluated by code only and flagged "not captured".
- **Criteria**: a fixed baseline checklist — visual hierarchy, typography, spacing/grid, color and contrast, component consistency, responsiveness, accessibility, states (empty, error, loading), and UI code debt (legacy CSS, inline styles, duplicated components, obsolete libraries). Each finding carries severity (high, medium, low) and evidence (image path or `file:line`). The checklist is a floor, not a ceiling: evaluators must also propose bold, creative modernization ideas (layout, interaction, motion, visual language) beyond it, without limiting the redesign's ambition.
- **Output**: `${TMPDIR:-/tmp}/ai-tools/ui/{SLUG}/` with `routes.md` (discovered list), `routes/<route-slug>/{desktop,tablet,mobile}.png` and `report.md` per route, consolidated `report.md`, and `after/stage-<n>/` recaptures during delivery.
- **Planning**: the session reads the consolidated report and images, grills the user about design direction (brand constraints, design system or CSS stack, scope and priorities, appetite for creative change), then plans per `<planning_protocol>` and asks the implementer per `<rule id="implementer-offer">`.
- **Validation**: every stage that changes UI requires its implementer to recapture the affected routes at the three viewports into `after/stage-<n>/`; the planner compares before/after images alongside the git diff and test summary when validating the stage.
- **Agent field**: `session + implementer (model asked once)`, so the skill defines `<implementer_job>` and an `executor="implementer"` template, and `scripts/lint.sh` adds it to `IMPLEMENTER_SKILLS`.

## Stage 1 — Branch and plan file

- **Files in scope**: `plans/ui-ai-tools.md` (new).
- **Out of scope**: any other file.
- **Work**: from `master`, create branch `plan/ui-ai-tools`; write this whole plan to `plans/ui-ai-tools.md`; set stage 1 to done; append the stage report.
- **Acceptance criteria**: branch `plan/ui-ai-tools` exists and is checked out; `plans/ui-ai-tools.md` holds this plan opened by the status table; stage 1 status is done.
- **Required tests**: none beyond lint (no code changed).
- **Verification**: `git branch --show-current` prints `plan/ui-ai-tools`; `"$HOME/.ai-tools/scripts/lint.sh"` exits 0.
- **Commit**: `chore(plans): start ui-ai-tools plan`

## Stage 2 — Add `ui-ai-tools` skill and lint registration

- **Files in scope**: `skills/ui-ai-tools/SKILL.md` (new); `scripts/lint.sh` (add `ui-ai-tools` to the shipped/gated skill list in `check_skill_layout`, to `IMPLEMENTER_SKILLS`, and to the usage text that names implementer skills).
- **Out of scope**: README, `docs/USAGE.md`, version line, `USER-AGENTS.md`, other skills, install scripts. Do not add new XML tags (reuse the registered vocabulary only).
- **Skill specification** (follow README Semantic XML grammar and the style of `skills/vibe-ai-tools/SKILL.md` and `skills/team-ai-tools/SKILL.md`; extreme concision):
  - Frontmatter: `name: ui-ai-tools`; `description` (at most 500 characters, three parts in order): what it does and `/ui-ai-tools`; `Impact:` evaluators consume model quota, may start and stop a local dev server, writes screenshots and reports to OS temp, and after the briefing creates a branch, edits files, commits, pushes, and opens a pull request unattended; cloud and destructive operations require separate approval; `Agent: session + implementer (model asked once).` Add `argument-hint: "[routes] [base URL] [auth state path or env var names]"`.
  - `<overview>`: evaluate routes by image and code, consolidate an illustrated report, plan per `<planning_protocol>`, deliver per `<implementation_protocol>`.
  - `<session_workflow>` steps (numeric ids):
    1. setup — derive kebab-case {SLUG}; {WORKDIR} = `${TMPDIR:-/tmp}/ai-tools/ui/{SLUG}`; parse routes, base URL, and auth source (storage-state path or env var names, never values).
    2. discover — only when no route is named: spawn `<template role="route-mapper">`; present `{WORKDIR}/routes.md` and confirm the route list (and example params) with the user via `<user_interaction>` before any evaluator spawns.
    3. serve — only without a base URL: spawn `<template role="dev-server">` with {ACTION} = start; record the returned {BASE_URL} and stop handle.
    4. evaluate — spawn one `<template role="route-evaluator">` per route, at most 4 in parallel, in waves.
    5. consolidate — after all evaluators return, spawn `<template role="dev-server">` with {ACTION} = stop when step 3 started it; the session reads every route report and views the images, then writes `{WORKDIR}/report.md`: summary, cross-route patterns, prioritized opportunities (including creative ones), per-route sections embedding image paths and linking route reports, and not-captured routes. Show only its path in chat.
    6. plan — plan the modernization per `<planning_protocol>` from the report; the grill-me covers design direction (brand constraints, design system or CSS stack, scope and priorities, appetite for creative change). Every stage that changes UI lists, in its verification, recapture of the affected routes at the three viewports into `{WORKDIR}/after/stage-{STAGE}/`. Save the plan outside the repository at `{WORKDIR}/plan.md`. Immediately upon briefing approval, ask {IMPLEMENTER} per `<rule id="implementer-offer">`, framed by `<implementer_job>`, as the very first action; ask nothing else afterwards.
    7. deliver — for each stage spawn `<template role="stage-implementer">` as {IMPLEMENTER}; validate by reviewing the git diff, the concise test summary, and before/after images against the plan and stage acceptance criteria. Decide in-scope questions from code evidence and log them in the stage report. On a failed check run `git reset --soft HEAD~1` and respawn once with corrections; on a second failure stop as blocked without push or pull request and write evidence to `{WORKDIR}/blocked.md`.
    8. report — chat (user's language): one-line outcome, the implementer actually used, the report path, and the pull request URL or blocked evidence path.
  - `<implementer_job>`: as in vibe-ai-tools, plus: starts the app if needed and recaptures affected routes at the three viewports with the same capture method; requires frontend/UI editing skill.
  - `<dispatch_templates>` (every placeholder declared in `<input>` and used):
    - `route-mapper`, `executor="default-worker"`: input {WORKDIR}; map routes from the router configuration and file conventions; mark dynamic routes with example params and protected routes; write `{WORKDIR}/routes.md` (route, source file, dynamic params, protection); read-only on the repository; return one-line outcome with path.
    - `dev-server`, `executor="default-worker"`: input {ACTION}, {WORKDIR}; start: detect the dev command, start it in the background, wait until it responds, log to `{WORKDIR}/dev-server.log`, return URL and stop handle (PID); stop: stop that process; never deploy or touch remote resources.
    - `route-evaluator`, `executor="inherited"`: input {ROUTE}, {BASE_URL}, {AUTH}, {ROUTE_DIR}; capture full-page desktop 1440x900, tablet 768x1024, mobile 390x844 to `{ROUTE_DIR}/desktop.png`, `tablet.png`, `mobile.png` with the harness browser or browser MCP tool, else `npx playwright screenshot --full-page --viewport-size=W,H` (loading {AUTH} storage state when given); view each image; locate and read the route's source and styles; evaluate the baseline criteria (list them) with severity and evidence (image path or `file:line`), then propose bold creative modernization ideas beyond the checklist; when capture fails, evaluate by code only and mark "not captured" with the reason; write `{ROUTE_DIR}/report.md`; return one-line outcome with path. Constraints: read-only on the repository; never write credential or cookie values anywhere.
    - `stage-implementer`, `executor="implementer"`: input {SLUG}, {STAGE}, {PLAN}, {WORKDIR}; same instructions and constraints as vibe-ai-tools `stage-implementer`, plus: when the stage changes UI, recapture the affected routes at the three viewports into `{WORKDIR}/after/stage-{STAGE}/` and list those paths in the outcome.
  - `<boundaries>` rules with ids: `protocols` (planning/delivery follow user-wide protocols; skill states only its specifics), `spawn-apis` (spawn templates per `<execution_protocol>`; implementer spawn failure stops as blocked per `<rule id="spawn-fallback">`), `protocol-source` (same text as vibe-ai-tools), `evaluators-read-only` (evaluation steps 1–5 write only under {WORKDIR}; the repository is untouched until delivery), `secrets` (auth values never reach disk, chat, or briefs; pass only paths or env var names), `stay-in-repo` (as vibe-ai-tools).
- **Acceptance criteria**: `skills/ui-ai-tools/SKILL.md` exists with the specification above; description at most 500 characters with what/Impact/Agent and `/ui-ai-tools`; lint registers the skill as shipped and as an implementer skill; `scripts/lint.sh` exits 0; `scripts/test.sh` passes; shellcheck clean.
- **Required tests**: `scripts/lint.sh` (xml grammar, references, placeholder parity, agent field, description) and `scripts/test.sh` must pass; no new test cases required (install tests glob skills).
- **Verification**: `"$HOME/.ai-tools/scripts/lint.sh"`; `"$HOME/.ai-tools/scripts/test.sh"`; `shellcheck -x -P scripts/shell -P scripts/test scripts/shell/*.sh scripts/*.sh scripts/test/*.sh` (if shellcheck is installed).
- **Commit**: `feat(ui-ai-tools): add UI modernization skill`

## Stage 3 — Documentation and version bump

- **Files in scope**: `README.md`, `docs/USAGE.md`.
- **Out of scope**: skills, scripts, `USER-AGENTS.md`.
- **Work**:
  - README: bump the version line `0.0.67-ALPHA` to `0.0.68-ALPHA`; mention `ui-ai-tools` wherever the README enumerates implementer/delivery skills (Overview item 4, rule 5 list of skills citing the protocols, rule 6 `Agent:` list, rule 24 delivery-to-PR list, Development checks "agent field" bullet), with a one-sentence description in Overview item 4.
  - `docs/USAGE.md`: add a Skills table row (`/ui-ai-tools` — evaluate routes by screenshots and code, then plan and deliver a UI modernization; example `/ui-ai-tools /dashboard /settings http://localhost:3000`) and a short `### UI modernization` section describing discovery and confirmation, dev server, capture method and viewports, inherited evaluators in waves of 4, auth handling, report location, grill-me on design direction, before/after recapture validation, and delivery to a pull request.
- **Acceptance criteria**: docs describe the shipped behaviour exactly as in stage 2; version bumped; `scripts/lint.sh --base master` exits 0.
- **Required tests**: lint (rule citations, version bump).
- **Verification**: `"$HOME/.ai-tools/scripts/lint.sh" --base master`; `"$HOME/.ai-tools/scripts/test.sh"`.
- **Commit**: `docs: document ui-ai-tools`

## Stage 4 — Remove plan, push, pull request

- **Files in scope**: `plans/ui-ai-tools.md` (removed with `git rm`).
- **Out of scope**: any other change.
- **Work**: set stage 4 to done and append its report, then `git rm plans/ui-ai-tools.md`, commit, push `plan/ui-ai-tools` to origin, and open a pull request against `master` summarizing the change.
- **Acceptance criteria**: plan file absent on the branch tip; branch pushed; pull request open with its URL returned.
- **Required tests**: `scripts/lint.sh --base master` and `scripts/test.sh` pass before push.
- **Verification**: `git ls-files plans/` empty; `gh pr view --json url`.
- **Commit**: `chore(plans): complete ui-ai-tools plan`

## Stage reports

### Stage 1 — Branch and plan file

- Created branch `plan/ui-ai-tools` from `master` and wrote the full plan to `plans/ui-ai-tools.md`; stage 1 set to done.
- Verification: `git branch --show-current` prints `plan/ui-ai-tools`; `scripts/lint.sh` exits 0 (470 ok, 1 skipped — version bump needs `--base`, 0 warnings).
