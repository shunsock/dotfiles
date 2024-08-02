.PHONY: up nvim_update

up:
	rm -rf tmp/*
	phpunit tests
	rm -r tmp/*

nvim_update:
	php ./worker/nvim_update_worker.php
