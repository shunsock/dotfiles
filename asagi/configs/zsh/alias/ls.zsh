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

