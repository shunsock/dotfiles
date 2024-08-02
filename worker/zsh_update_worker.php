<?php

declare(strict_types=1);

namespace Project\Worker;

require_once __DIR__ . '/FileCreator.php';
require_once __DIR__ . '/FileRemover.php';
require_once __DIR__ . '/FileCopier.php';
require_once __DIR__ . '/Messenger.php';
require_once __DIR__ . '/ConfigUpdater.php';

$homeDir = getenv('HOME');
$dotfiles_dir_path = $homeDir . '/.zsh';
$target_dir_path = $homeDir . '/.zsh/config';
$source_dir_path = __DIR__ . '/../configs/zsh/config';

$zshUpdateWorker = new ConfigUpdater(
    dotfiles_dir_path: $dotfiles_dir_path,
    source_dir_path: $source_dir_path,
    target_dir_path: $target_dir_path
);
$zshUpdateWorker->update();
