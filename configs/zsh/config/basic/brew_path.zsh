# PATH SETTING #
# * add path path to home brew
# typeset -Ug : deal with path as set of PATH
# N-/         : add path when the path exists
typeset -gU path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)
