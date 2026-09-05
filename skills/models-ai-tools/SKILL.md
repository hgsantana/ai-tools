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
      Resolve {HARNESSES} in scope from the request (default: all).
      Execute data extraction scripts directly in session, or dispatch `<template role="models-extractor">` from `<dispatch_templates>` substituting {HARNESSES}:
      - Run `scripts/harness-models.sh` to extract documented models and pricing tables per harness into `dev/tmp/harness-models.csv`.
      - Run `scripts/aa-metrics.sh` to fetch latest Artificial Analysis metrics into `dev/tmp/aa-metrics.csv`.
    </step>

    <step id="2" name="candidate_evaluation">
      Filter and score candidate models per harness using `<selection_method>`.
    </step>

    <step id="3" name="review_and_confirmation">
      Generate proposed MODELS.csv table and markdown diff.
      Save detailed evaluation to `dev/tmp/models-report.md`.
      Present proposed changes in chat and request explicit user confirmation before writing tracked files.
    </step>

    <step id="4" name="write_files">
      Upon user confirmation, write updated `MODELS.csv` and synchronize wrapper headers in `agents/{HARNESS}/` in the same commit.
      Always pin model token and matching effort token where supported.
    </step>
  </session_workflow>

  <selection_method>
    <rule id="score">Score formula: `(Intelligence Index / Cost per Task) / Time per Task` (higher is better).</rule>
    <rule id="planner-tier">Planner: Intelligence Index at least harness best minus 3, then rank.</rule>
    <rule id="implementer-tier">Implementer: Intelligence Index at least harness best minus 10, drop planner family, Cost strictly below planner, then rank.</rule>
    <rule id="mechanical-tier">Mechanical: Cost between harness min and 3x min, drop planner/implementer families, Cost strictly below implementer, then rank.</rule>
    <rule id="fallback">Apply the documented fallback when measurement cannot decide.</rule>
  </selection_method>

  <dispatch_templates>
    <template role="models-extractor" agent="implementer-ai-tools">
      <job>Implementer worker: run extraction scripts, compute scores, and format diff.</job>
      <input>
        <harnesses>{HARNESSES}</harnesses>
      </input>
      <instructions>
        Execute scripts/harness-models.sh and scripts/aa-metrics.sh for {HARNESSES}.
        Compute candidate rankings per `<selection_method>` and generate proposed MODELS.csv diff.
        Save report to dev/tmp/models-report.md and return its path.
      </instructions>
    </template>
  </dispatch_templates>

  <boundaries>
    <rule id="confirm-before-write">Never write to MODELS.csv or wrappers without explicit user confirmation of the diff.</rule>
    <rule id="same-commit-sync">Keep MODELS.csv and wrapper headers synchronized in the same commit (README.md#model-selection-and-wrapper-authoring).</rule>
  </boundaries>
</skill>
