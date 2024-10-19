.PHONY: up nvim wezterm zsh

up:
	rm -rf tmp/*
	phpunit tests
	rm -r tmp/*

nvim:
	mkdir -p ~/.config/nvim
	php ./php_worker/nvim_update_worker.php

wezterm:
	mkdir -p ~/.config/wezterm
	php ./php_worker/wezterm_update_worker.php

zsh:
	cp configs/zsh/.zshrc ~/.zshrc
	zsh -c 'source ~/.zshrc omz; echo $$?'
	php ./php_worker/zsh_update_worker.php

fonts:
	bash ./php_worker/fonts_downloader.sh
