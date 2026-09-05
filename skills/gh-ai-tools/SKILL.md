---
name: gh-ai-tools
description: >
  Query or manage GitHub accounts, administration, environments, Actions,
  issues, and releases through the GitHub CLI (gh). Use for /gh-ai-tools;
  handle repository code work directly. Impact: remote mutations can change
  access, settings, automation, or hosted data. Reads run freely; each mutation
  requires explicit approval. Agent: implementer-ai-tools.
argument-hint: "[GitHub platform resource to inspect or manage]"
---

<skill name="gh-ai-tools">
  <overview>
    Manage GitHub-hosted resources and platform configuration through the GitHub CLI (`gh`).
    Repository code work (commits, branches, PR delivery) runs directly in session; platform administration is managed here.
  </overview>

  <session_workflow>
    <step id="1" name="scope_and_intake">
      Verify request falls under platform administration:
      - Accounts, organizations, collaborators, team permissions.
      - Repository settings, visibility, rulesets, branch protection policies.
      - Actions workflows, runs, artifacts, caches, environments, secrets, variables.
      - Issues, discussions, releases, packages.
      Note: repository code work (git commits, rebases, merges, pushes, code reviews) bypasses this skill and runs directly in session.
    </step>

    <step id="2" name="read_exploration">
      Run read-only platform queries freely:
      - `gh auth status`, `gh api user`.
      - `gh repo view`, `gh api repos/<owner>/<repo>`.
      - `gh api orgs/<org>`, `gh api teams/<team>`.
      - `gh secret`, `gh variable`, `gh api .../environments`.
      - `gh workflow`, `gh run`, `gh cache`.
      - `gh issue`, `gh release`, `gh api <endpoint>`.
      Optionally dispatch `mechanical-ai-tools` using `<template role="mechanical-discovery">` from `<dispatch_templates>` for bulk fact collection.
    </step>

    <step id="3" name="mutation_guardrail">
      Present every remote mutation as a separate approval request to the user:
      - State command, target resource, reason, and blast impact.
      - For actions affecting others' access or automation, state the outcome and audience.
      - Execute only after explicit affirmative approval.
    </step>

    <step id="4" name="report">
      Write detailed inventories, logs, and listings to `dev/tmp/<topic>.md`.
      In chat (user's language), provide the direct answer, the report path, and any pending approval request.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery">
      <role>Mechanical worker: run read-only gh CLI commands and collect output.</role>
      <input>
        <commands>{COMMANDS}</commands>
        <output_file>dev/tmp/{TOPIC}.md</output_file>
      </input>
      <instructions>
        Execute the listed read-only gh queries.
        Save formatted command outputs to {OUTPUT_FILE}.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule>Read-only queries run freely; remote mutations require explicit approval.</rule>
    <rule>Repository code work bypasses this skill and executes directly under repository instructions.</rule>
    <rule>Save large outputs and logs to dev/tmp/ rather than flooding session context.</rule>
  </boundaries>
</skill>
