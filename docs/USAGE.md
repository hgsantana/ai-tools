# Using ai-tools

This guide is harness-agnostic. Skills are the user entry points. Automatic routing depends on the user-wide instructions being loaded; see [Supported harnesses](../README.md#supported-harnesses).

## Invocation

Invoke a skill explicitly by leading with its slash name and optional request:

```text
/vibe-ai-tools add resumable uploads
```

Skills provide session-directed workflows. Global planning, implementation, and execution protocols are provided across supported harnesses via user-wide instructions.

## Skills

| Skill | Use it for | Example |
|---|---|---|
| `/vibe-ai-tools` | Plan under `plans/`, then execute that plan and deliver a pull request | `/vibe-ai-tools add resumable uploads` |
| `/team-ai-tools` | Refine a request with a PO-led team of senior reviewers, then deliver a plan or campaign to a pull request | `/team-ai-tools add rate limiting to the public API` |
| `/campaign-ai-tools` | Repeatedly plan and deliver user-directed, multi-stage improvements in an autonomous local campaign | `/campaign-ai-tools repository-hardening` |
| `/az-ai-tools` | Inspect or manage Azure resources, subscriptions, infrastructure, and costs with `az` | `/az-ai-tools list costly idle resources` |
| `/gc-ai-tools` | Inspect or manage Google Cloud projects, infrastructure, and costs with `gcloud` | `/gc-ai-tools show resources in project-x` |
| `/agy-ai-tools`, `/claude-ai-tools`, `/copilot-ai-tools` | Dispatch an agent by tier (`junior`, `mid`, `senior`) or explicit model and effort | `/claude-ai-tools senior review the auth module` |
| `/gh-ai-tools` | Inspect or manage GitHub accounts, repository administration, environments, Actions/builds, issues, and releases | `/gh-ai-tools show failing Actions runs` |
| `/update-ai-tools` | Preview update with dry-run, confirm destructive changes, and update across all harnesses | `/update-ai-tools` |
| `/remove-ai-tools` | Remove installed ai-tools artifacts from selected harnesses | `/remove-ai-tools claude-code and copilot` |

### Who does the work

Every skill runs on the session's model. The session handles user alignment, judgment, commits, and short pointers to disk; builds, tests, and bulk fact collection go to the harness's default subagent. The user-wide planning and implementation rules add to each harness's own flows. Before the first stage of a plan, the session asks once who implements: the harness default or the `mid` tier of the current harness's skill. Every stage runs in a fresh implementer with a clean context; the stage 1 brief carries the full plan, or the path of a plan file saved outside the repository, which that implementer writes to `plans/<slug>.md`. If the implementer cannot be spawned, delivery stops as blocked.

### Agent dispatch

`/agy-ai-tools`, `/claude-ai-tools`, and `/copilot-ai-tools` each hold their harness's tier table. They dispatch through the CLI when installed, else through the harness subagent API with the tier's model and effort, else with the closest model and effort that API offers, and report which level and substitution applied.

### Delivery workflows

`/vibe-ai-tools` is the end-to-end choice for delivering a feature or fix. It grills the user into a staged plan, asks who implements, then runs unattended: stage 1 creates branch `plan/<slug>` and `plans/<slug>.md`, each later stage is delivered and committed by a fresh implementer that appends its report to the plan, and the last stage removes the plan, pushes, and opens the pull request.

### Team review

`/team-ai-tools` refines complex requests through a PO-led panel of senior reviewers before delivering unattended to a pull request. The session acts as product owner: it audits the request against repository documentation and code, asks the user nothing, and writes a PO analysis report under `${TMPDIR:-/tmp}/ai-tools/team/<slug>/po-report.md`. It selects 2–8 reviewers by relevance (`security`, `performance`, `ux`, `best-practices`, `design` for software architecture when structure changes, `devops` for CI, static analysis, build, deploy, infrastructure, and cost when those are touched, `docs` when behaviour or documentation changes, and `tests` when code changes, defining the behaviours and variations each stage must prove) that inherit the session's model and effort. Reviewers return findings; the PO clarifies and cross-routes points through up to 3 debate rounds per point. Open questions and decisions are asked in one batched round ending with the implementer question, re-iterating with affected reviewers on divergent answers. Once settled, the PO presents a plan (up to ~8 short stages) or campaign (3–10 goals) for user approval, then delivers unattended by reusing the delivery steps of `/vibe-ai-tools` or `/campaign-ai-tools`. During delivery, a test validator checks every stage that changes code or tests before the planner: it judges whether tests assert behaviour and cover variations, runs them, and confirms in a disposable copy that breaking the behaviour fails a test; a failure sends the implementer back once before the planner reviews. Before the last plan stage, or once before the campaign finish, a documentation auditor validates the delivered docs (organization, separation, structure, duplication, accuracy); one implementer stage applies its corrections, and anything left becomes a pull request follow-up without blocking delivery. Working files remain under `${TMPDIR:-/tmp}/ai-tools/team/<slug>/` until approved; nothing is written to the repository beforehand.

```text
/team-ai-tools add rate limiting to the public API
```

### Continuous improvement campaign

`/campaign-ai-tools` delivers a 3–10 goal campaign to a pull request. It aligns campaign scope, priorities, and exclusions with the user, asks once who implements, then iterates without interruption on branch `campaign/<campaign>`, recording progress in `plans/campaign/<campaign>.md`. Each goal is planned and delivered under `plans/campaign/<n>-<slug>.md`, and the finished campaign pushes and opens a pull request.

```text
/campaign-ai-tools repository-hardening
```

### Cloud and GitHub platform

`/az-ai-tools`, `/gc-ai-tools`, and `/gh-ai-tools` run read-only queries freely. Every mutation is presented separately with its target, reason, and cost or blast-radius impact, and requires explicit approval for that action.

`/gh-ai-tools` is for GitHub-hosted state and administration: accounts, organizations, repository settings and access, environments, secrets and variables, Actions, builds, artifacts, issues, and releases. Repository code work—commits, branches, tags, cherry-picks, rebases, merges, fetches, pulls, pushes, code review, and pull-request creation, updates, review, or merge—runs directly in the session without this skill. Platform policy such as rulesets, required checks, and pull-request settings remains in scope for the skill.

### Maintenance

`/update-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/update.sh"` across all supported harnesses with `--overwrite`, `--harnesses all`, and `--discard-local`. It runs `--dry-run` first without questions, presents what will be lost or overwritten, and asks for confirmation before executing. `/remove-ai-tools` runs `"$HOME/.ai-tools/scripts/shell/remove.sh"`: first settle harness scope, run with `--dry-run`, and present destructive flags separately. Both resolve the canonical clone first, do not run relative scripts from the caller's project, and leave `$HOME/AGENTS.md` untouched. An approved `--purge` writes dry-run, execution, and final reports under `$HOME/.ai-tools-remove-logs` so evidence survives deleting the clone.

First installation is not a skill: follow the root `README.md` installation process.
