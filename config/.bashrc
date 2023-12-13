#!/bin/bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
source "${HOME}/.bash_history_config"

echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"
echo "############################################################"

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot-}" ] && [ -r "/etc/debian_chroot" ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

########### Autocompletion:
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f "/usr/share/bash-completion/bash_completion" ]; then
		. "/usr/share/bash-completion/bash_completion"
	elif [ -f "/etc/bash_completion" ]; then
		. "/etc/bash_completion"
	fi
fi

# region Conda Setup

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/liam/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/liam/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/liam/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/liam/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# region Python-related Autocomplete

CONDA_ROOT="$HOME/miniconda3" # <- set to your Anaconda/Miniconda installation directory
if [[ -r "$CONDA_ROOT/etc/profile.d/bash_completion.sh" ]]; then
	source "$CONDA_ROOT/etc/profile.d/bash_completion.sh"
else
	echo "WARNING: could not find conda-bash-completion setup script"
fi
eval "$(pip completion --bash)"

source /home/liam/.bash_completions/nbpreview.sh
# endregion Python-related Autocomplete

# endregion Conda Setup

source "$HOME/.bash_profile"
[[ -f "${HOME}/.fzf.bash" ]] && source "${HOME}/.fzf.bash"

#################################################
############# Start Starship Prompt #############
#################################################

eval "$(starship init bash)"
