#!/usr/bin/env bash
# Configure git and gh inside the container from the host's read-only binds.
#
# Authentication: the host gh token lives in the keyring and is NOT mountable.
# Git auth here comes from the VS Code Dev Containers credential forwarding.
# That is why we remove any credential.helper that points at the host gh — it
# has no token here and, being more specific than the generic helper, would
# hijack github.com.
#
# Grok auth follows the bound $HOME/.grok/auth.json. Antigravity OAuth lives in
# the host OS keyring, so a container session may still prompt to sign in; the
# ~/.gemini bind is for instructions, skills, and agents (no keyring forwarding).
set -euo pipefail

HOST_GITCONFIG=/usr/local/share/host-git/gitconfig
HOST_GH_DIR=/usr/local/share/host-gh

# 1. Identity from the bind (nothing hardcoded in this repository).
if [ -r "$HOST_GITCONFIG" ]; then
	for key in user.name user.email core.editor init.defaultBranch pull.rebase; do
		value=$(git config --file "$HOST_GITCONFIG" --get "$key" || true)
		[ -n "$value" ] && git config --global "$key" "$value"
	done
fi

# 2. Clear inherited helpers (bind above or VS Code auto-copy).
git config --global --remove-section 'credential.https://github.com' 2>/dev/null || true
git config --global --remove-section 'credential.https://gist.github.com' 2>/dev/null || true
git config --global --unset-all credential.helper 2>/dev/null || true

# 3. Mounted repository directory belongs to the host; avoid "dubious ownership".
git config --global --add safe.directory "${PWD}"

# 4. gh config (aliases/prefs) copied to a writable location; the token does
#    not come along — run `gh auth login` once inside the container if needed.
if [ -d "$HOST_GH_DIR" ]; then
	mkdir -p "$HOME/.config/gh"
	[ -r "$HOST_GH_DIR/config.yml" ] && cp "$HOST_GH_DIR/config.yml" "$HOME/.config/gh/config.yml"
	chmod 700 "$HOME/.config/gh"
fi

echo "git configurado como: $(git config --global user.name) <$(git config --global user.email)>"

# --- Official harness CLI installs (latest on create) ---

if ! command -v curl >/dev/null 2>&1; then
	echo "error: curl is required to install Grok Build and Antigravity CLIs" >&2
	exit 1
fi

export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin"

# Grok Build: latest stable into $HOME/.local/bin (container-local binary).
# No version pin; installer has no `latest` alias. Do not set GROK_DEPLOYMENT_KEY.
GROK_CHANNEL=stable GROK_BIN_DIR="$HOME/.local/bin" \
	bash -c 'set -euo pipefail; curl -fsSL https://x.ai/cli/install.sh | bash'

# Antigravity CLI: always latest from its manifest. Do not pass --dir.
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Persist PATH for the vscode user's PowerShell login (chsh to pwsh in stage 2).
# The Grok installer only patches bash/zsh/fish from $SHELL.
PS_PROFILE="$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
PS_MARKER_BEGIN='# >>> ai-tools devcontainer >>>'
PS_MARKER_END='# <<< ai-tools devcontainer <<<'
mkdir -p "$(dirname "$PS_PROFILE")"
if [ ! -f "$PS_PROFILE" ] || ! grep -qF "$PS_MARKER_BEGIN" "$PS_PROFILE" 2>/dev/null; then
	{
		echo "$PS_MARKER_BEGIN"
		echo '$env:PATH = "$env:HOME/.local/bin:" + $env:PATH'
		echo "$PS_MARKER_END"
	} >>"$PS_PROFILE"
fi

# Invocability checks — fail postCreate if either CLI is missing or not runnable.
command -v grok >/dev/null
grok --version
command -v agy >/dev/null
test -x "$(command -v agy)"
