alias vi='vim'
alias nvim='vim'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.akatsuki-default/share":/root/.local/share/nvim \
  -v "$HOME/.akatsuki-default/cache":/root/.cache/nvim \
  -v "$HOME/.akatsuki-default/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/akatsuki:default-arm-0.0.2'
alias vpy='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.akatsuki-python/share":/root/.local/share/nvim \
  -v "$HOME/.akatsuki-python/cache":/root/.cache/nvim \
  -v "$HOME/.akatsuki-python/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/akatsuki:python-0.0.2'

