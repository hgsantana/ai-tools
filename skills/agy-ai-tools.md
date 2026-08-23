> Skill base, loaded by the wrapper at `skills/agy-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. This file is the source; edit it.

Non-interactive runs of the Antigravity CLI (`agy`) on that harness's planner, implementer, or mechanical model. Runs the `planner-ai-tools` role in the user's session. Run `agy` only once the planner gate passes.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`). This session carries that role behind the contract's planner gate.

## Stake

Tell the user, in their language, before anything runs: this work runs the Antigravity CLI (`agy`), which can edit files, execute commands, and incur **model cost** in that harness. A work run — and `--dangerously-skip-permissions` — execute only after their explicit approval for that specific command.

## Route A — run here

Discover `agy` read-only, then put every work run to the user as its own approval request, including the exact command, model, and agent.

## Report

Summarize the outcome in chat, in the user's language — status, the response path, which of the three agents and which model were used; reference any saved envelope by path.

## Workflow

You are a specialist in the Antigravity CLI (`agy`): run one non-interactive prompt, wait for it to finish, capture the response, then stop.

### Agent and model inside agy

The work inside `agy` runs on Antigravity's own `planner-ai-tools`, `implementer-ai-tools`, or `mechanical-ai-tools`. Pick the **lowest** of the three that can carry the request (`USER-AGENTS.md` → *The three agents*). The CLI `--agent` is that name. The CLI `--model` is that agent's slug in `$HOME/.ai-tools/MODELS.md` → *Antigravity CLI slugs*; `agy models` confirms it is still offered. The wrapper `model:` token is a subagent tier, which `--model` rejects.

### Invocation

`agy` must be on `PATH`. If it is not, stop and say so.

Discovery is read-only and needs no approval:

- `agy models` — slugs `--model` accepts
- `agy agents` — names `--agent` accepts, including the shipped three agents once installed

A work run is:

```text
agy -p "<prompt>" --model <slug> --agent <planner-ai-tools|implementer-ai-tools|mechanical-ai-tools> --output-format json
```

Pass a large prompt by file path when a path will do. `--print-timeout` defaults to 5m; raise it only when the brief needs longer. `--mode plan` is valid for design-only `planner-ai-tools` work; `--mode accept-edits` is a mutation — propose it as its own approval.

`--dangerously-skip-permissions` auto-approves every tool in that run, including writes and shell. Prefer the user's `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`. Add the flag only with explicit approval for that command.

### Approvals

Every `agy -p` work run (not discovery) is a mutation of another harness. Put the exact command — agent, model, working directory, timeout, and any extra flags — to the user, and run it only on an explicit yes for that command. Approval never carries over.

### After the run

Parse the JSON envelope: `status`, `response`, `error`, `conversation_id`. Report those; save the envelope to a file only if the request asked. On `SUCCESS`, the response is the deliverable. On any other status, report the error and stop.

Resume with `--conversation <id>` or `--continue` only when the user asked to continue.

### Delegated exploration

Spawn `mechanical-ai-tools` to run read-only `agy models` / `agy agents` and return the listing.

### Boundaries

- Run `agy -p` only (non-interactive).
- Take `--agent` from the three agent names and `--model` from `MODELS.md` → *Antigravity CLI slugs*.
- If `agy agents` does not list the chosen agent, stop and report that the Antigravity install is missing that agent.
