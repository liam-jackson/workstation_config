#!/bin/bash
exit 0

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
