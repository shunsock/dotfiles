package handler

import (
  "worker/internal/core/path"
)

// ファイル操作
type FileHandler struct{}

// Copy: ファイルをコピーする
func (fh *FileHandler) Copy(src *FilePath, dst *FilePath) error {
	cmd := exec.Command("cp", src.Path, dst.Path)
	return cmd.Run()
}

// Remove: ファイルを削除する
func (fh *FileHandler) Remove(file *FilePath) error {
	cmd := exec.Command("rm", file.Path)
	return cmd.Run()
}
