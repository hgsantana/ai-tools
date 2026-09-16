---
name: remove-ai-tools
description: >
  Remove this installation per the README: remove skills and optionally
  instructions from harnesses. Use for /remove-ai-tools. Impact: those tools
  become unavailable; the clone remains unless the user separately approves a
  purge. Each destructive step requires explicit approval. Agent: session.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

<skill name="remove-ai-tools">
  <overview>
    Remove installed ai-tools artifacts from selected harnesses (README.md#removal),
    preserving the repository clone unless explicitly purged.
  </overview>

  <session_workflow>
    <step id="1" name="scope_and_intake">
      Ask user which harnesses and flags are in scope.
      Pass answer as `--harnesses {HARNESS_LIST}` (or "all" for all supported harnesses).
    </step>

    <step id="2" name="dry_run">
      Resolve the canonical clone as `$HOME/.ai-tools` (Windows: `%USERPROFILE%\.ai-tools`). Refuse if that path is missing or is not the supported clone.
      If `--purge` is in scope, select a surviving report directory outside the clone before any run: `$HOME/.ai-tools-remove-logs` (create if absent). Otherwise use the clone's `dev/tmp/`. Record that absolute directory as {REPORT_DIR}.
      Spawn `<template role="script-runner">` from `<dispatch_templates>` with {SCRIPT} set to the quoted absolute `"$HOME/.ai-tools/scripts/shell/remove.sh"`, {FLAGS} set to `--dry-run` plus the scoped flags, and {LOG_PATH} set to `{REPORT_DIR}/remove-dry-run.log`.
      Present each destructive flag (`--instructions`, `--force`, `--purge`) separately with what it removes and why.
    </step>

    <step id="3" name="execution">
      Spawn `<template role="script-runner">` with {SCRIPT} set to the same quoted absolute path, {FLAGS} set to exactly the approved flags, and {LOG_PATH} set to `{REPORT_DIR}/remove-execution.log`.
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
    </step>

    <step id="4" name="report">
      Write `{REPORT_DIR}/remove-report.md` with exact invocations, results, tree status, and the surviving report directory. Do not recreate the clone after an approved purge.
      In chat (user's language), provide the report path, outcome, and reminder to restart harnesses.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="script-runner" executor="default-worker">
      <job>Default worker: execute the remove shell script and capture output.</job>
      <input>
        <script>{SCRIPT}</script>
        <flags>{FLAGS}</flags>
        <log_path>{LOG_PATH}</log_path>
      </input>
      <instructions>
        Run the quoted absolute {SCRIPT} with {FLAGS}. Do not change directory to the caller's project.
        Record complete stdout and stderr to {LOG_PATH}.
        Return exit code and log path.
      </instructions>
      <constraints>
        <constraint>Run exactly the given flags; add no destructive flag.</constraint>
        <constraint>Invoke only the canonical clone script path supplied as {SCRIPT}.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="scope-roots">Touch only $AI_TOOLS and declared harness destination roots, except the surviving purge-report directory in `<rule id="surviving-reports">`.</rule>
    <rule id="canonical-script">Resolve `$HOME/.ai-tools` first and invoke `"$HOME/.ai-tools/scripts/shell/remove.sh"`; do not run a relative `scripts/shell/remove.sh` from the caller's project.</rule>
    <rule id="surviving-reports">When `--purge` is approved, write dry-run, execution, and final reports under `$HOME/.ai-tools-remove-logs` and never recreate the clone to store them. That directory is the only write outside the clone and harness roots, and only for purge evidence.</rule>
    <rule id="home-agents-untouched">Never touch $HOME/AGENTS.md.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="separate-approvals">Destructive steps require explicit separate approval; never bypass safety flags.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
