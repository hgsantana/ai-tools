---
name: stripe-ai-tools
description: >
  Inspect, integrate, and manage Stripe payments, Checkout Sessions, products,
  prices, customers, and webhooks via Stripe MCP and SDKs. Use for
  /stripe-ai-tools.
argument-hint: "[Stripe integration or resource task]"
---

<skill name="stripe-ai-tools">
  <overview>
    Inspect, integrate, and manage Stripe resources and Checkout Sessions through the Stripe MCP server, CLI, or client SDKs.
    The session handles user approvals, scenario detection, and surgical code integration, sending bulk data discovery to a default worker.
  </overview>

  <session_workflow>
    <step id="1" name="intake_and_scope">
      Parse requested Stripe task: platform resource inspection, Checkout Session integration, webhook setup, or customer/product management. Derive a kebab-case {TOPIC}.
    </step>

    <step id="2" name="read_exploration">
      Run read-only inspection queries freely:
      - Account and platform resources: query products, prices, customers, payment links, and invoices via Stripe MCP tools or CLI.
      - SDK and runtime environment: inspect installed Stripe SDK version in project manifests (`package.json`, `Gemfile.lock`, `go.mod`, `requirements.txt`).
      - Codebase scan: search for existing Checkout Session calls (`stripe.checkout.sessions.create` or framework equivalents) to distinguish Scenario A from Scenario B per `<rule id="scenario-detection">`.
      Send bulk fact collection or resource inventory to `<template role="mechanical-discovery">` from `<dispatch_templates>`, substituting {COMMANDS} and {TOPIC}.
    </step>

    <step id="3" name="mutation_guardrail">
      Identify if the requested action creates live charges, modifies customer billing, updates live prices, issues refunds, or mutates cloud webhooks.
      Present each mutation as an explicit approval request to the user per `<security_guardrails>`:
      - State exact command or tool call, target resource, rationale, and financial or live-account impact.
      - Execute only after explicit affirmative user approval per `<rule id="reads-free-mutations-approved">`.
    </step>

    <step id="4" name="codebase_integration">
      When integrating Stripe Checkout into an application codebase, apply surgical updates:
      - In Scenario A: update only parameters inside the existing session creation call to match `<rule id="checkout-studio-presets">`. Preserve real user values for `mode`, `success_url`, `cancel_url`, and `line_items`. Remove parameters absent from presets.
      - In Scenario B: add a minimal server-side endpoint calling `stripe.checkout.sessions.create` with parameters from `<rule id="checkout-studio-presets">` and sample placeholders. Adapt strictly to the host framework.
      - Set `ui_mode` per `<rule id="sdk-version-compatibility">`.
      - Configure webhook endpoints verifying `stripe-signature` and handling `checkout.session.completed` with consent validation (`terms_of_service`, `promotions`).
      - Create or update `STRIPE_INTEGRATION_TODO.md` per `<rule id="single-source-todo">`.
    </step>

    <step id="5" name="report">
      Write detailed inventories, integration diffs, and setup notes to `${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md`.
      In chat (user's language), provide the direct answer, the report path, any pending approval request, and point the user to `STRIPE_INTEGRATION_TODO.md` when code was integrated.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="mechanical-discovery" executor="default-worker">
      <job>Default worker: run read-only Stripe queries and collect resource outputs.</job>
      <input>
        <commands>{COMMANDS}</commands>
        <topic>{TOPIC}</topic>
      </input>
      <instructions>
        Execute the read-only Stripe queries listed in {COMMANDS}.
        Write formatted outputs and resource listings to ${TMPDIR:-/tmp}/ai-tools/{TOPIC}.md.
        Return command list, exit codes, and output path.
      </instructions>
      <constraints>
        <constraint>Read-only queries only. Never execute mutating commands, charges, or refunds.</constraint>
      </constraints>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="reads-free-mutations-approved">Read-only queries run freely; every financial mutation, charge, refund, or live resource creation requires separate user approval.</rule>
    <rule id="scenario-detection">Scan codebase for existing Checkout Session calls: if present, follow Scenario A; if absent, follow Scenario B.</rule>
    <rule id="checkout-studio-presets">Enforce fixed Checkout Studio parameters: billing_address_collection is auto, phone_number_collection is disabled, automatic_tax is disabled, allow_promotion_codes is false, submit_type is auto, integration_identifier is hosted_mobile_app_0001, origin_context is mobile_app, and payment_method_collection is always only when mode is subscription.</rule>
    <rule id="sdk-version-compatibility">When Stripe SDK version is 21.0.0 or higher, set ui_mode to hosted_page. For SDK versions below 21.0.0, set ui_mode to hosted. If undetermined, default to hosted_page and document the dependency in STRIPE_INTEGRATION_TODO.md.</rule>
    <rule id="single-source-todo">Maintain STRIPE_INTEGRATION_TODO.md in the target project root as the single source of truth for all placeholder replacements (mode, success_url, cancel_url, line_items price IDs), webhook secrets, and next steps.</rule>
    <rule id="outputs-on-disk">Save large outputs, payload listings, and logs to ${TMPDIR:-/tmp}/ai-tools/ rather than flooding session context.</rule>
    <rule id="protocol-source">Follow user-wide `<user_interaction>` and `<security_guardrails>`. A repository `AGENTS.md` or `README.md` still overrides those rules there.</rule>
    <rule id="default-worker">Spawn each `<template executor="default-worker">` via the harness default subagent, passing only the brief and paths, never conversation context.</rule>
  </boundaries>
</skill>
