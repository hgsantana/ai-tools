---
name: update-ai-tools
description: >
  Update an existing installation per the README: remove current-version
  artifacts, reset $HOME/.ai-tools to origin/master, and install from the
  fresh tree. Use for /update-ai-tools. Impact: can discard local commits
  and edits, and refreshes harness configuration. Each destructive step
  requires explicit approval. Agent: session.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

<skill name="update-ai-tools">
  <overview>
    Run the update procedure for an existing ai-tools installation (README.md#update):
    remove current artifacts, reset clone to origin/master, and install from fresh tree.
  </overview>

  <session_workflow>
    <step id="1" name="scope_and_intake">
      Ask user which harnesses and flags are in scope.
      Pass answer as `--harnesses {HARNESS_LIST}` (or "all" for all supported harnesses).
    </step>

    <step id="2" name="dry_run">
      Spawn `<template role="script-runner">` from `<dispatch_templates>` with {FLAGS} set to `--dry-run` plus the scoped flags and {LOG_PATH} set to `dev/tmp/update-dry-run.log`.
      Present each required destructive flag (`--overwrite`, `--discard-local`) separately with what it discards and why.
    </step>

    <step id="3" name="execution">
      Spawn `<template role="script-runner">` with {FLAGS} set to exactly the approved flags and {LOG_PATH} set to `dev/tmp/update-execution.log`.
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
    </step>

    <step id="4" name="report">
      Write `dev/tmp/update-report.md` with exact invocations, results, and tree status.
      In chat (user's language), provide the report path, outcome, and reminder to restart harnesses that cache skills.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="script-runner" executor="default-worker">
      <job>Default worker: execute the update shell script and capture output.</job>
      <input>
        <script>scripts/shell/update.sh</script>
        <flags>{FLAGS}</flags>
        <log_path>{LOG_PATH}</log_path>
      </input>
      <instructions>
        Run scripts/shell/update.sh with {FLAGS}.
        Record complete stdout and stderr to {LOG_PATH}.
        Return exit code and log path.
      </instructions>
      <constraints>
        <constraint>Run exactly the given flags; add no destructive flag.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="scope-roots">Touch only $AI_TOOLS and declared harness destination roots.</rule>
    <rule id="home-agents-untouched">Never touch $HOME/AGENTS.md.</rule>
    <rule id="separate-approvals">Destructive steps require explicit separate approval; never bypass safety flags.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` through the harness's native subagent API (Claude Code Agent, Copilot runSubagent, Codex spawn_agent, Grok task, Antigravity invoke_subagent, Cursor TaskSubagent) with its default agent type and model, passing the populated payload and file paths, never conversation context. Builds, test suites, script runs, and bulk fact collection go there; a single pinpoint command the session needs for its next decision runs in the session. If spawning fails, run the payload in the session and state that in the report.</rule>
  </boundaries>
</skill>
