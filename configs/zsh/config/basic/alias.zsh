# Alias 'his' to show the command history with timestamps
alias his='history -i'

# Alias 'cd2' to go up two directories
alias cd2='cd ../..'
# Alias 'cd3' to go up three directories
alias cd3='cd ../../..'

# Alias 'so' to source a file, which executes commands from that file in the current shell
alias so='source'

# Alias 'l' to list files in a directory, showing file types and sizes in human-readable format
alias l='ls -Fh'
# Alias 'la' to list all files (including hidden ones), showing file types and sizes in human-readable format
alias la='ls -Fha'
# Alias 'll' to list all files with detailed information (including file permissions, number of links, owner, group, size, and timestamp), showing sizes in human-readable format
alias ll='ls -Fhaln'
# Alias 'lls' to list all files sorted by size, showing detailed information and sizes in human-readable format
alias lls='ls -FhalnS'
# Alias 'lk' to list files showing sizes in kilobytes
alias lk='ls -Fhk'

# Alias 'v' to open files with the Vim text editor
alias v='nvim'
# Alias 'vi' to open files with the Vim text editor
alias vi='nvim'

# Alias 'df' to display disk space usage for all file systems, showing sizes in kilobytes
alias df='df -kh'
# Alias 'du' to estimate file and directory space usage, showing sizes in kilobytes
alias du='du -kh'

