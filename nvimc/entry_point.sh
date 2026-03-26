CONTAINER="$1"
TARGET="$2"
if [ -z "$TARGET" ]; then
    TARGET="$PWD"
fi

NVIMC_DATA_DIR="$HOME/.config/nvimc/$CONTAINER"

docker run -it --rm \
  -v "$TARGET":/workspace \
  -v "$NVIMC_DATA_DIR/share":/root/.local/share/nvim \
  -v "$NVIMC_DATA_DIR/cache":/root/.cache/nvim \
  -v "$NVIMC_DATA_DIR/state":/root/.local/state/nvim \
  -w /workspace \
  "${CONTAINER}" "$TARGET"
