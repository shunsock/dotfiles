<?php

declare(strict_types=1);

namespace Project\Worker;

use RuntimeException;

class FileCopier
{
    public static function copy_recursive(
        string $source_dir,
        string $target_dir
    ): void
    {
        if (!is_dir($target_dir)) {
            throw new RuntimeException(Messenger::DIRECTORY_NOT_FOUND . $target_dir);
        }

        $command = "cp -r " . escapeshellarg($source_dir) . " " . escapeshellarg($target_dir);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        $info = ' source => ' . $source_dir . ', target => ' . $target_dir;
        if ($return_var !== 0) {
            throw new RuntimeException(Messenger::FAILED_TO_COPY_FILES_MESSAGE . $info);
        }

        echo Messenger::COPIED_FILES_MESSAGE . $info . PHP_EOL;
    }
}