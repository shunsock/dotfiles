<?php

declare(strict_types=1);

namespace Project\Worker;

use RuntimeException;

class FileRemover
{
    public static function remove_recursive(
        string $target_path
    ): void
    {
        // ファイルが存在しない場合は何もしない
        if (!file_exists($target_path)) {
            return;
        }

        $command = "rm -r " . escapeshellarg($target_path);
        $output = [];
        $return_var = 0;

        // コマンドの実行
        exec($command, $output, $return_var);

        $info = ' file => ' . $target_path;
        if ($return_var !== 0) {
            throw new RuntimeException(Messenger::FAILED_TO_DELETE_FILE_MESSAGE . $info);
        }

        echo Messenger::FILE_DELETED_MESSAGE . $info . PHP_EOL;
    }
}