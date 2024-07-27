

# Shell customization
HISTSIZE=20
HISTFILESIZE=20
export HISTCONTROL="ignoreboth"

export SYSTEMD_PAGER=

# My aliiases
[[ -f ~/.aliases ]] && . ~/.aliases

# Cool shell prompt
command -v starship &> /dev/null && eval "$(starship init bash)"
