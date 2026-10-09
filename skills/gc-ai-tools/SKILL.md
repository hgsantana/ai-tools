---
name: gc-ai-tools
description: >
  Query or manage Google Cloud resources, projects, costs, and infrastructure
  through the gcloud CLI. Use for /gc-ai-tools.
argument-hint: "[what to inspect or change in Google Cloud]"
---

<skill name="gc-ai-tools">
  <overview>
    Inventory, cost analysis, and management of Google Cloud resources through the `gcloud` CLI.
    Session handles user approvals and mutation guardrails, sending bulk CLI collection to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake">
      Parse requested Google Cloud inspection, billing query, or resource operation. Derive a kebab-case {TOPIC}.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Project context: `gcloud config list`, `gcloud projects list`, `gcloud projects describe {PROJECT}`.
      - Services and assets: `gcloud {SERVICE} list`, `gcloud {SERVICE} describe`, `gcloud asset search-all-resources`.
      - Billing and monitoring: `gcloud billing accounts list`, `gcloud logging read`, `gcloud monitoring`.
      Prefer `--format="table(...)"` or JSON piped through `jq` for concise output.
      Send bulk log or fact collection to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="mutation_guardrail">
      Identify if the command creates billable assets, mutates configurations, or deletes cloud resources.
      Present each mutation as an explicit approval request to the user per `<security_guardrails>`:
      - State exact command, target project/resource, reason, and cost or blast-radius impact.
      - Execute only after explicit affirmative user approval.
    </step>

    <step id="4" name="report">
      Write detailed inventories, cost breakdowns, and logs to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`.
      In chat (user's language), provide the direct answer, the report path, and any pending approval request.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only gcloud commands and collect output.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only gcloud commands listed in {COMMANDS}.
        Save formatted command outputs to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
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
    <rule id="outputs-on-disk">Save large outputs and logs to ${TMPDIR:-/tmp}/ai-tools/ rather than flooding session context.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`, and dispatch agents per implement-ai-tools `<harness_agents>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` per implement-ai-tools `<harness_agents>`, assembling nested payloads per implement-ai-tools `<rule id="payload-assembly">`.</rule>
  </boundaries>
</skill>
