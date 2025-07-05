package main

import (
	"worker/internal/updater"
)

func main() {
	updater.UpdateDirectory(
		// 設定するディレクトリを呼び出す
		"../configs/nix",
		// 既存の設定ディレクトリがあれば消す
		"$HOME/.config/nix",
		// 設定を置く場所
		"$HOME/.config/",
	)
}
