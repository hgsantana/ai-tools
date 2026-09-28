---
name: claude-ai-tools
description: >
  Dispatch a Claude Code agent by tier (junior, mid, senior) or explicit model
  and effort, via the claude CLI or else the harness subagent API. Use for
  /claude-ai-tools or as the mid implementer of plan stages. Impact: runs
  agents that can modify workspace files, commit, and consume model quota;
  destructive actions require explicit approval. Agent: session.
argument-hint: "[tier | [model] [effort]] <task description>"
---

<skill name="claude-ai-tools">
  <overview>
    Dispatch one Claude Code agent, from a clean context, on the model and effort of a tier or of the request.
  </overview>

  <session_workflow>
    <step id="1" name="resolve">
      Resolve {MODEL}, {EFFORT}, and {TASK_PROMPT}; derive kebab-case {TOPIC}. A tier maps through this table; an explicit model or effort overrides it; nothing given selects `mid`.
      | Tier | Model | Effort |
      |---|---|---|
      | `junior` | `haiku` | `medium` |
      | `mid` | `sonnet` | `medium` |
      | `senior` | `opus` | `high` |
      Models: `haiku`, `sonnet`, `opus`, `fable`, or a full identifier; check an unknown one against `claude --help` before rejecting. Efforts: `low`, `medium` (`med`), `high` (`hi`), `xhigh`, `max`.
    </step>

    <step id="2" name="guardrail">
      Present each destructive action in the task as an explicit approval request per `<security_guardrails>`, stating command, scope, reason, and blast radius; run it only after approval.
    </step>

    <step id="3" name="dispatch">
      From the workspace root (`git rev-parse --show-toplevel`, else `.`), use the first level available, saving output to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`:
      1. CLI: execute directly assuming it exists (no pre-checks). If command is not found (exit 127), search PATH, `~/.local/bin/claude`, or `which claude` and retry with the resolved path; advance to level 2 only if missing: `claude -p "{TASK_PROMPT}" --model "{MODEL}" --effort "{EFFORT}" --dangerously-skip-permissions`.
      2. Harness API: without the CLI, spawn a subagent via the native API per `<rule id="native-spawn">`, setting {MODEL} and {EFFORT}.
      3. Closest match: when that API cannot set them, pick the nearest model and effort it offers.
      Send bulk CLI inspection to `<template role="mechanical-discovery">`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="4" name="report">
      In chat (user's language): dispatch level, model and effort used (naming any substitution), one-line outcome, changed files, and the output path.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only claude commands and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only claude queries listed in {COMMANDS}.
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
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
  </boundaries>
</skill>
