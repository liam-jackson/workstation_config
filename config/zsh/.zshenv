#!/usr/bin/zsh
# echo "entered .zshenv"

# This is necessary to avoid random completion issues, you'll find people recommending to add this to the /etc/zsh/zshenv file,
# but I prefer to keep it here for version control and to avoid having a random thing to remember when setting up a new machine.
skip_global_compinit=1

# COMMONRC_PATH is the path to a file that contains environment variables, aliases, and function definitions that I tried
# to maintain compatibility with bash. It is not critical to do that, but I recommend it.
COMMONRC_PATH="${HOME}/workstation_config/config/commonrc/commonrc"
if [[ -f "${COMMONRC_PATH}" ]]; then
    source "${COMMONRC_PATH}"
fi

# ...for instance, CONFIG_DIR is defined in commonrc, so it is available here
export ZDOTDIR="${CONFIG_DIR:-${HOME}/.config}/zsh"
# and so is XDG_CACHE_HOME (I think I actually just use the default value)
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ("$SHLVL" -eq 1 && ! -o LOGIN) && -s "${ZDOTDIR}/.zprofile" ]]; then
    source "${ZDOTDIR}/.zprofile"
fi

# Emulate the vanilla sh 'source' command:
source_sh() {
    emulate -LR sh
    . "$@"
}
