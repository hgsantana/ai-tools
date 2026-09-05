---
name: az-ai-tools
description: >
  Query or manage Azure resources, subscriptions, costs, and infrastructure
  through the Azure CLI (az). Use for /az-ai-tools. Impact: mutations may
  create billable resources or remove resources and can be hard to reverse.
  Reads run freely; each mutation requires explicit approval. Agent:
  implementer-ai-tools.
argument-hint: "[what to inspect or change in Azure]"
---

<skill name="az-ai-tools">
  <overview>
    Inventory, cost analysis, and management of Azure resources through the Azure CLI (`az`).
    Session handles user approvals and mutation guardrails, delegating CLI exploration as needed.
  </overview>

  <session_workflow>
    <step id="1" name="intake">
      Parse requested Azure inventory, cost analysis, or management operation.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Account and subscription: `az account show`, `az account list`.
      - Inventory and groups: `az resource list`, `az group list`.
      - Resources: `az <service> list`, `az <service> show`.
      - Cost and metrics: `az consumption usage list`, `az costmanagement query`, `az monitor`.
      Prefer `--output table` or `--query` (JMESPath) for concise outputs.
      Optionally dispatch `mechanical-ai-tools` using `<template role="mechanical-discovery">` from `<dispatch_templates>` for bulk log or fact collection.
    </step>

    <step id="3" name="mutation_guardrail">
      Identify if the operation involves mutating or deleting resources or creating billable services.
      Present every mutation as an explicit approval request to the user:
      - State exact command, target resource/group, reason, and estimated cost/blast-radius impact.
      - Execute only after explicit affirmative user approval.
    </step>

    <step id="4" name="report">
      Write detailed inventories, cost breakdowns, and operation logs to `dev/tmp/<topic>.md`.
      In chat (user's language), provide the direct answer, the report path, and any pending approval request.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery">
      <role>Mechanical worker: run read-only az commands and collect output.</role>
      <input>
        <commands>{COMMANDS}</commands>
        <output_file>dev/tmp/{TOPIC}.md</output_file>
      </input>
      <instructions>
        Execute the listed read-only az queries.
        Write formatted command outputs to {OUTPUT_FILE}.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule>Read-only queries run freely; every mutation requires separate user approval.</rule>
    <rule>State cost impact (SKU, ongoing cost, billable status) before any resource creation.</rule>
    <rule>Save large outputs and logs to dev/tmp/ rather than flooding session context.</rule>
  </boundaries>
</skill>
