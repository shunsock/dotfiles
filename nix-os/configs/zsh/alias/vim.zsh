alias vi='vim'
alias nvim='vim'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.neovim-docker-default/share":/root/.local/share/nvim \
  -v "$HOME/.neovim-docker-default/cache":/root/.cache/nvim \
  -v "$HOME/.neovim-docker-default/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/neovim-docker:default-amd-0.0.2'
