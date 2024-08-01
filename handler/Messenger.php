<?php

declare(strict_types=1);

readonly class Messenger
{
    const string COPIED_FILES_MESSAGE = '[Running] Copied files:';
    const string FAILED_TO_COPY_FILES_MESSAGE = '[Error] Failed to copy files:';
    const string FAILED_TO_CREATE_FILE_MESSAGE = '[Error] Failed to create target directory:';
    const string FAILED_TO_DELETE_FILE_MESSAGE = '[Error] Failed to delete files:';
    const string FILE_CREATED_MESSAGE = '[Running] Created target directory:';
    const string FILE_DELETED_MESSAGE = '[Running] Deleted files:';

    const string FINISH_SUCCESSFULLY_MESSAGE = '[Finish] Completed!!';
}