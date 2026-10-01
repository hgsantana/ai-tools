---
name: update-ai-tools
description: >
  Update the ai-tools installation across all harnesses: preview with dry-run,
  confirm destructive changes, and apply. Use for /update-ai-tools. Impact:
  discards local clone edits and commits, replaces conflicting artifacts, and
  refreshes harness config. Requires explicit confirmation. Agent: session.
---

<skill name="update-ai-tools">
  <overview>
    Run the update procedure for an existing ai-tools installation (README.md#update):
    preview changes with dry-run, confirm destructive impact, reset the clone,
    and install across all supported harnesses.
  </overview>

  <session_workflow>
    <step id="1" name="dry_run">
      Resolve the canonical clone as `$HOME/.ai-tools` (Windows: `%USERPROFILE%\.ai-tools`). Refuse if that path is missing or is not the supported clone.
      Use the OS temp directory `${TMPDIR:-/tmp}/ai-tools` as {REPORT_DIR}.
      Immediately spawn `<template role="script-runner">` from `<dispatch_templates>` without asking the user, setting {SCRIPT} to the quoted absolute `"$HOME/.ai-tools/scripts/shell/update.sh"`, {FLAGS} to `"--dry-run --overwrite --harnesses all --discard-local"`, and {LOG_PATH} to `{REPORT_DIR}/update-dry-run.log`.
    </step>

    <step id="2" name="confirm_destruction">
      From `{REPORT_DIR}/update-dry-run.log`, inspect and present what will be lost or overwritten:
      1. Discarded local clone work: uncommitted edits or commits ahead of origin/master in `$HOME/.ai-tools` discarded by `--discard-local`.
      2. Overwritten or pruned harness artifacts: conflicting or locally modified files replaced, and orphan artifacts pruned across all harnesses by `--overwrite`.
      Warn the user via `<user_interaction>` with the specific items that will be lost or replaced, and ask for confirmation to proceed. Abort if refused.
    </step>

    <step id="3" name="execution">
      Spawn `<template role="script-runner">` with {SCRIPT} set to the same quoted absolute path, {FLAGS} set to `"--overwrite --harnesses all --discard-local"`, and {LOG_PATH} set to `{REPORT_DIR}/update-execution.log`.
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
    </step>

    <step id="4" name="report">
      Write `{REPORT_DIR}/update-report_<year>-<month>-<day>_<hour>-<minutes>.md` (timestamped with the current date and time, e.g., `update-report_2026-09-26_23-55.md`) with exact invocations, results, and tree status.
      In chat (user's language), provide the report path, a one-line outcome of what was updated, and a reminder to restart harnesses that cache skills.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="script-runner" executor="default-worker">
      <job>Default worker: execute the update shell script and capture output.</job>
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
    <rule id="scope-roots">Touch only $AI_TOOLS and declared harness destination roots.</rule>
    <rule id="canonical-script">Resolve `$HOME/.ai-tools` first and invoke `"$HOME/.ai-tools/scripts/shell/update.sh"`; do not run a relative `scripts/shell/update.sh` from the caller's project.</rule>
    <rule id="home-agents-untouched">Never touch $HOME/AGENTS.md.</rule>
    <rule id="protocol-source">Follow user-wide `<execution_protocol>`, `<user_interaction>`, and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="separate-approvals">Destructive steps require explicit separate approval; never bypass safety flags.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per `<execution_protocol>`, assembling nested payloads per `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
