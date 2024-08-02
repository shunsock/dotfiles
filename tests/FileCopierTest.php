<?php

declare(strict_types=1);

namespace Project\Tests;

use Project\Worker\FileCopier;
use PHPUnit\Framework\TestCase;

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
}