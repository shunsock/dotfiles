# pyenv が存在するならinit

if [ -d "$HOME/.pyenv" ]; then
  echo "pyenv dir is found! running pyenv init ..."
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
fi
