alias vi='vim'
alias nvim='vim'

v() {
  local target="${1:-.}"
  local mount_dir
  local nvim_args=()

  if [ -d "$target" ]; then
    mount_dir="$(cd "$target" && pwd)"
  elif [ -f "$target" ]; then
    mount_dir="$(cd "$(dirname "$target")" && pwd)"
    nvim_args=("$(basename "$target")")
  else
    mount_dir="$(cd "$(dirname "$target")" 2>/dev/null && pwd)" || mount_dir="$PWD"
    nvim_args=("$(basename "$target")")
  fi

  docker run -it --rm \
    -v "$mount_dir":/workspace \
    -v "$HOME/.config/nvimc/default/share":/root/.local/share/nvim \
    -v "$HOME/.config/nvimc/default/cache":/root/.cache/nvim \
    -v "$HOME/.config/nvimc/default/state":/root/.local/state/nvim \
    -w /workspace \
    tsuchiya55docker/nvimc:default-amd-0.1.0 "${nvim_args[@]}"
}
