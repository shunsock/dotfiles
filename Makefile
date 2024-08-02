.PHONY: up nvim wezterm

up:
	rm -rf tmp/*
	phpunit tests
	rm -r tmp/*

nvim:
	php ./worker/nvim_update_worker.php

wezterm:
	php ./worker/wezterm_update_worker.php