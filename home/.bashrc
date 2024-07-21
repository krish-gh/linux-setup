

# Shell customization
HISTSIZE=20
HISTFILESIZE=20
export HISTCONTROL="erasedups:ignorespace"

# Mimic Zsh run-help ability
#run-help() { help "$READLINE_LINE" 2>/dev/null || man "$READLINE_LINE"; }
#bind -m vi-insert -x '"\eh": run-help'
#bind -m emacs -x     '"\eh": run-help'

export SYSTEMD_PAGER=

# My aliiases
[[ -f ~/.aliases ]] && . ~/.aliases

# Cool shell prompt
command -v starship &> /dev/null && eval "$(starship init bash)"
