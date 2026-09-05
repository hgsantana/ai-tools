---
name: remove-ai-tools
description: >
  Remove this installation per the README: remove agents, skills, and
  optionally instructions from harnesses. Use for /remove-ai-tools. Impact:
  those tools become unavailable; the clone remains unless the user separately
  approves a purge. Each destructive step requires explicit approval. Agent:
  mechanical-ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

<skill name="remove-ai-tools">
  <overview>
    Remove installed ai-tools artifacts from selected harnesses per README procedure,
    preserving repository clone unless explicitly purged.
  </overview>

  <session_workflow>
    <step id="1" name="scope_and_intake">
      Ask user which harnesses and flags are in scope.
      Pass answer as `--harnesses <list>` (or "all" for all supported harnesses).
    </step>

    <step id="2" name="dry_run">
      Execute `scripts/shell/remove.sh` with `--dry-run` and scoped flags.
      Save output to `dev/tmp/remove-dry-run.log`.
      Present each destructive flag (`--instructions`, `--force`, `--purge`) separately with what it removes and why.
    </step>

    <step id="3" name="execution">
      Execute `scripts/shell/remove.sh` with exactly the approved flags (directly in session or delegating execution to `mechanical-ai-tools` using `<template role="mechanical-ai-tools">` from `<dispatch_templates>`).
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
    </step>

    <step id="4" name="report">
      Write `dev/tmp/remove-report.md` with exact invocations, results, and tree status.
      In chat (user's language), provide the report path, outcome, and reminder to restart harnesses.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-ai-tools">
      <role>Mechanical worker: execute remove shell script and capture output.</role>
      <input>
        <script>scripts/shell/remove.sh</script>
        <flags>{APPROVED_FLAGS}</flags>
      </input>
      <instructions>
        Run remove script with approved flags.
        Record complete stdout and stderr to dev/tmp/remove-execution.log.
        Return exit code and log path.
      </instructions>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule>Touch only $AI_TOOLS and declared harness destination roots.</rule>
    <rule>Never touch $HOME/AGENTS.md.</rule>
    <rule>Destructive steps require explicit separate approval; never bypass safety flags.</rule>
  </boundaries>
</skill>
