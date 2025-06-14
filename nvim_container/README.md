## NvimContainer

### build

```shell
docker build -t nvimc .
```

### Run

```shell
docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc/state":/root/.local/state/nvim \
  -w /workspace \
  nvimc
```

