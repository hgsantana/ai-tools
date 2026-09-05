---
name: models-ai-tools
description: >
  Rebuild and refresh the MODELS.csv mapping and wrapper pins across all
  supported harnesses using harness documentation and Artificial Analysis metrics.
  Use for /models-ai-tools. Impact: updates MODELS.csv and matching agent wrappers
  in place; changes model routing and reasoning effort. Agent: implementer-ai-tools.
argument-hint: "[optional: harnesses in scope, or --dry-run]"
---

# Model selection and wrapper authoring

Rebuild the MODELS.csv matrix and synchronize harness agent wrapper headers.

## Workflow

This file is the brief for the dispatched agent. Execute the Workflow.

1. **Extract data** — run `scripts/harness-models.sh` to extract documented models and pricing tables per harness into `dev/tmp/harness-models.csv`. Run `scripts/aa-metrics.sh` to retrieve latest model metrics into `dev/tmp/aa-metrics.csv`.
2. **Evaluate candidates** — apply the selection methodology per harness:

### Terms

| Term | Meaning |
|---|---|
| **Family** | One official family + version from step 1 |
| **Official effort** | A level the harness's individual-plan pricing/models table names for that surface and model. If the table names none, the family has no official effort. A label that exists only on Artificial Analysis (reasoning, non-reasoning, Adaptive Reasoning) is not one |
| **Complete row** | An AA **model** row with independently finished numeric Intelligence Index, Cost per Task, and Time per Task > 0 — no `*`, no lab-claim stand-in |
| **Effort-comparable** | The family has a complete row for **two or more** official efforts. One complete official row, or none, is not comparable; a later rematch writes the effort column when more levels are measured |
| **Score** | `(Intelligence Index / Cost per Task) / Time per Task` — higher first |

### Selection methodology

1. **List names.** From the harness's official **pricing/models** table for **individual** plans on this exact agent surface, list every model named by the most permissive documented first-party individual plan. Collapse each family + version to one name by removing effort, Fast/standard, and other mode suffixes. Record the accepted configuration value, underlying model, plan, surface, and every **official effort** token named for that model (`low`, `medium`, `high`, `xhigh`, `max`, or vendor equivalent). Record an empty effort when none is named. Exclude retired, utility, internal, arbitrary BYOK, and auto-routing models. Count an alias or tier only when official documentation resolves it to one family + version on the research date. Source names and effort exclusively from that harness table rather than a vendor API catalog, team/enterprise-only list, or Artificial Analysis.
2. **Join measurements.** Filter the AA catalog to the complete step-1 name list across all supported harnesses. Treat every AA **model** row for each remaining family + version, effort, and mode as a candidate. Record Intelligence Index, Cost per Task, and Time per Task in one table per harness. Use model-level measurements rather than harness-stack scores. Show gaps as `N/A` and exclude `*` estimates and lab claims from selection. Use AA Cost per Task rather than per-token or subscription prices, and calculate with downloadable source precision.
3. **Select.** Keep candidates with complete Intelligence Index, Cost per Task, and Time per Task values; do not impute. Thresholds are inclusive and selection is per harness. When the harness names no official effort for a family, collapse that family's complete rows **before** filtering into one candidate using the unweighted mean of all three metrics; name it only by family + version. Filter and rank the resulting candidates by score, then break ties by lower Cost per Task and lower Time per Task.
   - **planner** — keep Intelligence Index ≥ that harness's best − `3`, then rank.
   - **implementer** — keep Intelligence Index ≥ that harness's best − `10`. Drop any survivor whose family + version is the planner's. Keep Cost per Task **strictly less** than the planner's. Then rank.
   - **mechanical** — keep Cost per Task between that harness's minimum and `3 ×` that minimum. Drop any survivor whose family + version is the planner's or the implementer's. Keep Cost per Task **strictly less** than the implementer's (and thus than the planner's). Then rank. An empty band after those cuts is a fallback — do not reopen the planner or implementer family.
4. **Fallback—when measurement cannot decide** because step 3 yields an empty band, no complete candidate, or a final Cost per Task and Time per Task tie. Use the harness's official task guidance: deep reasoning, architecture, and ambiguity for **planner**; agentic software development, implementation, and tool use for **implementer**; simple, repetitive, routine, fast, or cost-sensitive work for **mechanical**. Cite it and label `documented fallback`. If guidance names **one** model, use that token and any effort it also names. Otherwise—including Auto/routing or multiple names without a winner—**repeat the previous category's cell**: implementer copies planner; mechanical copies implementer. Never invent a quantitative winner.
5. **Review and Write.**
   - Put each winner in the CSV as the accepted model token. Write the matching effort column only when the family is effort-comparable **and** official docs list a token that matches the selected row (or the documented-fallback effort the guidance named), in the vendor's spelling. Otherwise leave the effort cell empty. A measured winner may not be `N/A`.
   - Before writing to tracked files:
     - Generate a formatted markdown table of the new `MODELS.csv` content.
     - Report all differences compared to current `MODELS.csv` (changed model tokens, reasoning efforts, and score rationale).
     - Save full details to `dev/tmp/models-report.md`.
     - Present the table and changes in chat and request user confirmation before modifying tracked files.
   - Upon confirmation, write `MODELS.csv` and update affected wrapper headers in `agents/<harness>/` in the exact same commit (rule 12):
     - Always pin the model token in the wrapper header (`model:`, `model_reasoning_effort`, or Grok `config.toml` config).
     - Pin effort only if that effort column is non-empty and the wrapper form can hold it.
     - Grok wrappers declare no `model:` header (pinned in `config.toml`).
     - Antigravity uses tier `flash` across all roles.

