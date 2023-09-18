#!/bin/bash
# ~/.bash_aliases

#################################################
############### Alias Definitions ###############
#################################################

alias cat='bat --paging=auto --color=auto'

alias ll='ls -lAF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rm='echo "rm is disabled, use trash or /bin/rm instead."'

alias open="xdg-open"

alias show_funcs="declare -F"

alias matlab="$MATLAB_ROOT/bin/matlab"

alias fzfpreview="fzf --preview 'bat --color=always --style=numbers {}'"
alias findfzf="find . | fzfpreview"

alias tnn='tilix -e nnn'

alias wscfg="code $HOME/workstation-config/."

eval "$(thefuck --alias)"
