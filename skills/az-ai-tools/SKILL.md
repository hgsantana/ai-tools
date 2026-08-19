---
name: az-ai-tools
description: >
  Run the az-ai-tools work — query or manage Azure via the Azure CLI (az) — either by dispatching
  the az-ai-tools agent or by running its base file in this session. Use for /az-ai-tools or whenever
  the user asks about Azure resources, subscriptions, costs, or infrastructure, or wants something
  created, modified, or removed in Azure.
argument-hint: "[what to inspect or change in Azure]"
---

# Azure

Inventory, cost, and operations on Azure through the Azure CLI (`az`).

You are running an agent-backed skill: your shared contract is `$HOME/.ai-tools/skills/SKILL-CONTRACT.md`.
Read it and follow it — it governs the model check, the route offer, and the route mechanics.

Your base file is `$HOME/.ai-tools/skills/az-ai-tools.md`.
Read it and follow it in full — it is the absolute rule set for this skill; the contract above governs only the mechanics it names.
