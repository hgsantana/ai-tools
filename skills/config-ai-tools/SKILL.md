---
name: config-ai-tools
description: >
  Configure global ai-tools behavior: default CLI and implementer model prompts.
  Use for /config-ai-tools. Impact: updates $HOME/.ai-tools/config.local.json;
  code remains unchanged. Agent: session.
argument-hint: "[setting to configure]"
---

<skill name="config-ai-tools">
  <overview>
    Configure global ai-tools behavioral preferences, including preferred default CLI harness and implementer model prompting for autonomous workflow skills (`vibe-ai-tools`, `campaign-ai-tools`).
    Preferences persist to `$HOME/.ai-tools/config.local.json` under `"behavior"`.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_interview">
      Read existing `$HOME/.ai-tools/config.local.json` if present to load current `"behavior"` preferences:
      - `default_cli` (default `agy` or first detected harness): preferred CLI harness (`agy`, `claude`, `copilot`).
      - `ask_implementer_model` (default `true`): whether skills like `vibe-ai-tools` and `campaign-ai-tools` prompt the user for an implementer model or use pre-configured defaults directly.
      Parse optional request argument {SETTING} to focus configuration on a single preference if provided.
      Interview the user through USER-AGENTS `<user_interaction>` on settings to configure, offering current or recommended defaults:
      1. Preferred CLI harness: `agy` (Google Antigravity), `claude` (Claude Code), or `copilot` (GitHub Copilot).
      2. Implementer model prompt: ask for model each run (`true`, recommended) or use configured defaults directly (`false`).
    </step>

    <step id="2" name="persist_settings">
      Read existing `$HOME/.ai-tools/config.local.json` or initialize a new JSON object if missing.
      Merge the configured behavioral settings under the `"behavior"` top-level key:
      ```json
      {
        "behavior": {
          "default_cli": "agy",
          "ask_implementer_model": true
        }
      }
      ```
      Write the resulting configuration to `$HOME/.ai-tools/config.local.json`.
    </step>

    <step id="3" name="report">
      In chat (user's language), provide the concise confirmation:
      - Summary table of active behavioral preferences (`default_cli`, `ask_implementer_model`).
      - Absolute path to `$HOME/.ai-tools/config.local.json`.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="config-verifier" executor="default-worker">
      <job>Default worker: verify configuration json validity.</job>
      <input>
        <config_path>{CONFIG_PATH}</config_path>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Validate that {CONFIG_PATH} contains valid JSON.
        Write execution log to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return exit code and log path.
      </instructions>
      <constraints>
        <constraint>Read-only check; leave files unchanged.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="local-config-only">Writes solely to $HOME/.ai-tools/config.local.json; never modifies repository code, commits, or tracked files.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or question. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
