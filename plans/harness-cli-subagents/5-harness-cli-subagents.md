# Stage 5: Remove grok and cursor support

## Objective
Remove support for Grok and Cursor from `USER-AGENTS.md`, `README.md`, `scripts/shell/lib.sh`, `scripts/shell/install.sh`, and test files, retaining only the four supported harnesses (`claude-code`, `codex`, `copilot`, `antigravity`).

## Files
- Modify: `USER-AGENTS.md`
- Modify: `README.md`
- Modify: `scripts/shell/lib.sh`
- Modify: `scripts/shell/install.sh`
- Modify: `scripts/test/lib.sh`
- Modify: `scripts/test/install.sh`
- Modify: `scripts/test/reinstall.sh`
- Modify: `scripts/test/remove.sh`
- Modify: `scripts/test/update.sh`

## Steps
1. Update `ALL_HARNESSES` in `scripts/shell/lib.sh` to `"claude-code codex copilot antigravity"`.
2. Remove Grok and Cursor cases from `skills_root()`, `instructions_dest()`, `is_harness_installed()` in `scripts/shell/lib.sh`.
3. Update `USER-AGENTS.md` XML rules (`<rule id="native-spawn">`, `<user_interaction>` `<default>`) to only list supported harnesses (Claude Code, Copilot, Codex, Antigravity).
4. Update `README.md` supported harnesses table, descriptions, and rule counts to match the four harnesses.
5. Update shell install scripts and test assertions.

## Tests
- Run `./scripts/lint.sh` to verify harness parity and rule compliance.

## Acceptance criteria
- Only `claude-code`, `codex`, `copilot`, and `antigravity` are supported.
- `scripts/lint.sh` confirms supported harnesses match `lib.sh` (4 harnesses).

## Commit message
`chore(harnesses): remove grok and cursor support`

## Dependencies
Stage 4

## Implementation log
- Updated `scripts/shell/lib.sh` to set `ALL_HARNESSES="claude-code codex copilot antigravity"` and removed `grok` and `cursor` cases from `skills_root()`, `instructions_dest()`, and `harness_detected()`.
- Updated `scripts/shell/install.sh` usage string to list the 4 supported harnesses (`claude-code,codex,copilot,antigravity`).
- Updated `USER-AGENTS.md` to remove Grok and Cursor references from `<rule id="native-spawn">` and `<user_interaction>` `<default>`, keeping character count at 7,780 (within the 8,000 character limit).
- Updated `README.md` to reflect the 4 supported harnesses in the overview, Scope description, safety rules, Supported harnesses table (removing Grok Build and Cursor rows/notes), installation steps, and troubleshooting.
- Updated `docs/USAGE.md` example command to reference copilot instead of cursor.
- Updated `scripts/test/lib.sh`, `scripts/test/install.sh`, `scripts/test/reinstall.sh`, `scripts/test/update.sh`, and `scripts/test/remove.sh` to remove grok and cursor fixture paths, test cases, and assertions.
- Ran `shellcheck` across all modified shell scripts and verified 0 warnings.
- Ran `./scripts/test.sh` and verified all 346 tests pass.
- Ran `./scripts/lint.sh` and verified all 607 checks pass with 0 warnings (supported harnesses matching lib.sh with 4 harnesses).
