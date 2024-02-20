#!/bin/bash

#################################################
############### Alias Definitions ###############
#################################################

alias cat='bat'

alias gss="git status"
alias gsu="git status -uno"

alias ll='ls -lAF --color=auto'
alias lt='ls -lAF --sort=time --color=auto'
alias ltr='ls -lAF --sort=time --reverse --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

alias el='exa --all --long --header --icons'
alias elt='exa --all --long --header --icons --sort=time'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rm='echo "rm is disabled, use trash or /bin/rm instead."'

alias open="xdg-open"

alias matlab='$MATLAB_ROOT/bin/matlab'
alias python='python3'
alias untar='tar -x -f'

alias nalalistup='sudo nala list --upgradable'
alias nalaupall='sudo nala upgrade --fix-broken --full --install-recommends --install-suggests --update'

# alias tnn='tilix -e nnn'

alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

alias copydir='pwd | pbcopy'

alias numlines="wc --lines"
alias numwords="wc --words"
alias numchars="wc --chars"

# alias xterm="xterm -ti vt340"

alias wscfg='code ${HOME}/workstation_config/workstation_config.code-workspace'

alias watchdir='watch -n 1 --color tree --prune -C'

alias frf='${HOME}/workstation_config/bin/rfv.sh'
alias fapt='${HOME}/workstation_config/bin/pkgsearch.sh'
alias menu='${HOME}/workstation_config/bin/fzfmenu.sh'

alias src='source ${HOME}/.zshrc'
