# Using ai-tools

This guide is harness-agnostic. Skills are user entry points; agents are spawn-only workers selected by a skill or an orchestrating session.

## Invocation and gate

Invoke a skill by leading with its slash name and optional request:

```text
/plan-ai-tools add resumable uploads
```

A shipped skill passes one routing gate before it starts. The gate shows the skill's impact and model fit, then offers that skill, **run it here**, and **stop**. Choosing the skill authorizes its workflow; later approvals still follow that skill's own rules.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/vibe-ai-tools` | Plan a larger change with user relay, then implement the approved plan and deliver a pull request | `/vibe-ai-tools add resumable uploads` |
| `/plan-ai-tools` | Explore a multi-commit change and save a staged plan under `dev/`, then stop | `/plan-ai-tools redesign cache invalidation` |
| `/dev-ai-tools` | Execute an accepted `dev/` plan, or agree and deliver one single-commit task | `/dev-ai-tools dev/cache-invalidation/` |
| `/improve-ai-tools` | Repeatedly plan and deliver relevant, multi-stage improvements in an autonomous local campaign | `/improve-ai-tools repository-hardening` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/update-ai-tools` | Update an existing installation and refresh installed copies | `/update-ai-tools all detected harnesses` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and cursor` |
| `/reinstall-ai-tools` | Repair a broken, stale, or differently scoped installation from a fresh source tree | `/reinstall-ai-tools all harnesses` |

### Delivery workflows

`/vibe-ai-tools` is the end-to-end choice for a larger demand. It delegates planning, relays design questions, asks the user to approve the saved plan, then follows `/dev-ai-tools` through implementation, validation, commits, push, and pull request.

`/plan-ai-tools` designs only. Its output is a base plan plus one file per commit-sized stage under `dev/<slug>/`; the base plan records the branch used for analysis. A one-commit request is redirected to `/dev-ai-tools` Task mode.

`/dev-ai-tools` executes accepted work unattended after task or plan agreement. It creates the dedicated `plan/<slug>` branch from the recorded base and targets the pull request to that same branch: the analysis branch for a saved plan, or the branch current when a standalone task was requested. It delegates edits and tests, commits every accepted stage, archives the temporary work files, and opens a pull request or writes a local review patch when no host is available.

### Continuous improvement campaign

`/improve-ai-tools` uses a single initial gate. Choosing it authorizes all local, in-repository work for that campaign; it does not push, open pull requests, mutate cloud resources, or write outside the repository.

Recommended prompt:

```text
/improve-ai-tools

Campaign: repository-hardening
Objective: autonomously identify and implement useful repository improvements.
Prioritize correctness, reliability, tests, maintainability, and stale documentation.
Each iteration must address one relevant, cohesive improvement or correction, planned in as many tested stages and commits as needed.
Continue until the available budget ends or a blocker occurs.
```

The short form uses the skill's default priorities:

```text
/improve-ai-tools repository-hardening
```

The campaign creates or resumes local branch `improve/repository-hardening`, using the repository's base-branch rules. Each iteration chains the two planning workflows through fresh, zero-context agents:

1. A `planner-ai-tools` agent evaluates the current campaign branch and runs `plan-ai-tools`, saving one relevant multi-stage plan under `dev/`. The initial gate pre-authorizes it to resolve and accept its own recommendations.
2. The root session receives the plan path and spawns a different `planner-ai-tools` agent to run `dev-ai-tools` against that accepted plan.
3. The execution planner dispatches implementers and mechanical testers, judges their diffs and evidence, commits every accepted stage, archives the plan, and reports the result.
4. The root session starts the cycle again with another new planning agent. No planner instance or conversation history is reused between passes.

The root session only dispatches the planning and execution agents and routes their short statuses. Those planners decide in-scope questions under the initial gate; the user is not interrupted after it. Work needing remote mutation, an external write, or an unversioned destructive action blocks instead of expanding the authorization. Campaign delivery remains local: `dev-ai-tools` uses the campaign branch instead of `plan/<slug>` and does not push or open pull requests.

If execution ends mid-plan, the last accepted stage remains committed and the campaign branch may have resumable plan files or a dirty worktree. Resume with the same campaign name:

```text
/improve-ai-tools resume repository-hardening
```

To request a clean stop while it is running, say `Stop after the current plan.` An immediate interruption may leave the current stage dirty without affecting earlier commits.

### Cloud and GitHub platform

`/az-ai-tools`, `/gc-ai-tools`, and `/gh-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast impact, and requires an explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Installation maintenance

`/update-ai-tools`, `/remove-ai-tools`, and `/reinstall-ai-tools` first settle harness scope, run the matching script with `--dry-run`, and save its output. Destructive flags are presented separately and run only when explicitly approved. The scripts preserve conflicts by default and leave the user-owned `$HOME/AGENTS.md` untouched.

First installation is not a skill: follow the root `README.md` installation process.

## Agents

Agents are not user-facing skills. Do not offer or invoke them as alternatives to a slash skill; the selected workflow spawns the lowest capable role with a bounded brief.

| Agent | Role | Responsibility |
|---|---|---|
| `planner-ai-tools` | planner | Clarifies scope, explores, designs, adjudicates decisions, owns acceptance, and delegates implementation |
| `implementer-ai-tools` | implementer | Writes code and tests for one assigned stage or brief, matching repository conventions |
| `mechanical-ai-tools` | mechanical | Applies fully specified changes, runs commands and tests, and collects factual evidence |

Every spawn is announced in the user's language. Agents write durable substance to their assigned file or `dev/tmp/` and return short paths and outcomes to the orchestrating session. Their wrappers select the configured model for the role.
