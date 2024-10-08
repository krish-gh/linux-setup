# shellcheck disable=SC2148

# ~custom-setup~
# Shell customization
HISTSIZE=20
HISTFILESIZE=20
export HISTCONTROL="ignoreboth"
export SYSTEMD_PAGER=
export PATH="$PATH:~/.local/bin"

# My aliiases
# shellcheck disable=SC1090
[[ -f ~/.aliases ]] && . ~/.aliases

# Cool shell prompt
command -v starship &> /dev/null && eval "$(starship init bash)"
