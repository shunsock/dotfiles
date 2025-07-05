package path

import (
	"os"
	"path/filepath"
	"testing"
)

// テスト用の一時ファイルと一時ディレクトリをセットアップする
func setupTestFixture(t *testing.T) (string, string) {
	// 一時ファイルを作成
	tempFile, err := os.CreateTemp("", "testfile_*.txt")
	if err != nil {
		t.Fatalf("一時ファイルを作成できませんでした: %v", err)
	}

	// 一時ディレクトリを作成
	tempDir, err := os.MkdirTemp("", "testdir_")
	if err != nil {
		t.Fatalf("一時ディレクトリを作成できませんでした: %v", err)
	}

	return tempFile.Name(), tempDir
}

// テスト終了後にクリーンアップ
func teardownTestFixture(t *testing.T, tempFilePath string, tempDirPath string) {
	// 一時ファイルとディレクトリを削除
	err := os.Remove(tempFilePath)
	if err != nil {
		t.Errorf("一時ファイルを削除できませんでした: %v", err)
	}

	// 一時ディレクトリ内のファイルを含めて削除
	err = os.RemoveAll(tempDirPath)
	if err != nil {
		t.Errorf("一時ディレクトリを削除できませんでした: %v", err)
	}
}

func TestFilePath_Initialize(t *testing.T) {
	// 一時ファイルとディレクトリをセットアップ
	tempFilePath, tempDirPath := setupTestFixture(t)
	defer teardownTestFixture(t, tempFilePath, tempDirPath)

	// ファイルが存在する場合のテスト
	filePath := FilePath{}
	err := filePath.Initialize(tempFilePath) // 一時ファイル名を指定
	if err != nil {
		t.Errorf("ファイルが存在するはずですが、エラー: %v", err)
	}

	// 存在しないファイルを指定した場合のテスト
	err = filePath.Initialize("nonexistentfile.txt")
	if err == nil || err.Error() != "ファイルが存在しません" {
		t.Errorf("存在しないファイルのエラーメッセージが正しくありません: %v", err)
	}

	// ディレクトリを指定した場合のテスト
	err = filePath.Initialize(tempDirPath) // 一時ディレクトリを指定
	if err == nil || err.Error() != "指定されたパスはディレクトリです" {
		t.Errorf("ディレクトリをファイルとして指定した場合のエラーメッセージが正しくありません: %v", err)
	}
}

func TestDirectoryPath_Initialize(t *testing.T) {
	// 一時ファイルとディレクトリをセットアップ
	tempFilePath, tempDirPath := setupTestFixture(t)
	defer teardownTestFixture(t, tempFilePath, tempDirPath)

	// 存在するディレクトリのパスを指定した場合のテスト
	dirPath := DirectoryPath{}
	err := dirPath.Initialize(tempDirPath) // 一時ディレクトリを指定
	if err != nil {
		t.Errorf("ディレクトリが存在するはずですが、エラー: %v", err)
	}

	// 存在しないディレクトリを指定した場合のテスト
	err = dirPath.Initialize("nonexistentdir")
	if err == nil || err.Error() != "ディレクトリが存在しません" {
		t.Errorf("存在しないディレクトリのエラーメッセージが正しくありません: %v", err)
	}

	// ファイルをディレクトリとして指定した場合のテスト
	err = dirPath.Initialize(tempFilePath) // 一時ファイル名を指定
	if err == nil || err.Error() != "指定されたパスはファイルです" {
		t.Errorf("ファイルをディレクトリとして指定した場合のエラーメッセージが正しくありません: %v", err)
	}
}

func TestNonExistentDirectoryPath_Initialize(t *testing.T) {
	// NonExistentDirectoryPathの初期化テスト（存在しないディレクトリ）
	nonExistentDirPath := NonExistentDirectoryPath{}
	err := nonExistentDirPath.Initialize("/non/existing/directory")
	if err != nil {
		t.Errorf("存在しないディレクトリの初期化に失敗しました: %v", err)
	}

	// 一時ディレクトリを作成
	tempDir, err := os.MkdirTemp("", "testdir_")
	if err != nil {
		t.Fatalf("一時ディレクトリを作成できませんでした: %v", err)
	}
	defer os.RemoveAll(tempDir) // テスト終了後に一時ディレクトリを削除

	// NonExistentDirectoryPathの初期化テスト（既存のディレクトリを指定）
	err = nonExistentDirPath.Initialize(tempDir)
	if err == nil || err.Error() != "ディレクトリが既に存在しています" {
		t.Errorf("既存のディレクトリのエラーメッセージが正しくありません: %v", err)
	}
}

// TestGetPaths tests the GetPaths function.
func TestGetPaths(t *testing.T) {
	// 一時ファイルとディレクトリをセットアップ
	tempFilePath, tempDirPath := setupTestFixture(t)
	defer teardownTestFixture(t, tempFilePath, tempDirPath)

	// 一時ファイルのテスト
	cleanPath, absPath, err := GetPaths(tempFilePath)
	if err != nil {
		t.Errorf("一時ファイルでエラーが発生しました: %v", err)
	}

	// 絶対パスが正しいか確認
	expectedAbsPath, _ := filepath.Abs(tempFilePath)
	if absPath != expectedAbsPath {
		t.Errorf("絶対パスが正しくありません。期待値: %v, 実際: %v", expectedAbsPath, absPath)
	}

	// クリーンなパスが正しいか確認
	expectedCleanPath := filepath.Clean(tempFilePath)
	if cleanPath != expectedCleanPath {
		t.Errorf("クリーンな相対パスが正しくありません。期待値: %v, 実際: %v", expectedCleanPath, cleanPath)
	}

	// 存在しないパスのテスト
	_, _, err = GetPaths("nonexistentfile.txt")
	if err != nil {
		t.Errorf("存在しないファイルでエラーが発生することを期待しましたが、エラーがありませんでした: %v", err)
	}

	// ディレクトリのテスト
	cleanPath, absPath, err = GetPaths(tempDirPath)
	if err != nil {
		t.Errorf("一時ディレクトリでエラーが発生しました: %v", err)
	}

	// 絶対パスが正しいか確認
	expectedAbsDirPath, _ := filepath.Abs(tempDirPath)
	if absPath != expectedAbsDirPath {
		t.Errorf("ディレクトリの絶対パスが正しくありません。期待値: %v, 実際: %v", expectedAbsDirPath, absPath)
	}

	// クリーンなパスが正しいか確認
	expectedCleanDirPath := filepath.Clean(tempDirPath)
	if cleanPath != expectedCleanDirPath {
		t.Errorf("クリーンなディレクトリパスが正しくありません。期待値: %v, 実際: %v", expectedCleanDirPath, cleanPath)
	}
}
