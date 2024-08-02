.PHONY: up nvim_update

up:
	rm -r tmp/*
	phpunit tests

nvim_update:
	php ./worker/nvim_update_worker.php
