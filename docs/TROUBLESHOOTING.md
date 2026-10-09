# Troubleshooting

This guide provides diagnostic solutions for common installation, update, and runtime issues across supported harnesses.

---

## Git and Clone Issues

### Local changes prevent update (`reset would discard local work`)
- **Cause**: `update.sh` guards against discarding uncommitted work or local commits ahead of `origin/master`.
- **Solution**: Save your changes before updating:
  ```bash
  git stash                 # stash uncommitted edits
  # or
  git checkout -b my-branch # save commits to a branch
  ```
- Alternatively, if you intend to discard local modifications, pass `--discard-local`:
  ```bash
  "$HOME/.ai-tools/scripts/shell/update.sh" --discard-local
  ```

### `origin/master` missing or fetch failed
- **Cause**: Network connectivity failure, missing remote credentials, or renamed remote tracking branch.
- **Solution**: Verify remote connectivity with `git fetch origin`. Check remote URL with `git remote -v`. ai-tools targets `master` on `https://github.com/hgsantana/ai-tools.git`.

### Not a clone or missing repository
- **Cause**: The folder `$HOME/.ai-tools` does not exist or is not a git clone.
- **Solution**: Clone the repository to the canonical location:
  ```bash
  git clone https://github.com/hgsantana/ai-tools.git "$HOME/.ai-tools"
  "$HOME/.ai-tools/scripts/shell/install.sh"
  ```

### Clone is not at `$HOME/.ai-tools`
- **Cause**: The repository was cloned to a custom or nested directory.
- **Solution**: Relocate the clone to `$HOME/.ai-tools` (rule 16). Installed instructions and skills rely on this exact path.

---

## Harness Detection and Integration

### Skills missing from menu after install or update
- **Cause**: Supported harnesses (Claude Code, GitHub Copilot, Google Antigravity) cache skill catalogs at startup.
- **Solution**:
  1. Completely restart the CLI or host IDE.
  2. Run the verification script to confirm links:
     ```bash
     "$HOME/.ai-tools/scripts/shell/verify.sh"
     ```

### GitHub Copilot ignores installed instructions
- **Cause**: Copilot requires `applyTo` frontmatter to activate instructions across files. `verify.sh` verifies file equality, not activation.
- **Solution**:
  1. Confirm that `$HOME/.copilot/instructions/ai-tools.instructions.md` begins with:
     ```yaml
     ---
     applyTo: "**"
     ---
     ```
  2. Restart VS Code or your editor.
  3. Open Copilot Chat Diagnostics to confirm the instructions file is loaded.
  4. Test with an explicit prompt or slash command.

### Antigravity rule length limits
- **Cause**: Google Antigravity rejects or truncates instruction files exceeding 12,000 characters.
- **Solution**: `AI-TOOLS-AGENTS.md` is strictly limited to 10,000 characters (rule 3). If you maintain personal instructions in `$HOME/.ai-tools/USER-AGENTS.md`, keep them concise to avoid exceeding harness limits.

---

## Filesystem, Symlinks, and Permissions

### `copied (will not track updates)`
- **Cause**: The operating system or filesystem refused symbolic links (common on Windows without Developer Mode enabled).
- **Solution**:
  - On Windows: Enable Developer Mode in Windows Settings, or run the installer from an elevated Git Bash or WSL shell.
  - While using copies, re-run `update.sh` whenever upstream changes are made, as copies do not automatically reflect git changes.

### Legacy or dangling links
- **Cause**: Leftover links from older repository layouts or retired tools.
- **Solution**: Run `update.sh` or `remove.sh`. Both include a stale-link sweep that unlinks obsolete references into `$HOME/.ai-tools`, including links under the retired `$HOME/.gemini/skills/` directory.

### Edited a copied artifact locally
- **Cause**: Direct edits to an installed file in `~/.claude/skills/`, `~/.copilot/`, or `~/.gemini/`.
- **Solution**: Installed artifacts are managed deployment targets. Save any personal customizations in `$HOME/.ai-tools/USER-AGENTS.md` (which is never modified or removed by scripts, per rule 17). Re-run `install.sh` or `update.sh` with `--overwrite` to restore the clean state.

---

## Artifact Conflicts and Overwriting

### Conflicting or modified artifact needs replacement
- **Cause**: An existing file or local modification prevents non-destructive linking.
- **Solution**: Re-run install or update with `--overwrite` and your target harnesses:
  ```bash
  "$HOME/.ai-tools/scripts/shell/install.sh" --overwrite --harnesses all
  ```

### Removing modified copies or orphan skills
- **Cause**: `remove.sh` skips locally modified files to avoid destroying user work by default.
- **Solution**: Force removal of recognized artifact destinations using `--force`:
  ```bash
  "$HOME/.ai-tools/scripts/shell/remove.sh" --force --instructions
  ```

