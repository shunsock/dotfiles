<?php

declare(strict_types=1);

require_once 'Messenger.php';

class FileCopier
{
    public static function copy_recursive(
        string $source_dir,
        string $target_dir
    ): void
    {
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