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
