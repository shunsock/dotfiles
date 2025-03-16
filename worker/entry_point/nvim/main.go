package main

import (
	"worker/internal/updater"
)

func main() {
	updater.UpdateDirectory(
		// これから設定ファイルとするディレクトリ
		"../configs/nvim",
		// 既存の設定ディレクトリがあれば消す
		"$HOME/.config/nvim",
		// 設定を置く場所
		"$HOME/.config/",
	)
}
