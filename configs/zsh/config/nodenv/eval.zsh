# nodenv が存在するならinit

if [ -d "$HOME/.nodenv" ]; then
  echo "nodenv dir is found! running nodenv init ..."
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"
fi
