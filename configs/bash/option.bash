# History
shopt -s histappend
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND:-}"
HISTCONTROL=ignoredups

# Silence
bind 'set bell-style none'

# glob
shopt -s extglob  # extended pattern matching
shopt -s nullglob # no-match glob expands to empty

# Completion
shopt -s autocd
