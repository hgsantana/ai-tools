# Stage 1: Remove OpenAI Codex Support (Strict Cut)

## Objective

Strictly remove OpenAI Codex support across the entire `ai-tools` repository. Delete `skills/codex-ai-tools/`, reduce `ALL_HARNESSES` from 4 to 3 supported harnesses (`claude-code copilot antigravity`), remove all Codex branches from shell scripts, test suites, instructions, and documentation without legacy sweeps.

## Files

- **Remove**:
  - `skills/codex-ai-tools/SKILL.md`
  - Directory `skills/codex-ai-tools/`
- **Modify**:
  - `scripts/shell/lib.sh`
  - `USER-AGENTS.md`
  - `README.md`
  - `docs/USAGE.md`
  - `scripts/shell/install.sh`
  - `scripts/test/lib.sh`
  - `scripts/test/install.sh`
  - `scripts/test/remove.sh`
  - `scripts/test/reinstall.sh`
  - `scripts/test/update.sh`
  - `scripts/test/smoke.sh`
  - `scripts/lint.sh`

## Steps

1. Delete `skills/codex-ai-tools/` and `skills/codex-ai-tools/SKILL.md`.
2. In `scripts/shell/lib.sh`:
   - Change `ALL_HARNESSES="claude-code codex copilot antigravity"` to `ALL_HARNESSES="claude-code copilot antigravity"`.
   - Remove `codex)` case from `skills_root()`.
   - Remove `codex)` case from `instructions_dest()`.
   - Remove `codex)` case from `detect_harness()`.
   - Remove `~/.codex/AGENTS.override.md` warning check.
3. In `USER-AGENTS.md`:
   - In `<rule id="native-spawn">`, remove `Codex spawn_agent`.
   - In `<user_interaction>`, remove `Codex request_user_input`.
4. In `README.md` and `docs/USAGE.md`:
   - Remove Codex row from Supported harnesses table.
   - Remove mentions of OpenAI Codex in the repository overview and descriptions.
   - Remove description of `/codex-ai-tools` in `docs/USAGE.md`.
   - Update any harness count references from 4 to 3.
5. In `scripts/test/*.sh`:
   - Remove `.codex/skills` from `T_HARNESS_DIRS` in `scripts/test/lib.sh`.
   - Remove Codex assertions from `scripts/test/install.sh`, `scripts/test/remove.sh`, `scripts/test/reinstall.sh`, `scripts/test/update.sh`, and `scripts/test/smoke.sh`.
6. In `scripts/lint.sh`:
   - Remove any references to `codex-ai-tools` and adjust harness checks.
7. Run `./scripts/lint.sh` and `./scripts/test.sh`.

## Tests

- Run `./scripts/lint.sh` to ensure semantic XML references, vocabulary, and rules remain balanced.
- Run `./scripts/test.sh` to ensure installation, removal, update, and verification suites pass on 3 harnesses.

## Acceptance criteria

- Directory `skills/codex-ai-tools/` is removed.
- `git grep -i "codex"` in tracked files returns zero occurrences.
- `./scripts/lint.sh` exits 0.
- `./scripts/test.sh` exits 0 with 0 warnings.

## Commit message

```text
chore(codex): remove codex harness support and legacy references
```

## Dependencies

- None (Base stage)

## Implementation log

- Removed `skills/codex-ai-tools/` and `skills/codex-ai-tools/SKILL.md`.
- Updated `scripts/shell/lib.sh`:
  - `ALL_HARNESSES` set to `"claude-code copilot antigravity"`.
  - Removed `codex)` case from `skills_root()`, `instructions_dest()`, and `harness_detected()`.
  - Removed `~/.codex/AGENTS.override.md` warning check from `install_instructions()`.
- Updated `USER-AGENTS.md`:
  - Removed `Codex spawn_agent` from `<rule id="native-spawn">`.
  - Removed `Codex request_user_input` from `<user_interaction>`.
  - Verified character count: 7,737 chars (strictly below 8,000 char cap).
- Updated `README.md`:
  - Removed OpenAI Codex from repository overview.
  - Removed Codex context budget clause from rule 6.
  - Updated harness scope list and counts from 4 to 3 in Scope bullet, fixture description, and installation step 2.
  - Removed OpenAI Codex from Supported harnesses table and removed Codex notes bullet.
  - Removed `AGENTS.override.md` mention from installation step 3.
- Updated `scripts/shell/install.sh`:
  - Updated `--harnesses` usage text list to 3 harnesses.
- Updated `scripts/test/lib.sh`:
  - Removed `.codex/skills` from `T_HARNESS_DIRS`.
- Updated test cases in `scripts/test/install.sh`, `scripts/test/remove.sh`, `scripts/test/reinstall.sh`, `scripts/test/update.sh`:
  - Removed codex assertions in all-harnesses tests.
  - Adapted `case_install_parent_symlink_protects_agents_md` and `case_remove_parent_symlink_protects_agents_md` to test `$HOME/AGENTS.md` alias protection against surviving harnesses (`claude-code`).
  - Updated expected scope assertion in `case_update_all_harnesses_alias`.
- Updated `plans/ai-tools-evolution/0-ai-tools-evolution.md`:
  - Updated Stage 1 Status cell from `W` to `V`.
- Verification results:
  - `git grep -in "codex" -- ':!plans'`: 0 occurrences outside plans.
  - `./scripts/lint.sh`: exit 0 (585 ok, 1 skipped, 0 warnings).
  - `./scripts/test.sh`: exit 0 (340 ok, 0 skipped, 0 warnings).
