# nodenv が存在するならinit

if [ -d "$HOME/.nodenv" ]; then
  echo "nodenv dir is found! running nodenv init ..."
  eval "$(nodenv init -)"
fi
