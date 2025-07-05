package updater

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

// TestRemoveFile tests the removeFile function
func TestRemoveFile(t *testing.T) {
	// Create a temporary file for testing
	tempFile, err := ioutil.TempFile("", "test-remove-file")
	if err != nil {
		t.Fatalf("Failed to create temp file: %v", err)
	}
	tempFilePath := tempFile.Name()
	tempFile.Close()

	// Call the function to remove the file
	removeFile(tempFilePath)

	// Verify file was removed
	if _, err := os.Stat(tempFilePath); !os.IsNotExist(err) {
		t.Errorf("File %s was not removed", tempFilePath)
	}
}

// TestUpdateFile tests the UpdateFile function
func TestUpdateFile(t *testing.T) {
	// Create temporary directories and files for testing
	sourceDir, err := ioutil.TempDir("", "test-source-dir")
	if err != nil {
		t.Fatalf("Failed to create source temp directory: %v", err)
	}
	defer os.RemoveAll(sourceDir)

	destDir, err := ioutil.TempDir("", "test-dest-dir")
	if err != nil {
		t.Fatalf("Failed to create destination temp directory: %v", err)
	}
	defer os.RemoveAll(destDir)

	// Create test source file with content
	fileName := "config.txt"
	sourceFile := filepath.Join(sourceDir, fileName)
	sourceContent := []byte("test configuration content")
	if err := ioutil.WriteFile(sourceFile, sourceContent, 0644); err != nil {
		t.Fatalf("Failed to create source file: %v", err)
	}

	// Create target file (which should be replaced)
	targetDir, err := ioutil.TempDir("", "test-target-dir")
	if err != nil {
		t.Fatalf("Failed to create target temp directory: %v", err)
	}
	defer os.RemoveAll(targetDir)

	targetFile := filepath.Join(targetDir, fileName)
	if err := ioutil.WriteFile(targetFile, []byte("old configuration"), 0644); err != nil {
		t.Fatalf("Failed to create target file: %v", err)
	}

	// Call the function to update file
	UpdateFile(targetFile, sourceFile, destDir)

	// Verify target file was removed
	if _, err := os.Stat(targetFile); !os.IsNotExist(err) {
		t.Errorf("Target file %s was not removed", targetFile)
	}

	// Verify source file was copied to destination
	destFile := filepath.Join(destDir, fileName)
	if _, err := os.Stat(destFile); os.IsNotExist(err) {
		t.Errorf("Destination file %s was not created", destFile)
	}

	// Verify content of copied file
	destContent, err := ioutil.ReadFile(destFile)
	if err != nil {
		t.Fatalf("Failed to read destination file: %v", err)
	}

	if string(destContent) != string(sourceContent) {
		t.Errorf("Destination file content doesn't match. Expected '%s', got '%s'", string(sourceContent), string(destContent))
	}
}
