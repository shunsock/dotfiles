# terraform env が存在するならPathに追加

if [ -d "$HOME/.tfenv" ]; then
  echo "tfenv dir is found! adding ~/.tfenv to PATH ..."
  export PATH="$HOME/.tfenv/bin:$PATH"
fi
