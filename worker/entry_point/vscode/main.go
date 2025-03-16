package main

import (
	"worker/internal/updater"
)

func main() {
	updater.UpdateFile(
		// 既存の設定ファイル
		"$HOME/Library/Application Support/Code/User/settings.json",
		// 更新に使う設定ファイル
		"../configs/vscode/settings.json",
		// 設定を置く場所
		"$HOME/Library/Application Support/Code/User",
	)
}
