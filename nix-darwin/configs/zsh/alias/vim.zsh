alias vi='vim'
alias nvim='vim'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc-default/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc-default/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc-default/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/nvimc:default-arm-0.0.2'
alias vpy='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc-python/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc-python/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc-python/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/nvimc:python-0.0.2'

