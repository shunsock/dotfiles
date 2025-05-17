## NvimContainer

### build

```shell
docker build -t nvimc .
```

### Run

```shell
docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc/share":/home/devuser/.local/share/nvim \
  -v "$HOME/.nvimc/cache":/home/devuser/.cache/nvim \
  -v "$HOME/.nvimc/state":/home/devuser/.local/state/nvim \
  -w /workspace \
  nvimc

```

