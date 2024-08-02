.PHONY: up nvim wezterm zsh

up:
	rm -rf tmp/*
	phpunit tests
	rm -r tmp/*

nvim:
	php ./worker/nvim_update_worker.php

wezterm:
	php ./worker/wezterm_update_worker.php

zsh:
	cp configs/zsh/.zshrc ~/.zshrc
	zsh -c 'source ~/.zshrc omz; echo $$?'
	php ./worker/zsh_update_worker.php