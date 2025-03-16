package updater

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

// TestRemoveDirectory tests the removeDirectory function
func TestRemoveDirectory(t *testing.T) {
	// Create a temporary directory for testing
	tempDir, err := ioutil.TempDir("", "test-remove-dir")
	if err != nil {
		t.Fatalf("Failed to create temp directory: %v", err)
	}
	defer os.RemoveAll(tempDir) // clean up after test

	// Create test files and subdirectories
	testSubDir := filepath.Join(tempDir, "subdir")
	if err := os.Mkdir(testSubDir, 0755); err != nil {
		t.Fatalf("Failed to create subdirectory: %v", err)
	}

	testFile := filepath.Join(testSubDir, "test.txt")
	if err := ioutil.WriteFile(testFile, []byte("test content"), 0644); err != nil {
		t.Fatalf("Failed to create test file: %v", err)
	}

	// Call the function to remove the directory
	removeDirectory(tempDir)

	// Verify directory was removed
	if _, err := os.Stat(tempDir); !os.IsNotExist(err) {
		t.Errorf("Directory %s was not removed", tempDir)
	}
}

// TestUpdateDirectory tests the UpdateDirectory function
func TestUpdateDirectory(t *testing.T) {
	// Create temporary directories for testing
	sourceDir, err := ioutil.TempDir("", "test-source-dir")
	if err != nil {
		t.Fatalf("Failed to create source temp directory: %v", err)
	}
	defer os.RemoveAll(sourceDir)

	existingDir, err := ioutil.TempDir("", "test-existing-dir")
	if err != nil {
		t.Fatalf("Failed to create existing temp directory: %v", err)
	}
	defer os.RemoveAll(existingDir)

	destDir, err := ioutil.TempDir("", "test-dest-dir")
	if err != nil {
		t.Fatalf("Failed to create destination temp directory: %v", err)
	}
	defer os.RemoveAll(destDir)

	// Create test files in the source directory
	testFile := filepath.Join(sourceDir, "config.txt")
	if err := ioutil.WriteFile(testFile, []byte("test configuration"), 0644); err != nil {
		t.Fatalf("Failed to create test file: %v", err)
	}

	// Create a subdirectory with a file
	testSubDir := filepath.Join(sourceDir, "subconfig")
	if err := os.Mkdir(testSubDir, 0755); err != nil {
		t.Fatalf("Failed to create subdirectory: %v", err)
	}

	testSubFile := filepath.Join(testSubDir, "subconfig.txt")
	if err := ioutil.WriteFile(testSubFile, []byte("subconfiguration"), 0644); err != nil {
		t.Fatalf("Failed to create test subfile: %v", err)
	}

	// Create content in existing directory to verify it gets removed
	existingFile := filepath.Join(existingDir, "old-config.txt")
	if err := ioutil.WriteFile(existingFile, []byte("old configuration"), 0644); err != nil {
		t.Fatalf("Failed to create existing file: %v", err)
	}

	// Call the function to update directory
	UpdateDirectory(sourceDir, existingDir, destDir)

	// Verify existing directory was removed
	if _, err := os.Stat(existingDir); !os.IsNotExist(err) {
		t.Errorf("Existing directory %s was not removed", existingDir)
	}

	// Get the base name of the source directory to construct the correct destination path
	sourceDirName := filepath.Base(sourceDir)
	copiedDirPath := filepath.Join(destDir, sourceDirName)

	// Verify files were copied correctly to destination
	destTestFile := filepath.Join(copiedDirPath, "config.txt")
	if _, err := os.Stat(destTestFile); os.IsNotExist(err) {
		t.Errorf("Destination file %s was not created", destTestFile)
	}

	destTestSubDir := filepath.Join(copiedDirPath, "subconfig")
	destTestSubFile := filepath.Join(destTestSubDir, "subconfig.txt")
	if _, err := os.Stat(destTestSubFile); os.IsNotExist(err) {
		t.Errorf("Destination subfile %s was not created", destTestSubFile)
	}

	// Verify content of copied files
	content, err := ioutil.ReadFile(destTestFile)
	if err != nil {
		t.Fatalf("Failed to read destination file: %v", err)
	}
	if string(content) != "test configuration" {
		t.Errorf("Destination file content doesn't match. Expected 'test configuration', got '%s'", string(content))
	}
}
