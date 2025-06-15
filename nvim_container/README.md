## NvimContainer


## Getting Started

### Pull From Repository

```
docker pull tsuchiya55docker/nvimc:v0.0.2
docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc/state":/root/.local/state/nvim \
  -w /workspace \
  tsuchiya55docker/nvimc:v0.0.2
```

### Build by Your Self

```shell
docker build -t nvimc .
docker run -it --rm \
  -v "$PWD":/workspace \
  -v "$HOME/.nvimc/share":/root/.local/share/nvim \
  -v "$HOME/.nvimc/cache":/root/.cache/nvim \
  -v "$HOME/.nvimc/state":/root/.local/state/nvim \
  -w /workspace \
  nvimc
```

