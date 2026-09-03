#!/usr/bin/env bash
# ai-tools first-install bootstrap (bash). Self-contained: no lib.sh.
# Usage: curl -fsSL https://raw.githubusercontent.com/hgsantana/ai-tools/master/scripts/shell/install-bash.sh | bash
# Keep in sync with install-zsh.sh.
set -u

AI_TOOLS="${AI_TOOLS:-$HOME/.ai-tools}"
REPO_URL="https://github.com/hgsantana/ai-tools.git"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required"

if [ -e "$AI_TOOLS" ]; then
  if [ -d "$AI_TOOLS/.git" ] && [ -f "$AI_TOOLS/scripts/shell/install.sh" ]; then
    printf 'ai-tools is already cloned at %s\n' "$AI_TOOLS"
    printf 'To refresh artifacts from origin/master, run:\n'
    printf '  %s\n' "$AI_TOOLS/scripts/shell/update.sh"
    exit 0
  fi
  die "$AI_TOOLS exists but is not an ai-tools clone — move it aside (the only supported location is \$HOME/.ai-tools)"
fi

git clone "$REPO_URL" "$AI_TOOLS" || die "git clone failed: $REPO_URL -> $AI_TOOLS"
exec "$AI_TOOLS/scripts/shell/install.sh" "$@"
