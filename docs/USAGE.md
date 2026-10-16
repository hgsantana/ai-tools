# Using ai-tools

This guide is harness-agnostic. Skills are the user entry points. Automatic routing depends on the user-wide instructions being loaded; see [Supported harnesses](../README.md#supported-harnesses).

## Invocation

Invoke a skill explicitly by leading with its slash name and optional request:

```text
/az-ai-tools list costly idle resources
```

Skills provide session-directed workflows. Testing, interaction, and security protocols are provided across supported harnesses via user-wide instructions.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/plan-ai-tools` | Formulate a user story as PO, have a Planner subagent draft the general plan, then on approval orchestrate each task through a Task Planner that details it, a single-task implementer that delivers it, and an Evaluator that judges and commits it, through to PR creation; with the slug of an existing plan it goes straight to orchestration | `/plan-ai-tools add user authentication` |
| `/vibe-ai-tools` | Refine a user story as PO interactively, then autonomously run planning, task implementation, validation, and PR creation | `/vibe-ai-tools add user authentication` |
| `/team-ai-tools` | Run the full team flow in one skill: PO story, Architect plan, then per task a domain Specialist details and validates what an isolated implementer delivers, through to PR creation | `/team-ai-tools add user authentication` |
| `/campaign-ai-tools` | Settle a campaign scope, then run unattended cycles in which a Planner scans the repository, plans one work point, and drives and validates single-task implementers, until nothing is left to do | `/campaign-ai-tools raise unit test coverage of the domain layer` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/stripe-ai-tools` | Inspect, integrate, and manage Stripe payments, Checkout Sessions, products, and webhooks | `/stripe-ai-tools integrate checkout session` |
| `/agy-ai-tools`, `/claude-ai-tools`, `/copilot-ai-tools` | Dispatch an agent by tier (`junior`, `mid-level`, `senior`) or explicit model and effort | `/claude-ai-tools senior review the auth module` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/update-ai-tools` | Preview update with dry-run, confirm destructive changes, and update across all harnesses | `/update-ai-tools` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and copilot` |

### Who does the work

Every skill runs on the session's model. The session handles user alignment, judgment, commits, and short pointers to disk; builds, tests, and bulk fact collection go to the harness's default subagent. In `/plan-ai-tools` the session is PO and orchestrator: it settles the story with the user, one clean-context Planner writes the general plan of architecture and task separation, and after the implementation offer the session itself dispatches, for each task, one clean-context Task Planner to detail it, one single-task implementer to deliver it, and one clean-context Evaluator on the session's model and effort to judge the story, plan, and task file against the diff and the implementation report and commit approved work; Evaluator and implementer end with their task. The session only branches on return signals, asks the user when a task blocks after 3 attempts, and opens the pull request. `/team-ai-tools` is the robust alternative for the same story: an Architect plans and assigns each task to one of nine domain Specialists, who details it and validates the implementer's delivery, under `docs/team-ai-tools/<slug>/` on branch `team/<slug>`. In `/vibe-ai-tools`, the session refines the story interactively with the user and then takes full autonomous ownership of subsequent technical decisions—favoring zero-cost and easily reversible choices—approving the Planner's general plan itself and then running the same per-task cycle of Task Planner, implementer, and Evaluator through to PR creation, with one autonomous recovery before asking the user about a blocked task, under `docs/vibe-ai-tools/<slug>/` on branch `vibe/<slug>`. Every skill is self-contained and cites no other skill. In `/campaign-ai-tools`, the session only settles scope and implementer with the user, dispatches one clean-context Planner per cycle, and makes the first and last commits on the local `campaign/<slug>` branch; each Planner plans, dispatches implementers, validates, and commits, and the session never reads or judges a delivery. The campaign has no cycle cap: it stops only after 2 consecutive Planners find nothing left to do or when a Planner cannot dispatch the implementer, and aborts with the campaign state left in place when a Planner returns without a signal; the branch is never pushed.

These four skills implement with the harness default subagent without asking. Name another implementer in the request to override it: `session-subagent`, or a tier (`junior`, `mid-level`, `senior`) optionally prefixed by a harness, `agy`, `claude`, or `copilot`, as in `/plan-ai-tools add user authentication, implement with agy junior`. A tier without a harness takes the current one; a tier of another harness is dispatched through that harness's CLI, and the skill stops when the CLI is unavailable.

### Agent dispatch

`/agy-ai-tools`, `/claude-ai-tools`, and `/copilot-ai-tools` each hold their harness's tier table. They dispatch through the CLI when installed, else through the harness subagent API with the tier's model and effort, else with the closest model and effort that API offers, and report which level and substitution applied. The same tier tables serve implementers requested in other skills, including a tier of another harness, dispatched through its CLI.

#
### Cloud and platform tools

`/az-ai-tools`, `/gc-ai-tools`, `/gh-ai-tools`, and `/stripe-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast-radius impact, and requires explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Maintenance

`/update-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/update.sh"` across all supported harnesses with `--overwrite`, `--harnesses all`, and `--discard-local`. It runs `--dry-run` first without questions, presents what will be lost or overwritten, and asks for confirmation before executing. `/remove-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/remove.sh"`: first settle harness scope, run with `--dry-run`, and present destructive flags separately. Both resolve the canonical clone first, do not run relative scripts from the caller's project, and leave `$HOME/.ai-tools/USER-AGENTS.md` untouched. An approved `--purge` writes dry-run, execution, and final reports under `$HOME/.ai-tools-remove-logs` so evidence survives deleting the clone.

First installation is not a skill: follow the root `README.md` installation process.
