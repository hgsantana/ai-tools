# Using ai-tools

This guide is harness-agnostic. Skills are the user entry points. Automatic routing depends on the user-wide instructions being loaded; see [Supported harnesses](../README.md#supported-harnesses).

## Invocation

Invoke a skill explicitly by leading with its slash name and optional request:

```text
/vibe-ai-tools add resumable uploads
```

Skills provide session-directed workflows. Testing, interaction, and security protocols are provided across supported harnesses via user-wide instructions, while planning, implementation, and agent dispatch protocols are provided by `plan-ai-tools` and `implement-ai-tools`.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/plan-ai-tools` | Probe assumptions, settle scope with the user, and formulate a staged plan | `/plan-ai-tools add OAuth2 authentication` |
| `/implement-ai-tools` | Deliver changes from an existing plan or directly via a simplified flow | `/implement-ai-tools plan-implement-skills` |
| `/vibe-ai-tools` | Plan under `plans/`, then execute that plan and deliver a pull request | `/vibe-ai-tools add resumable uploads` |
| `/team-ai-tools` | Refine a request with a PO-led team of senior reviewers, then deliver a plan or campaign to a pull request | `/team-ai-tools add rate limiting to the public API` |
| `/campaign-ai-tools` | Repeatedly plan and deliver user-directed, multi-stage improvements in an autonomous local campaign | `/campaign-ai-tools repository-hardening` |
| `/ui-ai-tools` | Evaluate routes by screenshots and code, then plan and deliver a UI modernization to a pull request | `/ui-ai-tools /dashboard /settings http://localhost:3000` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/agy-ai-tools`, `/claude-ai-tools`, `/copilot-ai-tools` | Dispatch an agent by tier (`junior`, `mid-level`, `senior`) or explicit model and effort | `/claude-ai-tools senior review the auth module` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/update-ai-tools` | Preview update with dry-run, confirm destructive changes, and update across all harnesses | `/update-ai-tools` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and copilot` |

### Who does the work

Every skill runs on the session's model. The session handles user alignment, judgment, commits, and short pointers to disk; builds, tests, and bulk fact collection go to the harness's default subagent. The planning and implementation protocols from `plan-ai-tools` and `implement-ai-tools` add to each harness's own flows. Before the first stage of a plan, the session probes assumptions through batched questions ending with who implements (the harness default or the `mid-level` tier of the current harness's skill), analyzes responses and iterates until settled, sends a chat message with the briefing and confirms approval, then presents the plan in chat (linking to the plan file when on disk, preferred over repeating written content) and obtains explicit approval before dispatching execution. Every stage runs in a fresh implementer with a clean context; the stage 1 brief carries the full plan, or the path of a plan file saved outside the repository, which that implementer writes to `docs/<skill>/<slug>/0-<slug>.md`. If the implementer cannot be spawned, delivery stops as blocked.

### Agent dispatch

`/agy-ai-tools`, `/claude-ai-tools`, and `/copilot-ai-tools` each hold their harness's tier table. They dispatch through the CLI when installed, else through the harness subagent API with the tier's model and effort, else with the closest model and effort that API offers, and report which level and substitution applied.

### Planning and implementation

`/plan-ai-tools` conducts the interactive planning protocol: it grills assumptions and scope with the user in batched questions, settles decisions, formulates short testable stages in conventional commit format, and presents the plan for user approval before handing off to delivery.

```text
/plan-ai-tools add OAuth2 authentication
```

`/implement-ai-tools` executes changes either stage-by-stage from an approved plan (running each stage in a fresh implementer with clean context, validating diffs and test summaries before advancing), or directly in a single stage when no plan is present.

```text
/implement-ai-tools plan-implement-skills
```

### Delivery workflows

`/vibe-ai-tools` is the end-to-end choice for delivering a feature or fix. It grills the user into a staged plan (batched questions ending with who implements, and iterative follow-ups), sends a chat message with the briefing and confirms it, presents the plan in chat (linking to it when on disk) and obtains explicit approval before delivery, then runs unattended: stage 1 creates branch `plan/<slug>` and `docs/vibe-ai-tools/<slug>/0-<slug>.md`, each later stage is delivered and committed by a fresh implementer that appends its report to the plan, and the last stage removes `docs/vibe-ai-tools/<slug>/`, pushes, and opens the pull request.

### Team review

`/team-ai-tools` refines complex requests through a PO-led panel of senior reviewers before delivering unattended to a pull request. The session acts as product owner: it audits the request against repository documentation and code, asks the user nothing, has a default worker record the test, lint, and build baseline, and writes a PO analysis report under `${TMPDIR:-/tmp}/ai-tools/team/<slug>/po-report.md`. It selects 2–8 reviewers by relevance (`security`, `performance`, `ux`, `best-practices`, `design` for software architecture when structure changes, `devops` for CI, static analysis, build, deploy, infrastructure, and cost when those are touched, `docs` when behaviour or documentation changes, and `tests` when code changes, defining the behaviours and variations each stage must prove) that inherit the session's model and effort. Reviewers return findings; the PO clarifies and cross-routes points through up to 3 debate rounds per point. Open questions and decisions are asked in batched rounds ending with who implements, and analyzed across debate rounds until closed; the PO sends a chat message with the briefing and confirms it. Once settled, the PO drafts a plan (up to ~8 short stages in the planning protocol's stage format) or campaign (3–10 goals), names each stage's validators (every selected reviewer whose domain the stage touches), has the active reviewers sign it off in one blockers-only round, presents the plan in chat (linking to `{WORKDIR}/plan.md`), and asks for user approval, carrying any unresolved blocker with its recommendation; it then delivers unattended by reusing the delivery steps of `/vibe-ai-tools` or `/campaign-ai-tools`. During delivery, every reviewer related to a stage validates it in parallel before the planner, within its own domain, against the decisions and acceptance criteria; for stages that change code or tests, a test validator also judges whether tests assert behaviour and cover variations, runs them without blaming baseline failures on the stage, and confirms in a disposable copy that breaking the behaviour fails a test. Any correction, whatever its severity, or a failed planner check sends the implementer back once with the merged corrections; the retry passes the same validators and the planner again, and a second failure blocks. Before the last plan stage, or once before the campaign finish, a final auditor checks the integrated diff for acceptance criteria, security regressions, and documentation, and runs the full test, lint, and build commands; one implementer stage applies its corrections, and anything left becomes a pull request follow-up, blockers highlighted, without blocking delivery. After the pull request opens, the session watches its CI checks for about 15 minutes and reports the status without fixing failures. Working files remain under `${TMPDIR:-/tmp}/ai-tools/team/<slug>/` until approved; nothing is written to the repository beforehand.

```text
/team-ai-tools add rate limiting to the public API
```

### Continuous improvement campaign

`/campaign-ai-tools` delivers a 3–10 goal campaign to a pull request. It aligns campaign scope, priorities, and exclusions with the user through batched questions ending with who implements, sends a chat message with the briefing and confirms it, presents the campaign record in chat (linking to it when on disk), and obtains explicit approval before iterating without interruption. Implementers make every repository write: a bootstrap stage creates branch `campaign/<campaign>` and the progress record `docs/campaign-ai-tools/<campaign>/campaign.md`; each goal's stages write, then remove, `docs/campaign-ai-tools/<campaign>/<n>-<slug>.md` and mark the goal done; a finish stage removes the campaign directory `docs/campaign-ai-tools/<campaign>/`, pushes, and opens a pull request, or a block stage records the reason without pushing. The session only resets a stage commit on a failed check, and goal planners stay read-only.

```text
/campaign-ai-tools repository-hardening
```

### UI modernization

`/ui-ai-tools` evaluates routes by rendered image and source code, then plans and delivers a UI modernization to a pull request. It takes the routes, a base URL, and an auth source (a storage-state path or env var names, never values). Without named routes, a default worker maps them from the router configuration and file conventions, and the session confirms the route list and example params with the user before evaluation. Without a base URL, a default worker starts the local dev server and stops it after evaluation. One evaluator per route, inheriting the session's model and effort, runs in waves of at most 4: it captures full-page screenshots at desktop 1440x900, tablet 768x1024, and mobile 390x844 with the harness browser or browser MCP tool, else `npx playwright screenshot`, reads the route's source and styles, and reports findings with severity and evidence plus creative modernization ideas; a failed capture falls back to a code-only evaluation marked "not captured". Auth values never reach disk, chat, or briefs. The session consolidates an illustrated report at `${TMPDIR:-/tmp}/ai-tools/ui/<slug>/report.md`, then plans from it with a grill-me on design direction (brand constraints, design system or CSS stack, scope and priorities, appetite for creative change) ending with who implements, sends a chat message with the briefing and confirms it, presents the plan in chat (linking to `{WORKDIR}/plan.md`), and obtains explicit approval before delivery. Delivery reuses the `/vibe-ai-tools` shape; each stage that changes UI recaptures the affected routes at the three viewports, and the session validates the diff, test summary, and before/after images before the next stage. The repository stays untouched until delivery.

```text
/ui-ai-tools /dashboard /settings http://localhost:3000
```

### Cloud and GitHub platform

`/az-ai-tools`, `/gc-ai-tools`, and `/gh-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast-radius impact, and requires explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Maintenance

`/update-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/update.sh"` across all supported harnesses with `--overwrite`, `--harnesses all`, and `--discard-local`. It runs `--dry-run` first without questions, presents what will be lost or overwritten, and asks for confirmation before executing. `/remove-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/remove.sh"`: first settle harness scope, run with `--dry-run`, and present destructive flags separately. Both resolve the canonical clone first, do not run relative scripts from the caller's project, and leave `$HOME/.ai-tools/USER-AGENTS.md` untouched. An approved `--purge` writes dry-run, execution, and final reports under `$HOME/.ai-tools-remove-logs` so evidence survives deleting the clone.

First installation is not a skill: follow the root `README.md` installation process.
