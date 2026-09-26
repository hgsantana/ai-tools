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

