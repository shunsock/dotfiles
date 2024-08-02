<?php

declare(strict_types=1);

require_once 'Messenger.php';
require_once 'FileCreator.php';
require_once 'FileRemover.php';
require_once 'FileCopier.php';

final class NeovimUpdateWorker
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

    private function make_dot_config_dir_if_not_exist(): void
    {
        FileCreator::create(
            file_path: $this->target_path
        );
    }

    private function delete_target_path_if_target_exist(): void
    {
        FileRemover::remove_recursive(
            target_path: $this->target_path
        );
    }

    private function copy_files(): void
    {
        FileCopier::copy_recursive(
            source_dir: $this->source_path,
            target_dir: $this->dotfiles_path
        );
    }

    public function update(): void
    {
        $this->make_dot_config_dir_if_not_exist();
        $this->delete_target_path_if_target_exist();
        $this->copy_files();
        echo Messenger::FINISH_SUCCESSFULLY_MESSAGE . PHP_EOL;
    }
}

$neovim = new NeovimUpdateWorker();
$neovim->update();
