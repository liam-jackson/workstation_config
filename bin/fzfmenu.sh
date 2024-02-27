#!/usr/bin/zsh

export FZF_DEFAULT_OPTS="
--height=100%
--layout=reverse
--border
--no-sort
--prompt=\" ~ fzf menu ~ \"
--color=dark,hl:red:regular,fg+:white:regular,hl+:red:regular:reverse,query:white:regular,info:gray:regular,prompt:red:bold,pointer:red:bold"

exec alacritty --class="fzf-menu" -e bash -c "fzf-tmux -m $* < /proc/$$/fd/0 | awk 'BEGIN {ORS=\" \"} {print}' > /proc/$$/fd/1"
# For st instead
# st -c fzf-menu -n fzf-menu -e bash -c "fzf-tmux -m $* < /proc/$$/fd/0 | awk 'BEGIN {ORS=\" \"} {print}' > /proc/$$/fd/1"
