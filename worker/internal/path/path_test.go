package path

import (
	"io/ioutil"
	"os"
	"testing"
)

// テスト用の一時ファイルと一時ディレクトリをセットアップする
func setupTestFixture(t *testing.T) (string, string) {
	// 一時ファイルを作成
	tempFile, err := ioutil.TempFile("", "testfile_*.txt")
	if err != nil {
		t.Fatalf("一時ファイルを作成できませんでした: %v", err)
	}

	// 一時ディレクトリを作成
	tempDir, err := ioutil.TempDir("", "testdir_")
	if err != nil {
		t.Fatalf("一時ディレクトリを作成できませんでした: %v", err)
	}

	return tempFile.Name(), tempDir
}

// テスト終了後にクリーンアップ
func teardownTestFixture(t *testing.T, tempFilePath string, tempDirPath string) {
	// 一時ファイルを削除
	err := os.Remove(tempFilePath)
	if err != nil {
		t.Errorf("一時ファイルを削除できませんでした: %v", err)
	}

	// 一時ディレクトリを削除
	err = os.Remove(tempDirPath)
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

