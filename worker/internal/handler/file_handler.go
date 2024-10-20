package handler

import (
  "os/exec";
  "worker/internal/path"
)

// ファイル操作
type FileHandler struct{}

// Copy: ファイルをコピーする
func (fh *FileHandler) Copy(
  src *path.FilePath,
  dst *path.FilePath
) error {
	cmd := exec.Command("cp", src.Path, dst.Path)
	return cmd.Run()
}

// Remove: ファイルを削除する
func (fh *FileHandler) Remove(
  file *path.FilePath
) error {
	cmd := exec.Command("rm", file.Path)
	return cmd.Run()
}
