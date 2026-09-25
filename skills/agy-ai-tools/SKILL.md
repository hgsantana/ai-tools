---
name: agy-ai-tools
description: >
  Dispatch autonomous coding, analysis, and execution tasks to the Antigravity
  CLI (agy) with explicit model and reasoning effort control. Use for
  /agy-ai-tools or targeted model/effort tasks. Impact: executes local CLI tasks
  that can modify workspace files and consume model quota; destructive actions
  require explicit approval. Agent: session.
argument-hint: "[[model] [effort] | [effort]] <task description>"
---

<skill name="agy-ai-tools">
  <overview>
    Dispatch autonomous coding, analysis, and execution tasks through the Antigravity CLI (`agy`),
    enabling explicit control over model family and reasoning effort tier.
    Session resolves arguments and executes tasks, sending model discovery and log collection to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_parameter_resolution">
      Parse request arguments to resolve {MODEL}, {EFFORT}, and {TASK_PROMPT}. Derive a kebab-case {TOPIC}.
      Resolution rules:
      - Only effort specified: model defaults to `gemini-3.8-flash` with the requested effort (e.g. `high` -> `gemini-3.8-flash`, `high`).
      - Model aliases: `flash` / `flash-3.8` -> `gemini-3.8-flash`, `flash-3.7` -> `gemini-3.7-flash`, `flash-3.6` -> `gemini-3.6-flash`, `pro` / `pro-3.1` -> `gemini-3.1-pro`, `sonnet` -> `claude-sonnet-4-6`, `opus` -> `claude-opus-4-6-thinking`, `gpt-oss` -> `gpt-oss-120b-medium`.
      - Effort aliases: `low` -> `low`, `medium` / `med` -> `medium`, `high` / `hi` -> `high`.
      - Defaults when omitted: model `gemini-3.8-flash`, effort `medium`.
      - Workspace directory: resolve via `git rev-parse --show-toplevel` or `.`.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Model and effort availability: `agy models`.
      - CLI version and status: `agy --version`.
      Send bulk model discovery and CLI inspection to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="execution_guardrail">
      Verify if the requested task involves destructive operations (e.g. dropping database tables, force-pushing, removing uncommitted work).
      Present every destructive action as an explicit approval request to the user per USER-AGENTS `<security_guardrails>`:
      - State exact command, scope of change, reason, and blast-radius impact.
      - Execute only after explicit affirmative user approval.
    </step>

    <step id="4" name="command_execution">
      Construct the portable `agy` invocation:
      ```bash
      agy --model "{MODEL}" --effort "{EFFORT}" --add-dir "." --dangerously-skip-permissions -p "{CLEAN_PROMPT}"
      ```
      Execute via `run_command` in the workspace root.
      Save CLI execution output, session transcripts, and run details to `dev/tmp/{TOPIC}.md`.
    </step>

    <step id="5" name="report">
      Write detailed CLI execution transcripts, modified files inventory, and diagnostic output to `dev/tmp/{TOPIC}.md`.
      In chat (user's language), provide the concise outcome:
      - Model and reasoning effort used.
      - Status and summary of completed work.
      - Clickable links to created or modified files.
      - Path to the detailed report `dev/tmp/{TOPIC}.md`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only agy commands and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only agy queries listed in {COMMANDS}.
        Write formatted command outputs to dev/tmp/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="portability">Invoke agy from PATH or fallback to ~/.local/bin/agy; never hardcode machine-specific paths.</rule>
    <rule id="token-economy">Reference repository paths directly; avoid dumping large file contents into command prompts.</rule>
    <rule id="unbiased-reasoning">State goals and constraints plainly; allow the effort parameter to regulate thinking depth naturally.</rule>
    <rule id="destructive-guardrail">Destructive operations require explicit affirmative user approval before execution.</rule>
    <rule id="outputs-on-disk">Save command outputs, run transcripts, and logs to dev/tmp/ rather than flooding session context.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
