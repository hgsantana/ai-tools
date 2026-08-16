# Global agent instructions

Harness-agnostic, user-wide rules for AI coding tools. A repository's own `AGENTS.md` or `README.md` overrides these rules inside that repository.

This file is installed from `$HOME/.ai-tools/GLOBAL-AGENTS.md` (`%USERPROFILE%\.ai-tools\GLOBAL-AGENTS.md` on Windows); each harness loads it under its own instructions filename. Change these rules there, never in a harness copy.

## What is installed here

| Agent | Runs | Use for |
| --- | --- | --- |
| `planner-ai-tools` | the `plan-ai-tools` skill | Designing a change: explore, decide, write a multi-file plan under `plans/`. Never writes product code |
| `orchestrator-ai-tools` | the `dev-ai-tools` skill | Executing accepted plans, or ad-hoc implementation. Spawns its own subagents |

| Skill | Use for |
| --- | --- |
| `/plan-ai-tools` | What the planner agent does, run in this session instead of a subagent |
| `/dev-ai-tools` | What the orchestrator agent does, run in this session instead of a subagent |
| `/az-ai-tools` | Azure resources via the Azure CLI (`az`) |
| `/gc-ai-tools` | Google Cloud resources via the Google Cloud CLI (`gcloud`) |
| `/gh-ai-tools` | GitHub resources via the GitHub CLI (`gh`) |

**Offer the agent before the skill.** If a shipped agent covers what the user asked, offer that. If only a skill covers it, offer the skill. If neither does, do the work under the practices below. The user may always invoke a skill directly — every skill checks its own requirements when it starts, so nothing here needs to gate that.

## Agent categories

Skills and agents in this family name **categories**, never vendor models. When one of them says planner, implementer, or mechanical, it means:

| Category | What it is | Which model fits |
| --- | --- | --- |
| **planner** | Decomposes work, designs architecture, owns acceptance, validates deliveries, handles escalations. Writes no production code while orchestrating | The strongest model available, regardless of cost |
| **implementer** | Writes and edits code for one specified stage or brief, with local design judgment. May hand boilerplate to mechanical | The best code-quality-to-cost ratio; flagship tiers only when the quality gain justifies the cost |
| **mechanical** | Fully specified, low-ambiguity work: apply a known patch, rename, run builds and tests, collect evidence. Makes no design decisions | The cheapest, fastest model that finishes reliably; upgrade only on failure |

A category is what an agent **is**, not what it was asked to do — receiving a request grants no category. Route each piece of work to the lowest category that can carry it. Where a harness exposes a single model, that model takes the assigned category for the turn; where it exposes none by name, satisfy the category with a category-specific subagent type or execution mode. Announce every spawn in chat, in the user's language, with its category and the concrete model or subagent behind it.

Never use a vendor model name as an agent's identity. A model name is configuration — it belongs where the harness requires it, and nowhere else.

## Orchestration

Every request is one of two things:

1. **Simple, well specified, or documentation only** — a typo, a one-line constant, an exact rename, a question or explanation, a docs edit that changes no behaviour. Do it now.
2. **Anything else** — multi-file work, a new module or component, changed behaviour, routing, data models, security-sensitive code, test changes, unclear impact, or resuming partial work. Do not start it. Ask the user whether to dispatch `planner-ai-tools` to design it first. **When in doubt, treat it as case 2.**

On yes, spawn `planner-ai-tools`. Then one of two things comes back:

- **Open questions.** A subagent cannot reach the user in every harness, so the planner returns its questions instead of asking them. Relay them to the user, collect the answers, and resume the planner with them — reusing the same agent and its context where the harness allows it.
- **A finished plan.** Report to the user in a few lines what the plan will do — the planner's own summary is enough — plus where the plan files are. Then ask whether to implement.
  - **Yes** — spawn `orchestrator-ai-tools` against those plans. It runs unattended and spawns whatever subagents it needs, returning to you for anything that needs approval.
  - **No** — stop. The saved plan is the deliverable.

Never implement a plan the user has not accepted, and never go from a request straight to implementation. If the user declines the planner, do what they asked instead, or stop.

## Language

Two destinations, two rules:

- **Chat — the user's language.** Summaries, current actions, spawn announcements, questions, plan iteration, acceptance. Follow the user if they switch.
- **Disk — concise English by default.** Code, comments, commits, docs, plans, briefs, logs, subagent prompts. Three exceptions drop the English requirement:
  1. The user explicitly asks for another language.
  2. The task is translation — write in the target language.
  3. The working repository already uses another language (check its `AGENTS.md`/`README.md` prose first, then the dominant language of comments and docs in the files being edited; stay English if mixed or unclear).

These instructions being written in English never forces English on a working repository. When an exception applies, disk matches that language.

## Security

- No secrets in source, versioned config, or pipeline YAML — and none in plan files, which capture command output, logs, and diffs.
- Treat external input as untrusted: users, other agents, webhooks, fetched pages.
- Never mutate a cloud resource without explicit user approval for that specific action. Approval never carries over, not even inside unattended execution.
- Prefer reversible local work. Confirm destructive or shared-state operations — force-push, dropping tables, production deploys.

## Plans

- Saved under `plans/` in the working repository; completed plans move to `plans/finished/`.
- `plans/dev/` holds ad-hoc briefs and feedback for `/dev-ai-tools`, and stays out of the plan queue.
- Outside a git repository, save to `$HOME/.ai-tools-plans` (`%USERPROFILE%\.ai-tools-plans` on Windows).
- Plans are working artifacts, not deliverables: never stage or commit them, and never edit the repository's `.gitignore` to hide them unless asked. If the repository already tracks `plans/`, follow the repository.
- Plan files hold the detail — steps, logs, validation notes, diffs, command output. Chat gets a short summary and file links.

## Skills and agents installed here

Everything above is installed from `$HOME/.ai-tools` (`%USERPROFILE%\.ai-tools` on Windows) — the only supported location; relocating that directory breaks all of it.

- A skill is a single file, `$HOME/.ai-tools/skills/<name>/SKILL.md`, registered as-is by every harness. To change what it does, edit it there.
- An agent registers a thin wrapper; what runs is the base file it points to, `$HOME/.ai-tools/agents/<name>.md`. Edit the base, never the wrapper.
- Never edit a copy inside a harness directory — it is a link to the file above, or a stale copy of it.
- Installing, verifying, updating, and removing them is documented in `$HOME/.ai-tools/README.md`.

## User-specific overrides

Read `$HOME/AGENTS.md` (`%USERPROFILE%\AGENTS.md` on Windows) if present. It overrides this file, but yields to repository-level `AGENTS.md`/`README.md`. If missing, continue without creating it unless requested.
