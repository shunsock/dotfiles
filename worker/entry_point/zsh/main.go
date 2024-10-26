package main

import (
  "worker/internal/updater"
)

func zsh_config_update() {
  updater.UpdateDirectory(
    // 更新に使う設定ディレクトリ
    "../configs/zsh/config",
    // 既存の設定ディレクトリ
    "$HOME/.zsh/config",
    // 設定を置く場所
    "$HOME/.zsh/",
  )
}

func zshrc_update() {
  updater.UpdateFile(
    // 既存の設定ファイル
    "$HOME/.zshrc",
    // 更新に使う設定ファイル
    "../configs/zsh/.zshrc",
    // 設定を置く場所
    "$HOME/",
  )
}

func main() {
  zsh_config_update()
  zshrc_update()
}

