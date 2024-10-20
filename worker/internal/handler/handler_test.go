package handler_test

import (
	"os"
	"path/filepath"
	"testing"
	"worker/internal/handler"
	"worker/internal/path"
)

// setupFixture: テスト用のディレクトリとファイルを作成するフィクスチャ
func setupFixture(t *testing.T) (string, string) {
	// ソースディレクトリを作成
	srcDir := t.TempDir()

	// ソースディレクトリにファイルを作成
	srcFile := filepath.Join(srcDir, "testfile.txt")
	err := os.WriteFile(srcFile, []byte("test content"), 0644)
	if err != nil {
		t.Fatalf("ソースファイルの作成に失敗しました: %v", err)
	}

	// コピー先のディレクトリ（まだ存在しない）
	dstDir := filepath.Join(t.TempDir(), "copydir")

	return srcDir, dstDir
}

// teardownFixture: テスト終了後のクリーンアップ
func teardownFixture(t *testing.T, dirPath string) {
	// ディレクトリとその中のすべてのファイルを削除
	err := os.RemoveAll(dirPath)
	if err != nil {
		t.Errorf("ディレクトリの削除に失敗しました: %v", err)
	}
}

// TestCopyRecursive: ディレクトリの再帰的コピーのテスト
func TestCopyRecursive(t *testing.T) {
	// フィクスチャをセットアップ
	srcDir, dstDir := setupFixture(t)
	defer teardownFixture(t, dstDir) // テスト後にコピー先ディレクトリを削除

	// DirectoryPath を初期化
	srcDirPath := &path.DirectoryPath{}
	err := srcDirPath.Initialize(srcDir)
	if err != nil {
		t.Fatalf("ソースディレクトリの初期化に失敗しました: %v", err)
	}

	// dstDirPath は存在しないので初期化は不要
	dstDirPath := &path.DirectoryPath{Path: dstDir}

	// ディレクトリをコピー
	dh := &handler.DirectoryHandler{}
	err = dh.CopyRecursive(srcDirPath, dstDirPath)
	if err != nil {
		t.Fatalf("ディレクトリのコピーに失敗しました: %v", err)
	}

	// コピーされたファイルが存在するか確認
	copiedFile := filepath.Join(dstDir, "testfile.txt")
	_, err = os.Stat(copiedFile)
	if os.IsNotExist(err) {
		t.Fatalf("ファイルがコピーされていません")
	}
}

// TestRemoveRecursive: ディレクトリの再帰的削除のテスト
func TestRemoveRecursive(t *testing.T) {
	// フィクスチャをセットアップ
	srcDir, _ := setupFixture(t) // dstDir は使わない
	defer teardownFixture(t, srcDir) // テスト後にソースディレクトリを削除

	// DirectoryPath を初期化
	dirPath := &path.DirectoryPath{}
	err := dirPath.Initialize(srcDir)
	if err != nil {
		t.Fatalf("ディレクトリの初期化に失敗しました: %v", err)
	}

	// ディレクトリを削除
	dh := &handler.DirectoryHandler{}
	err = dh.RemoveRecursive(dirPath)
	if err != nil {
		t.Fatalf("ディレクトリの削除に失敗しました: %v", err)
	}

	// ディレクトリが削除されたか確認
	_, err = os.Stat(srcDir)
	if !os.IsNotExist(err) {
		t.Fatalf("ディレクトリが削除されていません")
	}
}

// TestCreateDirectory tests the Create method
func TestCreateDirectory(t *testing.T) {
	dirPath := &path.NonExistentDirectoryPath{}
	err := dirPath.Initialize("/tmp/testdir")

	dh := &handler.DirectoryHandler{}
	err = dh.Create(dirPath)
	if err != nil {
		t.Fatalf("ディレクトリ作成に失敗しました: %v", err)
	}

	// ディレクトリが存在するか確認
	_, err = os.Stat("/tmp/testdir")
	if os.IsNotExist(err) {
		t.Fatalf("ディレクトリが作成されていません")
	}

	// 後処理
	os.RemoveAll("/tmp/testdir")
}
