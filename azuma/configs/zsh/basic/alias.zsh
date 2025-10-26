# -------------------------------------------------------------------
# Basic Aliases
# -------------------------------------------------------------------

# 'exit' like Vim ❤️
alias :q='exit'

alias so='source'

# ⚠️ These Command require High Privileges
# Thus, automatic correction should be disabled

alias sudo='nocorrect sudo'
alias su='nocorrect su'

# date output with iso8601 format
alias date='date +"%Y-%m-%dT%H:%M:%S%z"'

# -------------------------------------------------------------------
# ls Command
# NOTE:
# -F 
#   slash (‘/’) immediately after each pathname that is a directory
#   asterisk (‘*’) after each that is executable
#   at sign (‘@’) after each symbolic link
#   equals sign (‘=’) after each socket
#   percent sign (‘%’) after each whiteout
#   vertical bar (‘|’) after each that is a FIFO.
#
# -h
#   When used with the -l option, use unit suffixes: Byte, Kilobyte, Megabyte, Gigabyte, Terabyte and Petabyte in order to reduce the number of digits to four or fewer using base 2 for sizes. This option is not defined in IEEE Std 1003.1-2008 (“POSIX.1”).
# -------------------------------------------------------------------

# Showing hidden files
alias la='ls -Fha'

unalias l
alias l='ls'

# -------------------------------------------------------------------
# Vim and Neovim
# -------------------------------------------------------------------

alias vi='vim'
alias nvim='vim'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.akatsuki-default/share":/root/.local/share/nvim \
  -v "$HOME/.akatsuki-default/cache":/root/.cache/nvim \
  -v "$HOME/.akatsuki-default/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/akatsuki:default-amd-0.0.2'

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

