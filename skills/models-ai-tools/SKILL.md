---
name: models-ai-tools
description: >
  Rebuild and refresh the MODELS.csv mapping and wrapper pins across all
  supported harnesses using harness documentation and Artificial Analysis metrics.
  Use for /models-ai-tools. Impact: updates MODELS.csv and matching agent wrappers
  in place; changes model routing and reasoning effort. Agent: implementer-ai-tools.
argument-hint: "[optional: harnesses in scope, or --dry-run]"
---

<skill name="models-ai-tools">
  <overview>
    Rebuild the MODELS.csv matrix and synchronize harness agent wrapper headers
    using harness documentation and Artificial Analysis metrics.
  </overview>

  <session_workflow>
    <step id="1" name="data_extraction">
      Execute data extraction scripts (directly in session or dispatching `implementer-ai-tools` using `<template role="implementer-ai-tools">` from `<dispatch_templates>`):
      - Run `scripts/harness-models.sh` to extract documented models and pricing tables per harness into `dev/tmp/harness-models.csv`.
      - Run `scripts/aa-metrics.sh` to fetch latest Artificial Analysis metrics into `dev/tmp/aa-metrics.csv`.
    </step>

    <step id="2" name="candidate_evaluation">
      Filter and score candidate models per harness using the selection methodology:
      - Score formula: `(Intelligence Index / Cost per Task) / Time per Task` (higher is better).
      - Planner: Intelligence Index >= harness best - 3, then rank.
      - Implementer: Intelligence Index >= harness best - 10, drop planner family, Cost strictly < planner, then rank.
      - Mechanical: Cost between harness min and 3x min, drop planner/implementer families, Cost strictly < implementer, then rank.
      - Apply documented fallback when measurement cannot decide.
    </step>

    <step id="3" name="review_and_confirmation">
      Generate proposed MODELS.csv table and markdown diff.
      Save detailed evaluation to `dev/tmp/models-report.md`.
      Present proposed changes in chat and request explicit user confirmation before writing tracked files.
    </step>

    <step id="4" name="write_files">
      Upon user confirmation, write updated `MODELS.csv` and synchronize wrapper headers in `agents/<harness>/` in the same commit.
      Always pin model token and matching effort token where supported.
    </step>
  </session_workflow>

  <dispatch_templates>
    <template role="implementer-ai-tools">
      <role>Implementer worker: run extraction scripts, compute scores, and format diff.</role>
      <input>
        <harnesses>{HARNESSES}</harnesses>
      </input>
      <instructions>
        Execute scripts/harness-models.sh and scripts/aa-metrics.sh.
        Compute candidate rankings and generate proposed MODELS.csv diff.
        Save report to dev/tmp/models-report.md.
      </instructions>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule>Never write to MODELS.csv or wrappers without explicit user confirmation of the diff.</rule>
    <rule>Keep MODELS.csv and wrapper headers synchronized in the same commit (Rule 12).</rule>
  </boundaries>
</skill>
