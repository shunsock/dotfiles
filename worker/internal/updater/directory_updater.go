package updater

import (
	"log"
  "worker/internal/path"
  "worker/internal/handler"
)

func removeDirectory(target_dir_path string) {
  log.Println("removing ... ", target_dir_path)

	_, targetDirAbsPath, err := path.GetPaths(target_dir_path)
	if err != nil {
		log.Fatal(err)
	}

	configSourcePath := &path.DirectoryPath{}
	err = configSourcePath.Initialize(targetDirAbsPath)
	if err != nil {
		log.Fatal(err)
	}

  handler := &handler.DirectoryHandler{}
  err = handler.RemoveRecursive(configSourcePath)
	if err != nil {
		log.Fatal(err)
	}
}

func UpdateDirectory(
  configDir string,
  configDirAlreadySet string,
  configDestinationDir string,
) {
  log.Println("🚀 Start updating ", configDir, " ...")

  // これから設定ファイルとするディレクトリ
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
  exist, err := handler.PathChecker(configDirAlreadySet)
	if err != nil {
		log.Fatal(err)
	}
  if exist {
    removeDirectory(configDirAlreadySet)
  }
  log.Println("removed: ", configDirAlreadySet)

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
  log.Println("🎉 Updeted!!")
}

