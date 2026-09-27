---
name: copilot-ai-tools
description: >
  Dispatch autonomous subagents to the GitHub Copilot CLI (copilot) for coding,
  analysis, and execution tasks with explicit model and reasoning effort
  control. Use for /copilot-ai-tools or targeted model/effort tasks. Impact:
  executes local CLI subagents that can modify workspace files and consume model
  quota; destructive actions require explicit approval. Agent: session.
argument-hint: "[[model] [effort] | [effort]] <task description>"
---

<skill name="copilot-ai-tools">
  <overview>
    Dispatch autonomous subagents through the GitHub Copilot CLI (`copilot`) for coding, analysis, and execution tasks,
    enabling explicit control over model family and reasoning effort tier.
    Session resolves arguments and executes subagents, sending model discovery and log collection to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_parameter_resolution">
      Parse request arguments to resolve {MODEL}, {EFFORT}, and {TASK_PROMPT}. Derive a kebab-case {TOPIC}.
      Supported models:
      | Model | Aliases |
      |---|---|
      | `gpt-5.4` | `gpt`, `gpt-5` |
      | `claude-sonnet-4-6` | `claude`, `sonnet` |
      | `claude-opus-4-6` | `opus` |
      | `o3` | `o3` |
      | `o1` | `o1` |
      | `gemini-2.5-pro` | `gemini` |
      | `auto` | `auto` |

      Resolution rules:
      - Only effort specified: model defaults to `gpt-5.4` with the requested effort (e.g. `high` -> `gpt-5.4`, `high`).
      - Model aliases: `claude` / `sonnet` -> `claude-sonnet-4-6`, `opus` -> `claude-opus-4-6`, `gpt` / `gpt-5` -> `gpt-5.4`, `o3` -> `o3`, `o1` -> `o1`, `gemini` -> `gemini-2.5-pro`, `auto` -> `auto`, or full model names.
      - Effort aliases: `none` -> `none`, `minimal` / `min` -> `minimal`, `low` -> `low`, `medium` / `med` -> `medium`, `high` / `hi` -> `high`, `xhigh` / `extra-high` -> `xhigh`, `max` -> `max`.
      - Defaults when omitted: model `gpt-5.4`, effort `medium`.
      - Dynamic fallback: inspect `copilot --help` or probe flags before rejecting unrecognized model inputs.
      - Workspace directory: resolve via `git rev-parse --show-toplevel` or `.`.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Model and CLI options: `copilot --help`.
      - CLI version and status: `copilot --version`.
      Send bulk model discovery and CLI inspection to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="execution_guardrail">
      Verify if the requested task involves destructive operations (e.g. dropping database tables, force-pushing, removing uncommitted work).
      Present every destructive action as an explicit approval request to the user per `<security_guardrails>`:
      - State exact command, scope of change, reason, and blast-radius impact.
      - Execute only after explicit affirmative user approval.
    </step>

    <step id="4" name="command_execution">
      Construct the portable `copilot` invocation:
      ```bash
      copilot -p "{CLEAN_PROMPT}" --model "{MODEL}" --effort "{EFFORT}" --yolo
      ```
      Execute via `run_command` in the workspace root.
      Save CLI execution output, session transcripts, and run details to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`.
    </step>

    <step id="5" name="report">
      Write detailed CLI execution transcripts, modified files inventory, and diagnostic output to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`.
      In chat (user's language), provide the concise outcome:
      - Model and reasoning effort used.
      - Status and summary of completed work.
      - Clickable links to created or modified files.
      - Path to the detailed report `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only copilot commands and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only copilot queries listed in {COMMANDS}.
        Write formatted command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="portability">Invoke copilot from PATH or fallback to ~/.local/bin/copilot; never hardcode machine-specific paths.</rule>
    <rule id="token-economy">Reference repository paths directly; avoid dumping large file contents into command prompts.</rule>
    <rule id="unbiased-reasoning">State goals and constraints plainly; allow the effort parameter to regulate thinking depth naturally.</rule>
    <rule id="destructive-guardrail">Destructive operations require explicit affirmative user approval before execution.</rule>
    <rule id="outputs-on-disk">Save command outputs, run transcripts, and logs to ${TMPDIR:-/tmp}/ai-tools/ rather than flooding session context.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per `<execution_protocol>`, assembling nested payloads per `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
