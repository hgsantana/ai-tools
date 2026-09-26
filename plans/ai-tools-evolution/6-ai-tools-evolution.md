# Stage 6: New models-ai-tools Skill

## Objective

Create the `models-ai-tools` skill to allow interactive inspection and configuration of preferred models per tier (`junior`, `mid`, `senior`) for installed CLI harnesses (`agy`, `claude`, `copilot`), persisting user preferences into `$HOME/.ai-tools/config.local.json`.

## Files

- **Create**:
  - `skills/models-ai-tools/SKILL.md`
- **Modify**:
  - `.gitignore`
  - `scripts/lint.sh`
  - `README.md`
  - `docs/USAGE.md`

## Steps

1. In `.gitignore`:
   - Add `config.local.json` and `*.local.json` so user preferences in the clone are never committed or wiped by `git reset`.
2. Create `skills/models-ai-tools/SKILL.md`:
   - Frontmatter:
     - `name: models-ai-tools`
     - `description`: Inspect available models and configure preferred models per tier (junior, mid, senior) for installed CLI harnesses. Use for /models-ai-tools. Impact: writes local configuration to $HOME/.ai-tools/config.local.json; no repository code is modified. Agent: session.
     - `argument-hint`: "[optional harness name]"
   - Body:
     - `step id="1" name="detect_installed_clis"`: Check availability of `agy`, `claude`, and `copilot` on `PATH`.
     - `step id="2" name="model_discovery"`: For detected CLIs, discover supported models using the static table and dynamic query (`agy models`, `claude --help`, `copilot --help`).
     - `step id="3" name="tier_configuration"`: Interactively query the user via USER-AGENTS `<user_interaction>` to select preferred models for `junior`, `mid`, and `senior` tiers among discovered options.
     - `step id="4" name="persist_configuration"`: Save or merge choices into `$HOME/.ai-tools/config.local.json` under `"models"`.
     - `step id="5" name="report"`: Display summary table of configured models in chat.
3. In `scripts/lint.sh`:
   - Register `models-ai-tools` in the shipped skills list.
4. In `README.md` and `docs/USAGE.md`:
   - Document `/models-ai-tools`, its options, and purpose.

## Tests

- Run `./scripts/lint.sh` to ensure `models-ai-tools` conforms to naming, frontmatter, XML vocabulary, and references.
- Run `./scripts/test.sh` to confirm installation and verification scripts handle the new skill.

## Acceptance criteria

- `skills/models-ai-tools/SKILL.md` exists and complies with all repository authoring rules.
- `.gitignore` ignores `config.local.json`.
- `scripts/lint.sh` and `scripts/test.sh` pass cleanly.

## Commit message

```text
feat(skills): introduce models-ai-tools skill for interactive model configuration
```

## Dependencies

- Stage 3 (`3-ai-tools-evolution.md`)

## Implementation log

- Updated `.gitignore`:
  - Added `config.local.json` and `*.local.json` to prevent local model configuration preferences from being tracked or overwritten.
- Created `skills/models-ai-tools/SKILL.md`:
  - Defined frontmatter with name `models-ai-tools`, description (246 chars, <= 500 chars limit), and argument hint `"[optional harness name]"`.
  - Structured semantic XML with `<skill name="models-ai-tools">`, `<overview>`, `<session_workflow>`, `<dispatch_templates>`, and `<boundaries>`.
  - Implemented session workflow steps:
    - `<step id="1" name="cli_detection">`: Probes `PATH` for `agy`, `claude`, and `copilot` executables, optionally filtering to requested `{HARNESS}`.
    - `<step id="2" name="model_discovery">`: Combines upfront static tables, baseline tier defaults from `config/agents.json`, and dynamic CLI queries (`agy models`, `claude --help`, `copilot --help`) dispatched to `<template role="model-inspector">`.
    - `<step id="3" name="tier_configuration">`: Interactively queries the user via USER-AGENTS `<user_interaction>` to select preferred models per tier (`junior`, `mid`, `senior`).
    - `<step id="4" name="persist_configuration">`: Saves/merges selections into `$HOME/.ai-tools/config.local.json` under `"models"`.
    - `<step id="5" name="report">`: Displays confirmation and formatted Markdown table of configured tiers in chat.
  - Defined `<dispatch_templates>` with `<template role="model-inspector" executor="default-worker">` for read-only CLI inspection queries.
  - Defined `<boundaries>` citing USER-AGENTS `<execution_protocol>`, `<user_interaction>`, `<security_guardrails>`, and `<rule id="payload-assembly">`.
- Updated `scripts/lint.sh`:
  - Registered `models-ai-tools` in `check_skill_layout`'s `gated` shipped skills list.
- Updated documentation:
  - Documented `/models-ai-tools` and local configuration in `README.md` under Agent tiers.
  - Documented `/models-ai-tools` in `docs/USAGE.md` skills table and added a dedicated Model configuration section.
- Verification results:
  - `./scripts/lint.sh`: exit 0 (646 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (342 ok, 0 skipped, 0 warnings).
