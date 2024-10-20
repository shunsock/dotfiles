package handler

import (
  "os/exec"
  "worker/internal/path"
)

// ディレクトリ操作
type DirectoryHandler struct{}

// CopyRecursive: ディレクトリを再帰的にコピー (DirectoryPathを使用)
func (dh *DirectoryHandler) CopyRecursive(
  src *path.DirectoryPath,
  dst *path.DirectoryPath,
) error {
	cmd := exec.Command("cp", "-r", src.Path, dst.Path)
	return cmd.Run()
}

// RemoveRecursive: ディレクトリを再帰的に削除 (DirectoryPathを使用)
func (dh *DirectoryHandler) RemoveRecursive(dir *path.DirectoryPath) error {
	cmd := exec.Command("rm", "-r", dir.Path)
	return cmd.Run()
}

