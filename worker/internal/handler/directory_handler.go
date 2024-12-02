package handler

import (
	"os/exec"
	"worker/internal/path"
)

// DirectoryHandler ディレクトリ操作
type DirectoryHandler struct{}

// CopyRecursive CopyRecursive: ディレクトリを再帰的にコピー (DirectoryPathを使用)
func (dh *DirectoryHandler) CopyRecursive(
	src *path.DirectoryPath,
	dst *path.DirectoryPath,
) error {
	cmd := exec.Command("cp", "-r", src.Path, dst.Path)
	return cmd.Run()
}

// RemoveRecursive RemoveRecursive: ディレクトリを再帰的に削除 (DirectoryPathを使用)
func (dh *DirectoryHandler) RemoveRecursive(dir *path.DirectoryPath) error {
	cmd := exec.Command("rm", "-r", dir.Path)
	return cmd.Run()
}

// Create ディレクトリを作成 (NonExistentDirectoryPathを使用)
// typeでPathが存在しないことを保証しているので-pは不要
func (dh *DirectoryHandler) Create(
	dir *path.NonExistentDirectoryPath,
) error {
	cmd := exec.Command("mkdir", dir.Path)
	return cmd.Run()
}
