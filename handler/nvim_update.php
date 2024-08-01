<?php

declare(strict_types=1);

final class NeovimUpdate {
    private string $dotfiles_path;
    private string $source_path;
    private string $target_path;

    const string FILE_CREATED_MESSAGE = 'Created target directory';
    const string FAILED_TO_CREATE_FILE_MESSAGE = 'Failed to create target directory';
    const string FILE_DELETED_MESSAGE = 'Deleted files';
    const string FAILED_TO_DELETE_FILE_MESSAGE = 'Failed to delete files';
    const string COPIED_FILES_MESSAGE = 'Copied files';
    const string FAILED_TO_COPY_FILES_MESSAGE = 'Failed to copy files';

    public function __construct ()
    {
        $homeDir = getenv('HOME');
        $this->dotfiles_path = $homeDir . '/.config';
        $this->target_path = $homeDir . '/.config/nvim';
        $this->source_path = __DIR__ . '/../nvim';
    }

    private function check_dot_config_dir_exists(): bool
    {
        return file_exists($this->dotfiles_path);
    }

    private function check_neovim_config_exists(): bool
    {
        return file_exists($this->target_path);
    }

    private function make_dot_config_dir_if_not_exist(): void
    {
        if ($this->check_dot_config_dir_exists()) {
            return;
        }

        if (mkdir($this->target_path, 0775, false)) {
            echo self::FILE_CREATED_MESSAGE.PHP_EOL;
        } else {
            throw new RuntimeException(self::FAILED_TO_CREATE_FILE_MESSAGE);
        }
    }

    private function delete_target_path_if_target_exist(): void
    {
        // ファイルが存在しない場合は何もしない
        if (!$this->check_neovim_config_exists()) {
            return;
        }

        $command = "rm -rf " . escapeshellarg($this->target_path);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        if ($return_var !== 0) {
            throw new RuntimeException(self::FAILED_TO_DELETE_FILE_MESSAGE);
        }

        echo self::FILE_DELETED_MESSAGE.PHP_EOL;
    }

    private function copy_files(): void
    {
        $command = "cp -r " . escapeshellarg($this->source_path) . " " . escapeshellarg($this->dotfiles_path);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        if ($return_var !== 0) {
            throw new RuntimeException(self::FAILED_TO_COPY_FILES_MESSAGE);
        }

        echo self::COPIED_FILES_MESSAGE.PHP_EOL;
    }

    public function update(): void
    {
        $this->make_dot_config_dir_if_not_exist();
        $this->delete_target_path_if_target_exist();
        $this->copy_files();
    }
}

$neovim = new NeovimUpdate();
$neovim->update();