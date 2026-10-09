---
name: agy-ai-tools
description: >
  Dispatch an Antigravity agent by tier (junior, mid-level, senior) or explicit model
  and effort, via the agy CLI or the harness subagent API. Use for
  /agy-ai-tools to execute delegated coding, research, or operational tasks.
argument-hint: "[tier | [model] [effort]] <task description>"
---

<skill name="agy-ai-tools">
  <overview>
    Dispatch one Antigravity agent, from a clean context, on the model and effort of a tier or of the request.
  </overview>

  <session_workflow>
    <step id="1" name="resolve">
      Resolve {MODEL}, {EFFORT}, and {TASK_PROMPT}; derive kebab-case {TOPIC}. A tier maps through this table; an explicit model or effort overrides it; nothing given selects `mid-level`.
      | Tier | Model | Effort |
      |---|---|---|
      | `junior` | `gemini-3.8-flash` | `low` |
      | `mid-level` | `gemini-3.8-flash` | `medium` |
      | `senior` | `gemini-3.8-flash` | `high` |
      Models: `gemini-3.8-flash` (`flash`), `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.1-pro` (`pro`; low or high effort), `claude-sonnet-4-6` (`sonnet`), `claude-opus-4-6-thinking` (`opus`), `gpt-oss-120b-medium` (`gpt-oss`), or a full identifier; check an unknown one against `agy models` before rejecting. Efforts: `low`, `medium` (`med`), `high` (`hi`).
    </step>

    <step id="2" name="guardrail">
      Present each destructive action in the task as an explicit approval request per `<security_guardrails>`, stating command, scope, reason, and blast radius; run it only after approval.
    </step>

    <step id="3" name="dispatch">
      From the workspace root (`git rev-parse --show-toplevel`, else `.`), use the first level available, saving output to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`:
      1. CLI: execute directly assuming it exists (no pre-checks). If command is not found (exit 127), search PATH, `~/.local/bin/agy`, or `which agy` and retry with the resolved path; advance to level 2 only if missing: `agy --model "{MODEL}" --effort "{EFFORT}" --add-dir "." --dangerously-skip-permissions -p "{TASK_PROMPT}"`.
      2. Harness API: without the CLI, spawn a subagent via the native API per implement-ai-tools `<rule id="native-spawn">`, setting {MODEL} and {EFFORT}.
      3. Closest match: when that API cannot set them, pick the nearest model and effort it offers.
      Send bulk CLI inspection to `<template role="mechanical-discovery">`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="4" name="report">
      In chat (user's language): dispatch level, model and effort used (naming any substitution), one-line outcome, changed files, and the output path.
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
        Write formatted command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="token-economy">Pass repository paths in {TASK_PROMPT}, not file contents; state goals and constraints plainly and let the effort regulate depth.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`, and dispatch agents per implement-ai-tools `<harness_agents>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
  </boundaries>
</skill>
