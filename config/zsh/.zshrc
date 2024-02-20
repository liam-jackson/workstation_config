#!/bin/zsh
# echo "entered .zshrc"

# zmodload zsh/zprof

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# History settings
if [[ -f "${ZDOTDIR}/.zsh_history_config" ]]; then
    source "${ZDOTDIR}/.zsh_history_config"
fi

# Ensure path arrays do not contain duplicates.
typeset -gU path fpath

# Autoload functions you might want to use with antidote.
# CUST_COMP_DIR="${ZDOTDIR}/zsh/.zfunc"
# if [[ -d "${CUST_COMP_DIR}" ]]; then
#     fpath=("${CUST_COMP_DIR}" $fpath)
# fi

# ZFUNCDIR="${ZFUNCDIR:-${ZDOTDIR}/functions}"
# if [[ -d "${ZFUNCDIR}" ]]; then
#     fpath=("${ZFUNCDIR}" $fpath)
# fi
# autoload -Uz $fpath[1]/*(.:t)

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

# User configuration

# Initialize antidote's dynamic mode, which changes `antidote bundle`
# from static mode.
# source <(antidote init)

# Bundle Fish-like auto suggestions just like you would with antigen.
# antidote bundle zsh-users/zsh-autosuggestions

# Bundle extra zsh completions too.
# antidote bundle zsh-users/zsh-completions

# # Antidote doesn't have the 'use' command like antigen,
# # but instead you can accomplish the same via annotations:

# # Bundle oh-my-zsh libs and plugins with the 'path:' annotation
# antidote bundle ohmyzsh/ohmyzsh path:lib
# antidote bundle ohmyzsh/ohmyzsh path:plugins/git
# antidote bundle ohmyzsh/ohmyzsh path:plugins/git
# antidote bundle ohmyzsh/ohmyzsh path:plugins/extract
# antidote bundle ohmyzsh/ohmyzsh path:plugins/copybuffer
# antidote bundle ohmyzsh/ohmyzsh path:plugins/web-search
# antidote bundle ohmyzsh/ohmyzsh path:plugins/safe-paste

# antidote install mattmc3/zman

# # OR - you might want to load bundles with a HEREDOC.
# antidote bundle <<EOBUNDLES
#     # Bundle syntax-highlighting
#     zsh-users/zsh-syntax-highlighting

#     # Bundle OMZ plugins using annotations
#     ohmyzsh/ohmyzsh path:plugins/magic-enter

#     # Bundle with a git URL
#     https://github.com/zsh-users/zsh-history-substring-search
# EOBUNDLES

# antigen bundle esc/conda-zsh-completion

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Bundles from the default repo (robbyrussell's oh-my-zsh).
# antigen bundle git
# antigen bundle heroku
# antigen bundle pip
# antigen bundle lein
# antigen bundle command-not-found
# antigen bundle lukechilds/zsh-better-npm-completion
# antigen bundle Aloxaf/fzf-tab
# antigen bundle ytet5uy4/fzf-widgets
# antigen bundle 'NullSense/fuzzy-sys'
# antigen bundle zsh-users/zsh-autosuggestions

# Syntax highlighting bundle.
# antigen bundle zdharma-continuum/fast-syntax-highlighting

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
setopt EXTENDED_GLOB
setopt AUTO_CD

antidote load "${ZDOTDIR:-${HOME}}/.zsh_plugins.txt"

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    source "$(code --locate-shell-integration-path zsh)"
fi

if [ ${TILIX_ID} ] || [ ${VTE_VERSION} ]; then
    if [[ -f /etc/profile.d/vte.sh ]]; then
        source /etc/profile.d/vte.sh
    elif [[ -f /etc/profile.d/vte-2.91.sh ]]; then
        source /etc/profile.d/vte-2.91.sh
    else
        echo "vte.sh not found, it might need a symlink from the versioned file in the same directory."
    fi
fi

# Emulate sh source command
source_sh() {
    emulate -LR sh
    . "$@"
}

source_files=(
    "${HOME}/.fzf.zsh"
    "${CONFIG_DIR}/fzf/config"
    "${WORKSTATION_DIR}/src/fzf-git/fzf-git.sh"
    "${WORKSTATION_DIR}/src/pip-fzf/pip_fzf.sh"
    "${WORKSTATION_DIR}/src/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh"
    "${WORKSTATION_DIR}/src/fzf/shell/key-bindings.zsh"
)
for source_file in "${source_files[@]}"; do
    if [[ -f "${source_file}" ]]; then
        source "${source_file}"
    else
        echo "File not found: ${source_file}"
    fi
done

# autoload -Uz compinit && compinit

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
############# Start Starship Prompt #############
#################################################
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
else
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi
