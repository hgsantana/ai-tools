# Using ai-tools

This guide is harness-agnostic. Skills are the user entry points.

## Invocation and gate

Invoke a skill by leading with its slash name and optional request:

```text
/plan-ai-tools add resumable uploads
```

The `<skill_offer>` inside `<routing_gate>` is the only `USER-AGENTS.md` gate. It names each option's impact, then offers the relevant skill, **run it here**, and **something else**. The last choice lets the user name another skill, revise the request, or propose a different approach; a native **Other** field serves the same purpose. A leading `/name` confirms that skill's stake, offers other fitting skills, and proceeds after the answer. Choosing a skill runs its `<session_workflow>`, which coordinates delivery. A workflow that later invokes another skill does not re-enter `<routing_gate>`. Later approvals still follow the skill's own rules.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/vibe-ai-tools` | Plan under `dev/`, then execute that plan and deliver a pull request | `/vibe-ai-tools add resumable uploads` |
| `/plan-ai-tools` | Explore a multi-commit change, save a staged plan under `dev/`, then offer `/dev-ai-tools` | `/plan-ai-tools redesign cache invalidation` |
| `/dev-ai-tools` | Execute a specified `dev/` plan, a queue of pending plans, or one single-commit task | `/dev-ai-tools dev/cache-invalidation/` |
| `/campaign-ai-tools` | Repeatedly plan and deliver user-directed, multi-stage improvements in an autonomous local campaign | `/campaign-ai-tools repository-hardening` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/update-ai-tools` | Remove current-version artifacts, reset the clone, and install from origin/master | `/update-ai-tools all detected harnesses` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and cursor` |

### Who does the work

Every skill runs on the session's model: the session plans, decides, reviews, and commits. Builds, test suites, script runs, and bulk fact collection go to the harness's default subagent. The skill offer's Execution column, filled from the skills' `Agent:` field, shows `session`, or `session + implementer (model asked once)` for the two skills below.

`/vibe-ai-tools` and `/campaign-ai-tools` also spawn implementer subagents that write stage code. Before the first one, they ask one question: which model implements the stages, with one to three models the harness can use. `/vibe-ai-tools` asks after the plan is on disk. `/campaign-ai-tools` asks when the campaign starts, records the answer in `dev/improve/<campaign>/campaign.md`, and reuses it for every iteration and on resume. A harness that cannot choose a model per subagent skips the question and uses its default; the report says so.

### Delivery workflows

`/vibe-ai-tools` is the end-to-end choice for a larger change. It follows `/plan-ai-tools` to align scope with the user interactively and writes the agreed plan to disk. It then asks which model implements the stages and follows `/dev-ai-tools` unattended, with implementer subagents writing stage code. Decisions are recorded in `dev/<slug>/vibe-decisions.md`.

`/plan-ai-tools` designs only. Its output is a base plan plus one file per commit-sized stage under `dev/<slug>/`; the base plan records the branch used for analysis. After the plan is on disk it offers `/dev-ai-tools`. A one-commit request is redirected to `/dev-ai-tools` Task mode.

`/dev-ai-tools` executes a specified `dev/<slug>/` plan, or lists pending plans, proposes an order, and runs the accepted queue; or agrees one single-commit task. It creates the dedicated `plan/<slug>` branch from the recorded base and targets the pull request to that same branch. It implements each stage in the session, sends tests to the harness's default subagent, commits every accepted stage, archives the temporary work files, and opens a pull request or writes a local review patch when no host is available.

### Continuous improvement campaign

`/campaign-ai-tools` uses a single initial gate, followed by one question about the implementer model. Choosing it authorizes all local, in-repository work for that campaign; it does not push, open pull requests, mutate cloud resources, or write outside the repository. The user owns the campaign and specifies its objectives and priorities.

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

The campaign creates or resumes local branch `improve/repository-hardening`, records the implementer model, and commits `dev/improve/repository-hardening/campaign.md` at start. Each iteration chains planning and execution passes in fresh subagents on the session model while keeping the orchestrating session lean:

1. A fresh planning subagent evaluates the campaign branch and follows `plan-ai-tools`, saving one multi-stage plan under `dev/<slug>/`. The initial gate pre-authorizes it to resolve and accept its recommendations according to the user's campaign priorities.
2. A separate fresh execution subagent runs the `dev-ai-tools` stage loop against that plan, spawning implementers on the recorded model.
3. The execution pass judges diffs and test evidence, commits every accepted stage on `improve/<campaign>`, archives the plan, and updates `dev/improve/<campaign>/campaign.md` and `decisions.md`.
4. The orchestrating session starts the cycle again with a new planning pass. No planning context or conversation history is reused between passes.

The orchestrating session only starts the planning and execution passes and routes their short statuses, keeping its context minimal. Planning decides in-scope questions under the initial gate; after the implementer-model question at start, the user is not interrupted. Work needing remote mutation, an external write, or an unversioned destructive action blocks instead of expanding the authorization. Planning and execution passes must spawn their own implementer and default subagents. On a harness where they cannot, the first pass that needs one stops the campaign as blocked, with a report naming the missing capability. The pass does not do that work itself. Campaign delivery remains local: `dev-ai-tools` uses the campaign branch instead of `plan/<slug>` and does not push or open pull requests. On controlled completion, `dev/improve/<campaign>/` is archived and removed in a final commit, leaving the branch clean for merge.

If execution ends mid-plan, the last accepted stage remains committed and the campaign branch may have resumable plan files or a dirty worktree. Resume with the same campaign name:

```text
/campaign-ai-tools resume repository-hardening
```

A resumed campaign reuses its recorded implementer model.

To request a clean stop while it is running, say `Stop after the current plan.` An immediate interruption may leave the current stage dirty without affecting earlier commits.

### Cloud and GitHub platform

`/az-ai-tools`, `/gc-ai-tools`, and `/gh-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast-radius impact, and requires explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Maintenance

`/update-ai-tools` runs `update.sh`. `/remove-ai-tools` runs `remove.sh`. First settle harness scope, run the matching script with `--dry-run`, and save its output. Destructive flags are presented separately and run only when explicitly approved. The scripts preserve conflicts by default and leave the user-owned `$HOME/AGENTS.md` untouched.

First installation is not a skill: follow the root `README.md` installation process.
