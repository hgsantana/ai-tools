# Using ai-tools

This guide is harness-agnostic. Skills are the user entry points. Automatic routing depends on the user-wide instructions being loaded; see [Supported harnesses](../README.md#supported-harnesses).

## Invocation and gate

Invoke a skill by leading with its slash name and optional request:

```text
/plan-ai-tools add resumable uploads
```

`USER-AGENTS.md` routes in three cases, for a new end-user request in the host session only. A prompt that starts with or mentions a skill or slash command runs that skill's `<session_workflow>` immediately. Simple, well specified, or documentation-only requests run in the session without asking. Other non-trivial requests receive the `<skill_offer>` inside `<routing_gate>`, the only USER-AGENTS gate. The offer names each option's impact, then lists the relevant skill, **run it here**, and **something else**. The last choice lets the user name another skill, revise the request, or propose a different approach; a native **Other** field serves the same purpose. Choosing a skill from the offer runs its `<session_workflow>`. A workflow that later invokes another skill does not re-enter `<routing_gate>`. Authorized delegated payloads, spawn briefs, and continuations skip the gate; a fresh worker that loads these instructions executes its brief and does not offer skills. If `$HOME/AGENTS.md` exists, follow it after the gate; if missing, ignore it. Later skill-specific questions and mutation approvals still follow the skill's own rules.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/vibe-ai-tools` | Plan under `plans/`, then execute that plan and deliver a pull request | `/vibe-ai-tools add resumable uploads` |
| `/plan-ai-tools` | Explore a multi-commit change, save a staged plan under `plans/`, then offer `/dev-ai-tools` | `/plan-ai-tools redesign cache invalidation` |
| `/dev-ai-tools` | Execute a specified `plans/` plan, a queue of pending plans, or one single-commit task | `/dev-ai-tools plans/cache-invalidation/` |
| `/campaign-ai-tools` | Repeatedly plan and deliver user-directed, multi-stage improvements in an autonomous local campaign | `/campaign-ai-tools repository-hardening` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/models-ai-tools` | Inspect available models and configure preferred models per tier (`junior`, `mid`, `senior`) for installed CLI harnesses | `/models-ai-tools agy` |
| `/config-ai-tools` | Configure global behavioral preferences: skill offer gate, default CLI, and implementer model prompts | `/config-ai-tools offer_skills` |
| `/update-ai-tools` | Remove current-version artifacts, reset the clone, and install from origin/master | `/update-ai-tools all detected harnesses` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and copilot` |

### Who does the work

Every skill runs on the session's model. The session handles user alignment, judgment, commits, and short pointers to disk. Builds, test suites, script runs, and bulk fact collection go to the harness's default subagent. The skill offer's Execution column, filled from the skills' `Agent:` field, shows `session`, `session + implementer` for `/dev-ai-tools`, or `session + implementer (model asked once)` for the two skills below.

Specified or queued `/dev-ai-tools`, `/vibe-ai-tools`, and `/campaign-ai-tools` spawn an implementer per stage. `/campaign-ai-tools` also spawns a session-subagent planner to write each plan and to validate each stage from the working-tree diff. If a planner or implementer cannot be spawned, delivery stops as blocked; the host session does not take that role. A failed default-worker spawn is run by the context that requested it. `/dev-ai-tools` Task mode implements in the session when the work fits one commit.

`/vibe-ai-tools` and `/campaign-ai-tools` ask one question before the first implementer: which model implements the stages, with one to three models the harness can use. `/vibe-ai-tools` asks after the plan is on disk. `/campaign-ai-tools` asks when the campaign starts, records the answer in `plans/improve/<campaign>/campaign.md`, and reuses it for every iteration and on resume. `/dev-ai-tools` uses the harness default implementer model with no question. A harness that cannot choose a model per subagent skips the question and uses its default; chat names that.

### Delivery workflows

`/vibe-ai-tools` is the end-to-end choice for a larger change. It follows `/plan-ai-tools` to execute a structured grill-me design interview to stress-test assumptions and align scope interactively, writing the agreed plan to disk. It then asks which model implements the stages. The session delivers: implementer subagents write stage code; the session reviews, commits, and opens the pull request. Chat names the report path and a one-line outcome. Decisions are recorded in `plans/<slug>/vibe-decisions.md`.

`/plan-ai-tools` designs only. Its output is a base plan plus one file per commit-sized stage under `plans/<slug>/`; the base plan records the branch used for analysis. It executes a structured grill-me design interview, proactively probing unstated assumptions, edge cases, failure scenarios, harness compatibility, and architectural trade-offs one question at a time with recommendations through the harness question tool after exploring the codebase. After the plan is on disk it offers `/dev-ai-tools`. A one-commit request presents `/dev-ai-tools` Task mode with that skill's Impact and Agent and waits for acceptance before invoking it; refusal ends with a short planning assessment.

`/dev-ai-tools` executes a specified `plans/<slug>/` plan, or lists pending plans, proposes an order, and runs the accepted queue; or agrees one single-commit task. Specified and queued plans run in the session on `plan/<slug>` with one implementer spawn per stage. Task mode interviews the user one question at a time with recommendations after exploring the codebase, and implements the single stage in the session when it fits one Conventional Commit; otherwise it offers `/plan-ai-tools` or `/vibe-ai-tools`. Tests go to the harness's default subagent, or to the spawning context if that spawn fails. Delivery (archive, push, pull request) runs only when every required stage is finished (`F`). An exhausted stage (`E`) blocks, keeps the work unit, and stops the queue. Chat names the report path and the PR URL or review-patch path. Resume of an existing `plan/<slug>` preserves accepted commits.

### Continuous improvement campaign

`/campaign-ai-tools` authorizes all local, in-repository work for that campaign when the skill is invoked directly or chosen from the offer. It aligns campaign scope, priorities, and exclusions with the user one question at a time with recommendations after exploring the codebase. It does not push, open pull requests, mutate cloud resources, or write outside the repository. After that authorization, one separate question asks which model implements the stages. The user owns the campaign and specifies its objectives and priorities.

Recommended prompt:

```text
/campaign-ai-tools

Campaign: repository-hardening
Objective: autonomously identify and implement useful repository improvements.
Priorities: modernize test suites, improve error handling, update stale docs.
Each iteration must address one cohesive improvement or correction matching these priorities, planned in as many tested stages and commits as needed.
Continue until the available budget ends or a blocker occurs.
```

The short form uses the user's objective or explicit campaign name:

```text
/campaign-ai-tools repository-hardening
```

The campaign creates or resumes local branch `improve/repository-hardening`, records the implementer model, and commits `plans/improve/repository-hardening/campaign.md` at start. The session iterates scope with the user, then mediates each iteration on disk:

1. A planner subagent on the session model evaluates the campaign branch from its spawn payload, saving one multi-stage plan under `plans/<slug>/`. Invocation or selection pre-authorizes it to resolve and accept its recommendations according to the user's campaign priorities.
2. The session commits that plan on `improve/<campaign>` and spawns an implementer per unfinished stage on the recorded model.
3. The same planner role is spawned again with only the stage path. It reads the stage file and the working-tree `git diff` itself, writes a verdict to OS temp (${TMPDIR:-/tmp}/ai-tools/), and returns accept, rework, or blocked. The session applies that signal, commits on accept, and does not judge the diff.
4. When every required stage is finished, the session archives the plan, records the iteration, and starts the cycle again with a new planner spawn. Each planner spawn is zero-context; memory is on disk.

Chat names spawn roles and disk paths only. After the implementer-model question at start, the user is not interrupted. Work needing remote mutation, an external write, or an unversioned destructive action blocks instead of expanding the authorization. If the planner or an implementer cannot be spawned, the session stops the campaign as blocked and names the missing capability; it does not take that role. A failed default-worker spawn is run by the planner or implementer that requested it. Campaign delivery remains local: no push or pull request. On two consecutive planning spawns with nothing to plan, `plans/improve/<campaign>/` is archived and removed in a final commit, leaving the branch clean for merge. Budget exhaustion or a host halt pauses instead: campaign.md stays on the branch with last accepted stage and model. An exhausted stage (`E`) blocks the iteration, keeps the plan, and does not archive the campaign.

If execution ends mid-plan, the last accepted stage remains committed and the campaign branch may have resumable plan files or a dirty worktree. Resume with the same campaign name:

```text
/campaign-ai-tools resume repository-hardening
```

A resumed campaign reuses its recorded implementer model.

To request a clean stop while it is running, say `Stop after the current plan.` An immediate interruption may leave the current stage dirty without affecting earlier commits.

### Cloud and GitHub platform

`/az-ai-tools`, `/gc-ai-tools`, and `/gh-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast-radius impact, and requires explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Model configuration

`/models-ai-tools` interactively inspects available models and configures preferred models per tier (`junior`, `mid`, `senior`) for installed CLI harnesses (`agy`, `claude`, `copilot`). Selections are saved to `$HOME/.ai-tools/config.local.json` under `"models"`, allowing users to customize agent model dispatch without modifying repository code or version-controlled defaults in `config/agents.json`. When invoked with an optional harness argument (e.g., `/models-ai-tools agy`), it limits configuration to that specific harness.

### Behavioral configuration

`/config-ai-tools` configures global behavioral preferences across the `ai-tools` ecosystem, persisting settings in `$HOME/.ai-tools/config.local.json` under `"behavior"`. Key settings include:
- **Skill offer gate** (`offer_skills`): whether `USER-AGENTS.md` displays the interactive skill offer table on non-trivial requests or routes directly to execution. When modified, instructions are automatically recompiled and synchronized into installed harness configurations.
- **Default CLI harness** (`default_cli`): preferred CLI harness (`agy`, `claude`, `copilot`) for autonomous execution and tool invocations.
- **Implementer model prompt** (`ask_implementer_model`): whether skills like `/vibe-ai-tools` and `/campaign-ai-tools` ask for an implementer model before execution or proceed directly with configured tier defaults.

### Maintenance

`/update-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/update.sh"`. `/remove-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/remove.sh"`. Both resolve that canonical clone first and do not run a relative script from the caller's project. First settle harness scope, run the matching script with `--dry-run`, and save its output. Destructive flags are presented separately and run only when explicitly approved. The scripts preserve conflicts by default and leave the user-owned `$HOME/AGENTS.md` untouched. An approved `--purge` writes dry-run, execution, and final reports under `$HOME/.ai-tools-remove-logs` so evidence survives deleting the clone.

First installation is not a skill: follow the root `README.md` installation process.
