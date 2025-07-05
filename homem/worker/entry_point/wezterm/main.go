package main

import (
	"worker/internal/updater"
)

func main() {
	updater.UpdateDirectory(
		// weztermの設定ディレクトリを呼び出す
		"../configs/wezterm",
		// 既存の設定ディレクトリがあれば消す
		"$HOME/.config/wezterm",
		// 設定を置く場所
		"$HOME/.config/",
	)
}
