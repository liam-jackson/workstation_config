#!/usr/bin/zsh
# echo "entered .zshenv"
skip_global_compinit=1

COMMONRC_PATH="${HOME}/workstation_config/config/commonrc/commonrc"
if [[ -f "${COMMONRC_PATH}" ]]; then
    source "${COMMONRC_PATH}"
fi

export ZDOTDIR="${CONFIG_DIR:-${HOME}/.config}/zsh"
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ("$SHLVL" -eq 1 && ! -o LOGIN) && -s "${ZDOTDIR}/.zprofile" ]]; then
    source "${ZDOTDIR}/.zprofile"
fi

# Emulate sh source command
source_sh() {
    emulate -LR sh
    . "$@"
}
