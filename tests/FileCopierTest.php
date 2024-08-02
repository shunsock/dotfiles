<?php

declare(strict_types=1);

namespace Project\Tests;

use Project\Worker\FileCopier;
use PHPUnit\Framework\TestCase;
use RuntimeException;

require_once __DIR__ . '/../worker/FileCopier.php';
require_once __DIR__ . '/../worker/Messenger.php';

class FileCopierTest extends TestCase
{
    final public function testCopyRecursiveSuccessWithValidInputs(): void
    {
        $sourceDir = __DIR__ . '/../worker';
        $targetDir = __DIR__ . '/../tmp';

        FileCopier::copy_recursive(
            source_dir: $sourceDir,
            target_dir: $targetDir
        );

        // ターゲットディレクトリが作成されたことを確認
        $this->assertTrue(is_dir($targetDir . '/worker'), 'The target directory should exist after copying.');

        // 期待するファイルがコピーされたことを確認
        $expectedFile = $targetDir . '/worker/FileCopier.php';
        $this->assertTrue(file_exists($expectedFile), 'Expected file should exist in the target directory.');
    }

    final public function testCopyRecursiveFailIfSourceDirNotExist(): void
    {
        $nonExistentSourceDir = __DIR__ . '/../non_existent_directory';
        $targetDir = __DIR__ . '/../tmp';

        // 例外を期待する
        $this->expectException(RuntimeException::class);

        FileCopier::copy_recursive(
            source_dir: $nonExistentSourceDir,
            target_dir: $targetDir
        );
    }

    final public function testCopyRecursiveFailIfTargetDirNotExist(): void
    {
        $sourceDir = __DIR__ . '/../worker';
        $nonExistentTargetDir = __DIR__ . '/../tmp/non_existent_directory';

        // 例外を期待する
        $this->expectException(RuntimeException::class);

        FileCopier::copy_recursive(
            source_dir: $sourceDir,
            target_dir: $nonExistentTargetDir
        );
    }
}