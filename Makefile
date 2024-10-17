.PHONY: up nvim wezterm zsh

up:
	rm -rf tmp/*
	phpunit tests
	rm -r tmp/*

nvim:
	mkdir -p ~/.config/nvim
	php ./worker/nvim_update_worker.php

wezterm:
	mkdir -p ~/.config/wezterm
	php ./worker/wezterm_update_worker.php

zsh:
	cp configs/zsh/.zshrc ~/.zshrc
	zsh -c 'source ~/.zshrc omz; echo $$?'
	php ./worker/zsh_update_worker.php

fonts:
	bash ./worker/fonts_downloader.sh
