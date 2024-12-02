package handler

import (
	"os"
)

// PathChecker pathChecker は、指定されたパスが存在するかを確認し、エラーも返します。
func PathChecker(path string) (bool, error) {
	// 環境変数の展開 (例: $HOME)
	expandedPath := os.ExpandEnv(path)

	_, err := os.Stat(expandedPath)
	if os.IsNotExist(err) {
		// パスが存在しない場合は false と nil（エラーなし）を返す
		return false, nil
	}
	if err != nil {
		// それ以外のエラーが発生した場合は false とそのエラーを返す
		return false, err
	}
	// パスが存在する場合は true と nil（エラーなし）を返す
	return true, nil
}
