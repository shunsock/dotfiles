package path

import (
	"errors"
	"os"
)

// FilePath構造体
type FilePath struct {
	Path string
}

// Fileのメソッド: 初期化時にファイルの存在とタイプを保証する
func (f *FilePath) Initialize(path string) error {
	info, err := os.Stat(path)
	if os.IsNotExist(err) {
		return errors.New("ファイルが存在しません")
	}
	if err != nil {
		return err
	}
	if info.IsDir() {
		return errors.New("指定されたパスはディレクトリです")
	}
	// ファイルが存在することを確認して初期化
	f.Path = path
	return nil
}

// Directory構造体
type DirectoryPath struct {
	Path string
}

// Directoryのメソッド: 初期化時にディレクトリの存在とタイプを保証する
func (d *DirectoryPath) Initialize(path string) error {
	info, err := os.Stat(path)
	if os.IsNotExist(err) {
		return errors.New("ディレクトリが存在しません")
	}
	if err != nil {
		return err
	}
	if !info.IsDir() {
		return errors.New("指定されたパスはファイルです")
	}
	// ディレクトリが存在することを確認して初期化
	d.Path = path
	return nil
}

// NonExistDirectory構造体
type NonExistentDirectoryPath struct {
	Path string
}

// Initialize メソッド: 初期化時にディレクトリの存在を確認し、存在しない場合にのみ初期化
func (d *NonExistentDirectoryPath) Initialize(path string) error {
	_, err := os.Stat(path)
	if os.IsNotExist(err) {
		// ディレクトリが存在しない場合は初期化
		d.Path = path
		return nil
	}
	if err != nil {
		// その他のエラーが発生した場合
		return err
	}
	// ディレクトリが存在する場合
	return errors.New("ディレクトリが既に存在しています")
}

