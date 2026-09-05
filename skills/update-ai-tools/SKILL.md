---
name: update-ai-tools
description: >
  Update an existing installation per the README: remove current-version
  artifacts, reset $HOME/.ai-tools to origin/master, and install from the
  fresh tree. Use for /update-ai-tools. Impact: can discard local commits
  and edits, and refreshes harness configuration. Each destructive step
  requires explicit approval. Agent: mechanical-ai-tools.
argument-hint: "[optional: harnesses in scope, or extra instructions]"
---

<skill name="update-ai-tools">
  <overview>
    Run update procedure for an existing ai-tools installation per README:
    remove current artifacts, reset clone to origin/master, and install from fresh tree.
  </overview>

  <session_workflow>
    <step id="1" name="scope_and_intake">
      Ask user which harnesses and flags are in scope.
      Pass answer as `--harnesses <list>` (or "all" for all supported harnesses).
    </step>

    <step id="2" name="dry_run">
      Execute `scripts/shell/update.sh` with `--dry-run` and scoped flags.
      Save dry-run output to `dev/tmp/update-dry-run.log`.
      Present each required destructive flag (`--overwrite`, `--discard-local`) separately with what it discards and why.
    </step>

    <step id="3" name="execution">
      Execute `scripts/shell/update.sh` with exactly the approved flags.
      Exit 0: clean. Exit 2: report every WARN with reason. Exit 1: report precondition error.
    </step>

    <step id="4" name="report">
      Write `dev/tmp/update-report.md` with exact invocations, results, and tree status.
      In chat (user's language), provide the report path, outcome, and reminder to restart harnesses caching agents/skills.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-ai-tools">
      <role>Mechanical worker: execute update shell script and capture output.</role>
      <input>
        <script>scripts/shell/update.sh</script>
        <flags>{APPROVED_FLAGS}</flags>
      </input>
      <instructions>
        Run update script with approved flags.
        Record complete stdout and stderr to dev/tmp/update-execution.log.
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
