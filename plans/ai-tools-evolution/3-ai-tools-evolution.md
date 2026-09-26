# Stage 3: Multi-Tier Agents (Junior/Mid/Senior) & Central Manifest

## Objective

Establish a standardized 3-tier agent classification (`junior`, `mid`, `senior`) backed by a repository build-time manifest (`config/agents.json`). Map executors in `USER-AGENTS.md` and skills to these tiers across `antigravity`, `claude-code`, and `copilot`.

## Files

- **Create**:
  - `config/agents.json`
- **Modify**:
  - `USER-AGENTS.md`
  - `scripts/shell/lib.sh`
  - `scripts/lint.sh`
  - `README.md`

## Steps

1. Create `config/agents.json` mapping tiers to default models and reasoning tiers for each supported harness:
   ```json
   {
     "harnesses": {
       "antigravity": {
         "junior": { "model": "gemini-3.8-flash", "effort": "low" },
         "mid": { "model": "gemini-3.8-flash", "effort": "high" },
         "senior": { "model": "gemini-3.1-pro", "effort": "high" }
       },
       "claude-code": {
         "junior": { "model": "haiku", "effort": "medium" },
         "mid": { "model": "sonnet", "effort": "medium" },
         "senior": { "model": "opus", "effort": "high" }
       },
       "copilot": {
         "junior": { "model": "gemini-2.5-pro", "effort": "low" },
         "mid": { "model": "gpt-5.4", "effort": "medium" },
         "senior": { "model": "o3", "effort": "high" }
       }
     }
   }
   ```
2. In `USER-AGENTS.md`:
   - Refactor `<execution_protocol>` to define the semantics of the three tiers:
     - `junior`: bulk fact collection, builds, mechanical test runs, and verification tasks (default worker).
     - `mid`: stage code implementation, bug fixes, test authoring (implementer).
     - `senior`: planning, architectural alignment, stage review, and diff validation (judge / session-subagent).
   - Ensure `USER-AGENTS.md` remains strictly under the 8,000-character cap.
3. In `scripts/lint.sh`:
   - Add a check validating the structure and validity of `config/agents.json` (all 3 harnesses present, defining `junior`, `mid`, and `senior`).
4. In `scripts/shell/lib.sh`:
   - Add utility functions to query tier models from `config/agents.json`.
5. Update `README.md` to document the 3-tier agent hierarchy and the manifest.

## Tests

- Run `./scripts/lint.sh` to check `config/agents.json` validation and `USER-AGENTS.md` character length.
- Run `./scripts/test.sh` to confirm installer and updater work with the new manifest file.

## Acceptance criteria

- `config/agents.json` is present and valid.
- `USER-AGENTS.md` documents `junior`, `mid`, and `senior` roles and stays <= 8,000 characters.
- `./scripts/lint.sh` and `./scripts/test.sh` pass cleanly.

## Commit message

```text
feat(agents): define central agents manifest and junior mid senior tiers
```

## Dependencies

- Stage 2 (`2-ai-tools-evolution.md`)

## Implementation log

- Created `config/agents.json`:
  - Defined central manifest mapping `junior`, `mid`, and `senior` tiers across all 3 supported harnesses (`antigravity`, `claude-code`, `copilot`) with default models and reasoning effort tiers.
- Updated `USER-AGENTS.md`:
  - Added `<rule id="agent-tiers">` defining the 3 agent tiers: `junior` (default-worker for mechanical tasks, tests, builds, and read-only fact collection), `mid` (implementer for stage code editing, bug fixes, and unit tests), and `senior` (high-level planner, judge, and architectural evaluation).
  - Explicitly mapped `default-worker` (`junior`), `implementer` (`mid`), and `session-subagent` (`senior`).
  - Tightened routing gate prose to maintain strict character cap compliance (7,651 chars, well under 8,000 cap).
- Updated `scripts/shell/lib.sh`:
  - Added `agent_tier_model <harness> <tier>` helper function to query model for a given harness and tier from `config/agents.json`.
  - Added `agent_tier_effort <harness> <tier>` helper function to query reasoning effort tier.
- Updated `scripts/lint.sh`:
  - Added `check_agents_manifest` verifying that `config/agents.json` exists, is valid JSON, and defines `junior`, `mid`, and `senior` for all 3 supported harnesses.
  - Registered `agents manifest` in `usage()`.
- Updated `README.md`:
  - Added `config/agents.json` to Contents table.
  - Documented 3 agent tiers and central manifest under Semantic XML grammar.
  - Registered `agents manifest` in Development checks family list.
- Verification results:
  - `./scripts/lint.sh`: exit 0 (596 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (340 ok, 0 skipped, 0 warnings).
