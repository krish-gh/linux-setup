

# Shell customization
HISTSIZE=20
HISTFILESIZE=20

export SYSTEMD_PAGER=

# My aliiases
[[ -f ~/.aliases ]] && . ~/.aliases

# Cool shell prompt
eval "$(starship init bash)"
