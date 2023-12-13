#!/bin/bash
# ~/.bash_aliases

#################################################
############### Alias Definitions ###############
#################################################

alias cat='bat'

alias ll='ls -lAF --color=auto'
alias lt='ls -lAF --sort=time --color=auto'
alias ltr='ls -lAF --sort=time --reverse --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias rm='echo "rm is disabled, use trash or /bin/rm instead."'

alias open="xdg-open"

alias show_funcs="declare -F"

alias binvox='${HOME}/Workspace/tenbeauty/ROM_analysis_pipeline/binvox'
alias matlab='$MATLAB_ROOT/bin/matlab'
alias python='python3'
alias untar='tar -x -f'

function fzfp() {
    fzf \
        --preview \
        "$(
            if file --mime-type {} | grep -qF image/; then
                echo 'kitty icat --clear --transfer-mode=memory --stdin=no --place"=${FZF_PREVIEW_COLUMNS"}"x${FZF_PREVIEW_LINES"}@0x0 {} | sed \$d'
            else
                echo 'bat --color=always {}'
            fi
        )"
}
_fzf_complete_fzfp() {
    _fzf_complete_fzf "$@"
}
alias ffind="find . | fzfp"
_fzf_complete_ffind() {
    _fzf_complete_find "$@"
}

# alias tnn='tilix -e nnn'

alias pbcopy="xsel --clipboard --input"
_fzf_complete_pbcopy() {
    echo "completing pbcopy"
    _fzf_complete_xsel "$@"
}
alias pbpaste="xsel --clipboard --output"
_fzf_complete_pbpaste() {
    _fzf_complete_xsel "$@"
}

alias copydir='pwd | pbcopy'

alias numlines="wc --lines"
_fzf_complete_numlines() {
    _fzf_complete_wc "$@"
}
alias numwords="wc --words"
_fzf_complete_numwords() {
    _fzf_complete_wc "$@"
}
alias numchars="wc --chars"
_fzf_complete_numchars() {
    _fzf_complete_wc "$@"
}

# alias xterm="xterm -ti vt340"

alias wscfg='code $HOME/workstation_config/.'
_fzf_complete_wscfg() {
    _fzf_complete_code "$@"
}

alias watchdir='watch -n 1 --color tree --prune -C'
_fzf_complete_watchdir() {
    _fzf_complete_watch "$@"
}

alias frf='${HOME}/workstation_config/bin/rfv.sh'
alias fapt='${HOME}/workstation_config/bin/pkgsearch.sh'
alias menu='${HOME}/workstation_config/bin/fzfmenu.sh'
alias src='source ${HOME}/.zshrc'
