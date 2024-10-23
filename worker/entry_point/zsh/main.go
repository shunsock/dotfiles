package main

import (
	"log"
  "worker/internal/path"
  "worker/internal/handler"
  "worker/internal/updater"
)

func removeDir(target_dir_path string) {
  log.Println("removing ... ", target_dir_path)
	_, configDirAbsPath, err := path.GetPaths(target_dir_path)
	if err != nil {
		log.Fatal(err)
	}
	configSourcePath := &path.DirectoryPath{}
	err = configSourcePath.Initialize(configDirAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  handler := &handler.DirectoryHandler{}
  handler.RemoveRecursive(configSourcePath)
}

func removeFile(target_file_path string) {
  log.Println("removing ... ", target_file_path)
	_, configFileAbsPath, err := path.GetPaths(target_file_path)
	if err != nil {
		log.Fatal(err)
	}
	configSourcePath := &path.FilePath{}
	err = configSourcePath.Initialize(configFileAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  handler := &handler.FileHandler{}
  handler.Remove(configSourcePath)
}

func zsh_config_update() {
  log.Println("🚀 Start updating ~/.zsh/config ...")

  // weztermの設定ディレクトリを呼び出す
	configDir := "../configs/zsh/config"
	_, configDirAbsPath, err := path.GetPaths(configDir)
	if err != nil {
		log.Fatal(err)
	}
	configSourcePath := &path.DirectoryPath{}
	err = configSourcePath.Initialize(configDirAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  log.Println("Source Directory Path initialized:", configSourcePath)

  // 既存の設定ディレクトリがあれば消す
  configDirAlreadySet := "$HOME/.zsh/config"
  exist, err := handler.PathChecker(configDirAlreadySet)
	if err != nil {
		log.Fatal(err)
	}
  if exist {
    removeDir(configDirAlreadySet)
  }
  log.Println("removed: ", configDirAlreadySet)

  // 設定を置く場所
	configDestinationDir := "$HOME/.zsh/"
	_, configDestinationDirAbsPath, err := path.GetPaths(configDestinationDir)
	if err != nil {
		log.Fatal(err)
	}
	configDestinationPath := &path.DirectoryPath{}
	err = configDestinationPath.Initialize(configDestinationDirAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  log.Println("Destination Directory Path initialized:", configDestinationPath)
  
  // DirectoryHandlerを呼び出す
  handler := &handler.DirectoryHandler{}
  err = handler.CopyRecursive(
    configSourcePath,
    configDestinationPath,
  )
	if err != nil {
		log.Fatal(err)
	}
  log.Println("File copied: ", configSourcePath, " -> ", configDestinationPath)
}

func zshrc_update() {
  file_updater.Update(
    // 既存の設定ファイル
    "$HOME/.zshrc",
    // 更新に使う設定ファイル
    "../configs/zsh/.zshrc",
    // 設定を置く場所
    "$HOME/",
  )
}


func main() {
  zsh_config_update()
  zshrc_update()
  log.Println("🎉 Updeted!!")
}

