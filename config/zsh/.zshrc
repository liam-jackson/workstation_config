#!/bin/zsh
# echo "entered .zshrc"

# zmodload zsh/zprof

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# History settings
if [[ -f "${ZDOTDIR}/.zsh_history_config" ]]; then
    source "${ZDOTDIR}/.zsh_history_config"
fi

# Autoload functions you might want to use with antidote.
CUST_COMP_DIR="${CONFIG_DIR}/zsh/.zfunc"
if [[ -d "${CUST_COMP_DIR}" ]]; then
    fpath=(${CUST_COMP_DIR} $fpath)
fi

ZFUNCDIR="${ZFUNCDIR:-${ZDOTDIR}/functions}"
if [[ -d "${ZFUNCDIR}" ]]; then
    fpath=("${ZFUNCDIR}" $fpath)
fi

# Source zstyles you might use with antidote.
[[ -e "${ZDOTDIR:-~}/.zstyles" ]] && source "${ZDOTDIR:-~}/.zstyles"

# Clone antidote if necessary.
[[ -d ${ZDOTDIR:-~}/.antidote ]] ||
    git clone https://github.com/mattmc3/antidote "${ZDOTDIR:-${HOME}}/.antidote"

ANTIDOTE_PATH="${ZDOTDIR:-${HOME}}/.antidote/antidote.zsh"
if [[ -f "${ANTIDOTE_PATH}" ]]; then
    source "${ANTIDOTE_PATH}"
else
    echo "Antidote not found at ${ANTIDOTE_PATH}"
    echo "Initialize/update submodules (includes antidote) and try again."
    return 1
fi
export ZSH="$(antidote path ohmyzsh/ohmyzsh)"

# Load conda
if command -v conda &>/dev/null; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/liam/miniconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/liam/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/home/liam/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/liam/miniconda3/bin:${PATH}"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    if command -v mamba &>/dev/null; then
        alias condaconda='/home/liam/miniconda3/bin/conda'
        alias conda=mamba
    fi
fi

# Custom pip completion
_pip_completion() {
    local words cword
    read -cA words
    read -cn cword
    reply=($(COMP_WORDS="$words[*]" \
        COMP_CWORD=$((cword - 1)) \
        PIP_AUTO_COMPLETE=1 $words[1]))
}
compctl -K _pip_completion pip _pip3_completion pip3

autoload -Uz $fpath[1]/*(.:t)

# User configuration

setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt AUTO_CD

ZSH_PLUGINS_PATH="${ZDOTDIR:-${HOME}}/.zsh_plugins.txt"
[[ -f "${ZSH_PLUGINS_PATH}" ]] && antidote load "${ZSH_PLUGINS_PATH}"

source_files=(
    "${HOME}/.fzf.zsh"
    "${WORKSTATION_DIR}/src/fzf/shell/key-bindings.zsh"
    "${CONFIG_DIR}/fzf/config"

    "${WORKSTATION_DIR}/src/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh"
    "${WORKSTATION_DIR}/src/fzf-git/fzf-git.sh"
    "${WORKSTATION_DIR}/src/pip-fzf/pip_fzf.sh"
)
for source_file in "${source_files[@]}"; do
    if [[ -f "${source_file}" ]]; then
        source "${source_file}"
    else
        echo "File not found: ${source_file}"
    fi
done

() {
    local -a prefix=( '\e'{\[,O} )
    local -a up=( ${^prefix}A ) down=( ${^prefix}B )
    local key=
    for key in $up[@]; do
        bindkey "$key" up-line-or-history
    done
    for key in $down[@]; do
        bindkey "$key" down-line-or-history
    done
}

# autoload history-search-end
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bindkey "^P" history-beginning-search-backward-end
# bindkey "^N" history-beginning-search-forward-end

bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

#################################################

autoload -Uz compinit && compinit

if ! command -v zoxide &>/dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
eval "$(zoxide init zsh)" || echo "zoxide init failed"

if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)" || echo "starship init failed"
