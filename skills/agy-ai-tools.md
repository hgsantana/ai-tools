> Skill base, loaded by the wrapper at `skills/agy-ai-tools/SKILL.md`, which loads `skills/SKILL-CONTRACT.md` before it. Edit this file, never the wrapper.

Non-interactive runs of the Antigravity CLI (`agy`) on that harness's planner, implementer, or mechanical model. Dispatches `planner-ai-tools` to follow **Workflow**. Never run `agy` outside that dispatch.

## Agent

Agent: `planner-ai-tools`, base `$HOME/.ai-tools/agents/planner-ai-tools.md` (Windows: `%USERPROFILE%\.ai-tools\agents\planner-ai-tools.md`).

## Stake

Tell the user, in their language, before anything runs: this work runs the Antigravity CLI (`agy`), which can edit files, execute commands, and incur **model cost** in that harness. A work run — and `--dangerously-skip-permissions` — execute only after their explicit approval for that specific command.

## Route A — dispatch

The agent discovers `agy` read-only, then returns every work run for approval, including the exact command, model, and agent.

## Report

Summarize the outcome in chat, in the user's language — status, the response path, which of the three agents and which model were used; reference any saved envelope by path.

## Workflow

You are a specialist in the Antigravity CLI (`agy`): run one non-interactive prompt, wait for it to finish, capture the response, then stop.

### Agent and model inside agy

The work inside `agy` runs on Antigravity's own `planner-ai-tools`, `implementer-ai-tools`, or `mechanical-ai-tools` — never this session's. Pick the **lowest** of the three that can carry the request (`USER-AGENTS.md` → *The three agents*). The CLI `--agent` is that name. The CLI `--model` is the `model:` token in that agent's Antigravity wrapper (`$HOME/.ai-tools/agents/antigravity/<agent>.md`).

### Invocation

`agy` must be on `PATH`. If it is not, stop and say so — never invent a path or a substitute command.

Discovery is read-only and needs no approval:

- `agy models` — slugs `--model` accepts
- `agy agents` — names `--agent` accepts, including the shipped three agents once installed

A work run is:

```text
agy -p "<prompt>" --model <token> --agent <planner-ai-tools|implementer-ai-tools|mechanical-ai-tools> --output-format json
```

Pass a large prompt by file path when a path will do. `--print-timeout` defaults to 5m; raise it only when the brief needs longer. `--mode plan` is valid for design-only `planner-ai-tools` work; `--mode accept-edits` is a mutation — propose it as its own approval.

`--dangerously-skip-permissions` auto-approves every tool in that run, including writes and shell. Prefer the user's `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`. Never add the flag on your own judgement.

### Approvals

Every `agy -p` work run (not discovery) is a mutation of another harness. Put the exact command — agent, model, working directory, timeout, and any extra flags — to the user, and run it only on an explicit yes for that command. Approval never carries over.

### After the run

Parse the JSON envelope: `status`, `response`, `error`, `conversation_id`. Report those; save the envelope to a file only if the request asked. On `SUCCESS`, the response is the deliverable. On any other status, report the error and stop — never retry a different model on your own.

Resume with `--conversation <id>` or `--continue` only when the user asked to continue.

### Delegated exploration

You may spawn `mechanical-ai-tools` to run read-only `agy models` / `agy agents` and return the listing.

### Boundaries

- Never run `agy` interactively (`--prompt-interactive` / no `-p`).
- Never pick an agent above the lowest that can carry the work.
- Never invent `--model` or `--agent`; the three agent names and their Antigravity wrapper `model:` tokens are the only sources.
- If `agy agents` does not list the chosen agent, stop and report that the Antigravity install is missing that agent.
