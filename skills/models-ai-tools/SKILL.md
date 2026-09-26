---
name: models-ai-tools
description: >
  Inspect available models and configure preferred models per tier (junior,
  mid, senior) for installed CLI harnesses. Use for /models-ai-tools. Impact:
  writes local configuration to $HOME/.ai-tools/config.local.json; no
  repository code is modified. Agent: session.
argument-hint: "[optional harness name]"
---

<skill name="models-ai-tools">
  <overview>
    Inspect available models across supported CLI harnesses (`agy`, `claude`, `copilot`) and interactively configure preferred models for `junior`, `mid`, and `senior` agent tiers.
    Selections are persisted to `$HOME/.ai-tools/config.local.json` under `"models"`, allowing users to customize agent model dispatch without altering repository defaults in `config/agents.json`.
  </overview>

  <session_workflow>
    <step id="1" name="cli_detection">
      Parse optional request argument {HARNESS} (e.g. `agy`, `claude`, `copilot` or canonical keys `antigravity`, `claude-code`, `copilot`).
      Probe `PATH` for installed harness CLIs:
      - `agy` (Google Antigravity CLI)
      - `claude` (Claude Code CLI)
      - `copilot` (GitHub Copilot CLI)
      When {HARNESS} is provided, limit the workflow to that specific harness.
      If no supported CLI harness is detected on `PATH`, inform the user in chat and stop.
    </step>

    <step id="2" name="model_discovery">
      For each detected CLI harness, gather supported and known model identifiers:
      - Upfront static tables from harness skills:
        - `agy`: `gemini-3.8-flash`, `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.1-pro`, `claude-sonnet-4-6`, `claude-opus-4-6-thinking`, `gpt-oss-120b-medium`.
        - `claude`: `haiku`, `sonnet`, `opus`, `fable`.
        - `copilot`: `gpt-5.4`, `claude-sonnet-4-6`, `claude-opus-4-6`, `o3`, `o1`, `gemini-2.5-pro`, `auto`.
      - Baseline tier defaults from `config/agents.json`:
        - Antigravity: junior `gemini-3.8-flash`, mid `gemini-3.8-flash`, senior `gemini-3.1-pro`.
        - Claude Code: junior `haiku`, mid `sonnet`, senior `opus`.
        - Copilot: junior `gemini-2.5-pro`, mid `gpt-5.4`, senior `o3`.
      - Dynamic discovery queries:
        - Query read-only model lists when verification is needed (`agy models`, `claude --help`, `copilot --help`).
        - Send bulk discovery commands to `<template role="model-inspector">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="tier_configuration">
      Read existing `$HOME/.ai-tools/config.local.json` if present to load previously chosen model preferences.
      For each detected harness, prompt the user via USER-AGENTS `<user_interaction>` to select the preferred model for each agent tier (`junior`, `mid`, `senior`):
      - Offer discovered options with the current setting or `config/agents.json` default marked as recommended.
      - Allow the user to select or confirm reasoning effort tiers (`low`, `medium`, `high`, `default`) where supported.
    </step>

    <step id="4" name="persist_configuration">
      Read existing `$HOME/.ai-tools/config.local.json` or initialize a new object if missing.
      Merge the configured tier models under the `"models"` top-level key:
      ```json
      {
        "models": {
          "{HARNESS}": {
            "junior": { "model": "{JUNIOR_MODEL}", "effort": "{JUNIOR_EFFORT}" },
            "mid": { "model": "{MID_MODEL}", "effort": "{MID_EFFORT}" },
            "senior": { "model": "{SENIOR_MODEL}", "effort": "{SENIOR_EFFORT}" }
          }
        }
      }
      ```
      Write the resulting configuration to `$HOME/.ai-tools/config.local.json`.
    </step>

    <step id="5" name="report">
      In chat (user's language), provide the concise confirmation:
      - Markdown table displaying configured tiers, models, and reasoning effort for each harness.
      - Absolute path to `$HOME/.ai-tools/config.local.json`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="model-inspector" executor="default-worker">
      <job>Default worker: run read-only model discovery CLI queries and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only discovery queries listed in {COMMANDS}.
        Write formatted command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="local-config-only">Writes solely to $HOME/.ai-tools/config.local.json; never modifies repository code, commits, or tracked files.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or question. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
