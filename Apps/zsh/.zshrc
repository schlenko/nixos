typeset -A ZSH_HIGHLIGHT_STYLES

# Commands
ZSH_HIGHLIGHT_STYLES[arg0]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=yellow,bold'

# Invalid / unknown commands
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=yellow,bold'

# Paths
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'

# Arguments
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'

# Comments
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'