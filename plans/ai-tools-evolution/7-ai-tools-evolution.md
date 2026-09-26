# Stage 7: New config-ai-tools Skill

## Objective

Create the `config-ai-tools` skill to configure global behavioral preferences for `ai-tools` (controlling routing gate skill offers, default CLI, and prompting for implementer models). Persist preferences in `$HOME/.ai-tools/config.local.json`, synchronize routing preferences into installed `USER-AGENTS.md` for zero-latency execution, and allow skills to read implementation defaults on demand.

## Files

- **Create**:
  - `skills/config-ai-tools/SKILL.md`
- **Modify**:
  - `scripts/shell/lib.sh`
  - `skills/vibe-ai-tools/SKILL.md`
  - `skills/campaign-ai-tools/SKILL.md`
  - `scripts/lint.sh`
  - `README.md`
  - `docs/USAGE.md`

## Steps

1. Create `skills/config-ai-tools/SKILL.md`:
   - Frontmatter:
     - `name: config-ai-tools`
     - `description`: Configure global ai-tools behavior: skill offer gate, default CLI, and implementer model prompts. Use for /config-ai-tools. Impact: updates $HOME/.ai-tools/config.local.json and syncs installed harness instructions; code remains unchanged. Agent: session.
     - `argument-hint`: "[setting to configure]"
   - Body:
     - `step id="1" name="intake_and_interview"`: Interactively interview the user via USER-AGENTS `<user_interaction>` on key settings:
       1. Skill offer gate: whether `USER-AGENTS.md` should display the skill offer table on non-trivial requests or route directly to execution.
       2. Default CLI harness: preferred CLI for autonomous execution (`agy`, `claude`, `copilot`).
       3. Implementer model prompt: whether skills like `vibe-ai-tools` should ask for an implementer model or use pre-configured defaults directly.
     - `step id="2" name="persist_settings"`: Write or update preferences in `$HOME/.ai-tools/config.local.json` under `"behavior"`.
     - `step id="3" name="sync_instructions"`: When routing gate preferences change, invoke installer helper to recompile/sync `USER-AGENTS.md` into installed harness configurations.
     - `step id="4" name="report"`: Output concise confirmation and summary of active settings.
2. In `scripts/shell/lib.sh`:
   - Add helper logic in installation/update to respect `"offer_skills"` setting from `config.local.json` when deploying `USER-AGENTS.md`.
3. In `skills/vibe-ai-tools/SKILL.md` and `skills/campaign-ai-tools/SKILL.md`:
   - Add step logic to check `$HOME/.ai-tools/config.local.json`: if `ask_implementer_model` is false and a default model is set, skip the model question and use the configured model directly.
4. In `scripts/lint.sh`:
   - Register `config-ai-tools` in shipped skills list.
5. In `README.md` and `docs/USAGE.md`:
   - Document `/config-ai-tools` and available configuration options.

## Tests

- Run `./scripts/lint.sh` to ensure `config-ai-tools` satisfies all XML, frontmatter, and reference rules.
- Run `./scripts/test.sh` to confirm installer and updater function smoothly with the new skill and sync logic.

## Acceptance criteria

- `skills/config-ai-tools/SKILL.md` is present and adheres to all repository rules.
- Global behavioral options are persisted in `$HOME/.ai-tools/config.local.json`.
- `vibe-ai-tools` and `campaign-ai-tools` respect the model prompting preference.
- `./scripts/lint.sh` and `./scripts/test.sh` pass with 0 warnings.

## Commit message

```text
feat(skills): introduce config-ai-tools skill for global behavioral preferences
```

## Dependencies

- Stage 3 (`3-ai-tools-evolution.md`)
- Stage 4 (`4-ai-tools-evolution.md`)
- Stage 6 (`6-ai-tools-evolution.md`)

## Implementation log

