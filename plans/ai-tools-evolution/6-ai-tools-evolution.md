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

