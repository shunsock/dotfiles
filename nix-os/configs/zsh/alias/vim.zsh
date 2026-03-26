alias vi='vim'
alias nvim='vim'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.config/nvimc/default/share":/root/.local/share/nvim \
  -v "$HOME/.config/nvimc/default/cache":/root/.cache/nvim \
  -v "$HOME/.config/nvimc/default/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/nvimc:default-amd-0.0.5'
