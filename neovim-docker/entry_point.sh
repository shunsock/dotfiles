CONTAINER="$1"
TARGET="$2"
if [ -z "$TARGET" ]; then
    TARGET="$PWD"
fi

docker run -it --rm \
  -v "$TARGET":/workspace \
  -v "$HOME/.neovim-docker-$CONTAINER/share":/root/.local/share/nvim \
  -v "$HOME/.neovim-docker-$CONTAINER/cache":/root/.cache/nvim \
  -v "$HOME/.neovim-docker-$CONTAINER/state":/root/.local/state/nvim \
  -w /workspace \
  "${CONTAINER}" "$TARGET"
