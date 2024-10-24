# -------------------------------------------------------------------
# Basic Aliases
# -------------------------------------------------------------------

# show the command history with timestamps
alias his='history -i'

# Short hand for 'exit' like Vim ❤️
alias :q='exit'

# Short hand for 'source'
alias so='source'

# -------------------------------------------------------------------
# cd Command
# -------------------------------------------------------------------

alias cd2='cd ../..'
alias cd3='cd ../../..'

# -------------------------------------------------------------------
# ls Command
# -------------------------------------------------------------------

# Shortcut for ls
alias l='ls -Fh'
# Showing hidden files
alias la='ls -Fha'

# -------------------------------------------------------------------
# Vim and Neovim
# -------------------------------------------------------------------

# Shortcut for nvim
alias v='nvim'
alias vi='vim'

# -------------------------------------------------------------------
# df Command
#
# change default to display disk space usage
# for all file systems and show sizes in kilobytes
# -------------------------------------------------------------------

alias df='df -kh'

# -------------------------------------------------------------------
# du Command
#
# change default to estimate file and directory space usage
# and show sizes in kilobytes
# -------------------------------------------------------------------

alias du='du -kh'

# -------------------------------------------------------------------
# Terraform
# -------------------------------------------------------------------

alias tf='terraform'
