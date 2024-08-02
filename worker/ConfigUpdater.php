<?php

declare(strict_types=1);

namespace Project\Worker;

use InvalidArgumentException;

require_once __DIR__ . '/FileCreator.php';
require_once __DIR__ . '/FileRemover.php';
require_once __DIR__ . '/FileCopier.php';
require_once __DIR__ . '/Messenger.php';

final class ConfigUpdater
{
    private string $dotfiles_path;
    private string $source_path;
    private string $target_path;

    public function __construct(
        string $dotfiles_dir_path,
        string $source_dir_path,
        string $target_dir_path
    )
    {
        // check $HOME/.config exist
        if (file_exists($dotfiles_dir_path) === false) {
            throw new InvalidArgumentException(
                message: '[Error] could not find ' . $dotfiles_dir_path
            );
        }
        if (file_exists($source_dir_path) === false) {
            throw new InvalidArgumentException(
                message: '[Error] could not find ' . $source_dir_path
            );
        }
        if (file_exists($target_dir_path) === false) {
            throw new InvalidArgumentException(
                message: '[Error] could not find ' . $target_dir_path
            );
        }

        $this->dotfiles_path = $dotfiles_dir_path;
        $this->target_path = $target_dir_path;
        $this->source_path = $source_dir_path;
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
