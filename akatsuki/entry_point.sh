CONTAINER="$1"
TARGET="$2"
if [ -z "$TARGET" ]; then
    TARGET="$PWD"
fi

docker run -it --rm \
  -v "$TARGET":/workspace \
  -v "$HOME/.akatsuki-$CONTAINER/share":/root/.local/share/nvim \
  -v "$HOME/.akatsuki-$CONTAINER/cache":/root/.cache/nvim \
  -v "$HOME/.akatsuki-$CONTAINER/state":/root/.local/state/nvim \
  -w /workspace \
  "${CONTAINER}" "$TARGET"
