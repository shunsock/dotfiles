package main

import (
	"log"
  "worker/internal/path"
)

func main() {
  // weztermの設定ディレクトリを呼び出す
	configDir := "../configs/wezterm"
	_, configDirAbsPath, err := path.GetPaths(configDir)
	if err != nil {
		log.Fatal(err)
	}
	dirPath := &path.DirectoryPath{}
	err = dirPath.Initialize(configDirAbsPath)
	if err != nil {
		log.Fatal(err)
	}
  log.Println("Directory path initialized:", dirPath)
}

