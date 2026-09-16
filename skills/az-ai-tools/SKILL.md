---
name: az-ai-tools
description: >
  Query or manage Azure resources, subscriptions, costs, and infrastructure
  through the Azure CLI (az). Use for /az-ai-tools. Impact: mutations may
  create billable resources or remove resources and can be hard to reverse.
  Reads run freely; each mutation requires explicit approval. Agent: session.
argument-hint: "[what to inspect or change in Azure]"
---

<skill name="az-ai-tools">
  <overview>
    Inventory, cost analysis, and management of Azure resources through the Azure CLI (`az`).
    Session handles user approvals and mutation guardrails, sending bulk CLI collection to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake">
      Parse requested Azure inventory, cost analysis, or management operation. Derive a kebab-case {TOPIC}.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Account and subscription: `az account show`, `az account list`.
      - Inventory and groups: `az resource list`, `az group list`.
      - Resources: `az {SERVICE} list`, `az {SERVICE} show`.
      - Cost and metrics: `az consumption usage list`, `az costmanagement query`, `az monitor`.
      Prefer `--output table` or `--query` (JMESPath) for concise outputs.
      Send bulk log or fact collection to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="mutation_guardrail">
      Identify if the operation involves mutating or deleting resources or creating billable services.
      Present every mutation as an explicit approval request to the user per USER-AGENTS `<security_guardrails>`:
      - State exact command, target resource/group, reason, and estimated cost/blast-radius impact.
      - Execute only after explicit affirmative user approval.
    </step>

    <step id="4" name="report">
      Write detailed inventories, cost breakdowns, and operation logs to `dev/tmp/{TOPIC}.md`.
      In chat (user's language), provide the direct answer, the report path, and any pending approval request.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only az commands and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only az queries listed in {COMMANDS}.
        Write formatted command outputs to dev/tmp/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="reads-free-mutations-approved">Read-only queries run freely; every mutation requires separate user approval.</rule>
    <rule id="state-cost">State cost impact (SKU, ongoing cost, billable status) before any resource creation.</rule>
    <rule id="outputs-on-disk">Save large outputs and logs to dev/tmp/ rather than flooding session context.</rule>
    <rule id="protocol-source">When USER-AGENTS `<execution_protocol>`, `<user_interaction>`, or `<security_guardrails>` are not already loaded, read `$HOME/.ai-tools/USER-AGENTS.md` before the first spawn or approval. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per USER-AGENTS `<execution_protocol>`, assembling nested payloads per USER-AGENTS `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
