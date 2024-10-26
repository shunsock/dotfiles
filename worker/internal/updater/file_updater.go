package updater

import (
	"log"
  "worker/internal/path"
  "worker/internal/handler"
)

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

func UpdateFile(
  configTargetFile string,
  configSourceFile string,
  configDestinationDir string,
) {
  log.Println("🚀 Start updating ", configTargetFile, " ...")

  // 既存の設定ファイルがあれば消す
  exist, err := handler.PathChecker(configTargetFile)
	if err != nil {
		log.Fatal(err)
	}
  if exist {
    removeFile(configTargetFile)
  }
  log.Println("removed: ", configTargetFile)

  // 本レポジトリの設定ファイル
	_, configFileAbsPath, err := path.GetPaths(configSourceFile)
	if err != nil {
		log.Fatal(err)
	}
	configSourcePath := &path.FilePath{}
	err = configSourcePath.Initialize(configFileAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  log.Println("Source File Path initialized:", configSourcePath)

  // 設定を置く場所
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

  // FileHandlerを呼び出す
  handler := &handler.FileHandler{}
  err = handler.Copy(
    configSourcePath,
    configDestinationPath,
  )
  log.Println("File copied: ", configSourcePath, " -> ", configDestinationPath)
  log.Println("🎉 Finish updating ", configTargetFile, " !!")
}

