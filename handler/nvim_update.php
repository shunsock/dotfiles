<?php

declare(strict_types=1);

require_once 'Messenger.php';
require_once 'FileCreator.php';

final class NeovimUpdate
{
    private string $dotfiles_path;
    private string $source_path;
    private string $target_path;

    public function __construct()
    {
        $homeDir = getenv('HOME');

        // check $HOME/.config exist
        if (file_exists($homeDir.'/.config') === false) {
            throw new InvalidArgumentException(
                message: '[Error] could not find $HOME/.config dir'
            );
        }

        $this->dotfiles_path = $homeDir . '/.config';
        $this->target_path = $homeDir . '/.config/nvim';
        $this->source_path = __DIR__ . '/../nvim';
    }

    private function check_neovim_config_exists(): bool
    {
        return file_exists($this->target_path);
    }

    private function make_dot_config_dir_if_not_exist(): void
    {
        FileCreator::create(
            file_path: $this->target_path
        );
    }

    private function delete_target_path_if_target_exist(): void
    {
        // ファイルが存在しない場合は何もしない
        if (!$this->check_neovim_config_exists()) {
            return;
        }

        $command = "rm -r " . escapeshellarg($this->target_path);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        $info = ' file => ' . $this->target_path;
        if ($return_var !== 0) {
            throw new RuntimeException(Messenger::FAILED_TO_DELETE_FILE_MESSAGE . $info);
        }

        echo Messenger::FILE_DELETED_MESSAGE . $info . PHP_EOL;
    }

    private function copy_files(): void
    {
        $command = "cp -r " . escapeshellarg($this->source_path) . " " . escapeshellarg($this->dotfiles_path);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        $info = ' source => ' . $this->source_path . ' target => ' . $this->target_path;
        if ($return_var !== 0) {
            throw new RuntimeException(Messenger::FAILED_TO_COPY_FILES_MESSAGE . $info);
        }

        echo Messenger::COPIED_FILES_MESSAGE . $info . PHP_EOL;
    }

    public function update(): void
    {
        $this->make_dot_config_dir_if_not_exist();
        $this->delete_target_path_if_target_exist();
        $this->copy_files();
        echo Messenger::FINISH_SUCCESSFULLY_MESSAGE . PHP_EOL;
    }
}

$neovim = new NeovimUpdate();
$neovim->update();
