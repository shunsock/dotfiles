# dotfiles
This Repository is config files updater which I often use with my work.

## Screen Shot

![screen shot](./images/screen_shot.png)

## Architecture
This is project directory architecture.

```shell
.
├── Makefile
├── README.md
├── configs
│   ├── nvim
│   │   ├── init.lua
│   │   └── lua
│   ├── wezterm
│   │   └── wezterm.lua
│   └── zsh
│       └── config
├── images
│   └── screen_shot.png
├── tests
│   └── FileCopierTest.php
├── tmp
└── worker
    ├── ConfigUpdater.php
    ├── FileCopier.php
    ├── FileCreator.php
    ├── FileRemover.php
    ├── Messenger.php
    ├── fonts_downloader.sh
    ├── nvim_update_worker.php
    ├── wezterm_update_worker.php
    └── zsh_update_worker.php

11 directories, 15 files
```

- `Makefile`: run command
- `worker`: PHP files to update setting files
- `worker/font_downloader.sh`: Font downloader (will be replaced by PHP)
- `tests`: PHP test file
- `configs`: config files


## Setting Files
### Neovim
neovim settings are in `./configs/nvim`.

before using following command, check if you've already install [jetpack](curl -fLo ~/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim)

```shell
curl -fLo ~/.local/share/nvim/site/pack/jetpack/opt/vim-jetpack/plugin/jetpack.vim --create-dirs https://raw.githubusercontent.com/tani/vim-jetpack/master/plugin/jetpack.vim
```

```shell
make nvim  # call `php worker/nvim_update_worker.php`
```

### Wezterm
neovim settings are in `./configs/wezterm`.

```shell
make wezterm  # call `php worker/nvim_update_worker.php`
```

### Zsh
neovim settings are in `./configs/zsh`.

```shell
make zsh  # call `php worker/nvim_update_worker.php`
```
