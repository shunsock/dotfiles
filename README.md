# dotfiles

## Architecture
This is project directory architecture.

```shell
.
├── Makefile
├── README.md
├── handler
│   ├── FileCopier.php
│   ├── FileCreator.php
│   ├── FileRemover.php
│   ├── Messenger.php
│   └── nvim_update_worker.php
└── nvim
    ├── init.lua
    └── lua
```

- `Makefile`: run command
- `handler`: PHP files to update setting files


## Setting Files
### Neovim
neovim settings are in `./nvim`.

```shell
make nvim_update  # call `php handler/nvim_update_worker.php`
```