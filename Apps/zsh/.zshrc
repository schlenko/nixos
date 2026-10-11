typeset -A ZSH_HIGHLIGHT_STYLES
source "$HOME/.oh-my-zsh/custom/themes/crcandy.zsh-theme"

# Commands
ZSH_HIGHLIGHT_STYLES[arg0]='fg=141'
ZSH_HIGHLIGHT_STYLES[command]='fg=141'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=135'
ZSH_HIGHLIGHT_STYLES[alias]='fg=135'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=177,bold'

# Invalid / unknown commands
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=163,bold'

# Paths
ZSH_HIGHLIGHT_STYLES[path]='fg=99'

# Arguments
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=183'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=183'

# Comments
ZSH_HIGHLIGHT_STYLES[comment]='fg=97'

# Notify on `sudo nixos-rebuild ...`; everything else goes to the real sudo
sudo() {
  if [[ "$1" == nixos-rebuild ]]; then
    shift
    nixos-rebuild-notify "$@"
  else
    command sudo "$@"
  fi
}

