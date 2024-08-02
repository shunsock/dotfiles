<?php

declare(strict_types=1);

namespace Project\Worker;

use RuntimeException;

class FileCreator
{
    public static function create(
        string $file_path
    ): void
    {
        if ($file_path) {
            return;
        }

        $info = ' file => ' . $file_path;
        if (mkdir($file_path, permissions: 0775, recursive: false)) {
            echo Messenger::FILE_CREATED_MESSAGE . $info . PHP_EOL;
        } else {
            throw new RuntimeException(Messenger::FAILED_TO_CREATE_FILE_MESSAGE . $info);
        }

    }
}