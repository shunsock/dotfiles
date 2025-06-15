alias dcm='docker compose'
alias dcmd='docker compose down'
alias dimg='docker image'
alias dprune='docker system prune -f'
alias drmi='docker rmi -f'
alias v='docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/nvimc:v0.0.2'

