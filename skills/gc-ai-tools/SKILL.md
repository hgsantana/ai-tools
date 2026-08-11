---
name: gc-ai-tools
description: >
  Query and manage Google Cloud resources via the Google Cloud CLI (gcloud). Use whenever the
  user asks about Google Cloud resources, projects, costs, or infrastructure, or wants something
  created, modified, or removed in Google Cloud. Also use for /gc-ai-tools.
---

# Google Cloud CLI (gcloud)

Use the `gcloud` CLI for Google Cloud inventory, cost, and operations work.

## Rules

- Freely use `gcloud` for **read-only / query** operations (list, describe, query costs).
- You may **suggest** creating, modifying, or removing resources; only the user decides.
- **NEVER** create, modify, or remove any Google Cloud resource without **explicit** user
  authorization for that specific action. Prior approval does not carry over, and this gate holds
  even inside an unattended `/dev-ai-tools` run.
- Before any suggested mutating change, make **cost impact** clear (SKU, ongoing cost, billable or not).

## Useful commands

- `gcloud config list` / `gcloud projects list` — project context
- `gcloud projects describe <project>` — inspect a project
- `gcloud <service> list` / `gcloud <service> describe` — inspect a resource
- `gcloud billing accounts list` / `gcloud billing projects describe` — billing
- `gcloud logging read` / `gcloud monitoring` — logs and metrics
- `gcloud asset search-all-resources` — inventory across project/org

Prefer `--format="table(...)"` or JSON piped through `jq` for concise reports.
