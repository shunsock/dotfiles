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
alias date='date +"%Y-%m-%dT%H:%M:%S%:%z"'

# -------------------------------------------------------------------
# cd Command
# -------------------------------------------------------------------

# I want to use this alias (in progress)
alias .='cd ../'
alias ..='cd ../../'
alias ...='cd ../../../'

# I am going to delete this alias. I will use ☝️ instead.
alias cd2='cd ../..'
alias cd3='cd ../../..'

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

alias l='ls -Fh'

# Showing hidden files
alias la='ls -Fha'

# -------------------------------------------------------------------
# Vim and Neovim
# -------------------------------------------------------------------

alias vim='nvim'
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

