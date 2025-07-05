package handler_test

import (
	"os"
	"testing"
	"worker/internal/handler"
)

func TestPathChecker_PathPathChecker(t *testing.T) {
	tempDir := t.TempDir()

	exists, err := handler.PathChecker(tempDir)
	if err != nil {
		t.Fatalf("エラーが発生しました: %v", err)
	}
	if !exists {
		t.Errorf("存在するディレクトリを検出できませんでした: %v", tempDir)
	}
}

func TestPathChecker_PathNotPathChecker(t *testing.T) {
	nonExistentPath := "/non/existing/path"

	exists, err := handler.PathChecker(nonExistentPath)
	if err != nil {
		t.Fatalf("エラーが発生しました: %v", err)
	}
	if exists {
		t.Errorf("存在しないパスを誤って検出しました: %v", nonExistentPath)
	}
}

func TestPathChecker_FilePathChecker(t *testing.T) {
	tempFile, err := os.CreateTemp("", "testfile")
	if err != nil {
		t.Fatalf("一時ファイルの作成に失敗しました: %v", err)
	}
	defer os.Remove(tempFile.Name())

	exists, err := handler.PathChecker(tempFile.Name())
	if err != nil {
		t.Fatalf("エラーが発生しました: %v", err)
	}
	if !exists {
		t.Errorf("存在するファイルを検出できませんでした: %v", tempFile.Name())
	}
}
