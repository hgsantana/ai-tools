#!/usr/bin/env bash
# Configura git e gh dentro do container a partir dos binds read-only do host.
#
# Autenticação: o token do gh no host vive no keyring e NÃO é montável. Quem
# autentica o git aqui é o encaminhamento de credenciais da extensão Dev
# Containers do VS Code. Por isso removemos qualquer credential.helper que
# aponte para o gh do host — ele não existe/não tem token aqui e, por ser mais
# específico que o helper genérico, sequestraria o github.com.
set -euo pipefail

HOST_GITCONFIG=/usr/local/share/host-git/gitconfig
HOST_GH_DIR=/usr/local/share/host-gh

# 1. Identidade vinda do bind (nada hardcoded neste repositório).
if [ -r "$HOST_GITCONFIG" ]; then
	for key in user.name user.email core.editor init.defaultBranch pull.rebase; do
		value=$(git config --file "$HOST_GITCONFIG" --get "$key" || true)
		[ -n "$value" ] && git config --global "$key" "$value"
	done
fi

# 2. Limpa helpers herdados (bind acima ou cópia automática do VS Code).
git config --global --remove-section 'credential.https://github.com' 2>/dev/null || true
git config --global --remove-section 'credential.https://gist.github.com' 2>/dev/null || true
git config --global --unset-all credential.helper 2>/dev/null || true

# 3. Diretório do repositório montado pertence ao host; evita "dubious ownership".
git config --global --add safe.directory "${PWD}"

# 4. Config do gh (aliases/prefs) copiada para um local gravável; o token não
#    vem junto — rode `gh auth login` uma vez dentro do container se precisar.
if [ -d "$HOST_GH_DIR" ]; then
	mkdir -p "$HOME/.config/gh"
	[ -r "$HOST_GH_DIR/config.yml" ] && cp "$HOST_GH_DIR/config.yml" "$HOME/.config/gh/config.yml"
	chmod 700 "$HOME/.config/gh"
fi

echo "git configurado como: $(git config --global user.name) <$(git config --global user.email)>"
