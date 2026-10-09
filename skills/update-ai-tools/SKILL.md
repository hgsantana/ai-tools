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
      Resolve canonical clone `$HOME/.ai-tools` (Windows: `%USERPROFILE%\.ai-tools`); abort if missing.
      Run dry-run in session: `"$HOME/.ai-tools/scripts/shell/update.sh" --dry-run --overwrite --harnesses all --discard-local`.
      Present dry-run report (discarded local work, overwritten or pruned harness artifacts) and ask user via `<user_interaction>` whether to proceed and run for real. Abort if refused.
    </step>

    <step id="2" name="execute">
      Run update in session: `"$HOME/.ai-tools/scripts/shell/update.sh" --overwrite --harnesses all --discard-local`.
      Present execution report with outcome and reminder to restart harnesses that cache skills.
    </step>
  </session_workflow>

  <dispatch_templates>
  </dispatch_templates>

  <boundaries>
    <rule id="scope-roots">Touch only $AI_TOOLS and declared harness destination roots.</rule>
    <rule id="canonical-script">Resolve `$HOME/.ai-tools` first and invoke `"$HOME/.ai-tools/scripts/shell/update.sh"`; do not run a relative `scripts/shell/update.sh` from the caller's project.</rule>
    <rule id="home-agents-untouched">Never touch $HOME/.ai-tools/USER-AGENTS.md.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="separate-approvals">Destructive steps require explicit separate approval; never bypass safety flags.</rule>
  </boundaries>
</skill>
