#!/usr/bin/zsh
# echo "entered .zshrc"

# zmodload zsh/zprof

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

DBG_STARTUP=0
if [[ ${DBG_STARTUP} == 1 ]]; then
    trash "${HOME}/keymap_zshrc.txt"
    trash "${HOME}/cur_keymap_zshrc.txt"
    trash "${HOME}/new_keymap_zshrc.txt"
fi

bindkey_writer() {
    if [[ ${DBG_STARTUP} == 0 ]]; then
        return 0
    else
        echo "DBG_STARTUP is set. Running bindkey_writer."
    fi

    # Check if argument is provided
    if [ $# -ne 1 ]; then
        echo "Usage: bindkey_writer <description>"
        return 1
    fi

    local file_path="${HOME}/keymap_zshrc.txt"
    local cur_keymap="${HOME}/cur_keymap_zshrc.txt"
    local new_keymap="${HOME}/new_keymap_zshrc.txt"

    # Capture current keybinds
    if ! [[ -f "${cur_keymap}" ]]; then
        echo "Creating current keybinds file..."
        bindkey >"${cur_keymap}"
        return 0
    else
        bindkey >"${new_keymap}"
    fi


    # Compare with previous log and find differences
    echo "Comparing with previous keybinds..."
    local new_binds=$(comm -13 <(sort "${cur_keymap}") <(sort "${new_keymap}"))
    local missing_binds=$(comm -23 <(sort "${cur_keymap}") <(sort "${new_keymap}"))

    # Log the differences
    {
        if [[ ! -z "${new_binds}" ]] || [[ ! -z "${missing_binds}" ]]; then
            echo "$1" >>"${file_path}"

            if [[ ! -z "${new_binds}" ]]; then
                echo "New keybinds:" >>"${file_path}"
                echo "${new_binds}" >>"${file_path}"
            fi

            if [[ ! -z "${missing_binds}" ]]; then
                echo "Missing keybinds:" >>"${file_path}"
                echo "${missing_binds}" >>"${file_path}"
            fi
            echo "" >>"${file_path}"
        fi
    } || {
        echo "Error writing to ${file_path}. Check permissions or path."
        return 2
    }
    cp "${new_keymap}" "${cur_keymap}"
}

# User configuration
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt AUTO_CD

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# ZDOTDIR="${CONFIG_DIR:-${HOME}/.config}/zsh"
# ZSH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"

# Clone antidote if necessary.
ANTIDOTE_DIR="${ZDOTDIR:-${HOME}}/.antidote"
[[ -d "${ANTIDOTE_DIR}" ]] ||
    git clone https://github.com/mattmc3/antidote "${ANTIDOTE_DIR}"

ANTIDOTE_PATH="${ANTIDOTE_DIR}/antidote.zsh"
if [[ -f "${ANTIDOTE_PATH}" ]]; then
    source "${ANTIDOTE_PATH}"
    bindkey_writer "antidote"
else
    echo "Antidote not found at ${ANTIDOTE_PATH}"
    echo "Initialize/update submodules (includes antidote) and try again."
    return 1
fi
autoload -Uz compinit && compinit

# Load the default completion system (considers "--help" output)
# [note: must call after compinit]
compdef _gnu_generic -default- -P '*'
bindkey_writer "compdef"

# History settings
if [[ -f "${ZDOTDIR}/.zsh_history_config" ]]; then
    source "${ZDOTDIR}/.zsh_history_config"
    bindkey_writer "historycfg"
fi

# Autoload functions you might want to use with antidote.
export ZFUNCDIR="${ZDOTDIR}/.zfunc"
[[ -d "${ZFUNCDIR}" ]] && fpath=("${ZFUNCDIR}" $fpath)

# Adding to fpath
fpath_additions=(
    "${WORKSTATION_DIR}/src/eza/completions/zsh",
)
for fpath_addition in "${fpath_additions[@]}"; do
    [[ -e "${fpath_addition}" ]] && fpath=("${fpath_addition}" $fpath)
done

# Source zstyles you might use with antidote.
ZSTYLES_PATH="${ZDOTDIR}/.zstyles"
[[ -f "${ZSTYLES_PATH}" ]] && source "${ZSTYLES_PATH}" && bindkey_writer "zstyles"

# Load conda
export CONDARC="${CONFIG_DIR}/conda/.condarc"
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/miniforge3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/miniforge3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/miniforge3/bin:${PATH}"
    fi
fi
unset __conda_setup

if [ -f "${HOME}/miniforge3/etc/profile.d/mamba.sh" ]; then
    . "${HOME}/miniforge3/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<
if command -v mamba &>/dev/null; then
    alias condaconda="${HOME}/miniforge3/bin/conda"
    alias conda=mamba
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
bindkey_writer "autoload"

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
        bindkey_writer ""$(basename ${source_file})""
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

bindkey -s '\e[1;5D' '\eb'
bindkey -s '\e[1;5C' '\ef'

compinit && bindkey_writer "compinit"



ZSH_PLUGINS_PATH="${ZDOTDIR:-${HOME}}/.zsh_plugins.txt"
if [[ -f "${ZSH_PLUGINS_PATH}" ]]; then
    antidote load "${ZSH_PLUGINS_PATH}"
    bindkey_writer "antidote_load"
else
    echo "No zsh plugins file found at ${ZSH_PLUGINS_PATH}"
fi

#################################################

if ! command -v zoxide &>/dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi
eval "$(zoxide init zsh --cmd cd)" || echo "zoxide init failed"
bindkey_writer "zoxide"

if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init zsh)" || echo "starship init failed"
bindkey_writer "starship"

unset DBG_STARTUP
