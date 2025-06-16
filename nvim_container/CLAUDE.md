# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Run Commands
- Build Docker image: `docker build -t nvimc .`
- Run container: `docker run -it --rm -v "$PWD":/workspace -v "$HOME/.nvimc/share":/root/.local/share/nvim -v "$HOME/.nvimc/cache":/root/.cache/nvim -v "$HOME/.nvimc/state":/root/.local/state/nvim -w /workspace nvimc`

[README](./

## Code Style Guidelines
- Indentation: 2 spaces (no tabs)
- Plugin definitions should return a table with plugin name, dependencies and a config function
- Comments should be in Japanese for clarity
- Use `local` for variable declarations
- For keymappings, use `vim.api.nvim_set_keymap` or `vim.keymap.set` with `opts` containing `{ noremap = true, silent = true }`
- Group related functionality in subdirectories (e.g., plugins/lsp/, plugins/bufferline/)
- Plugin files should follow a consistent pattern: setup.lua for main configuration, keymap.lua for plugin-specific keymaps
- Use snake_case for function and variable names
- Prefer explicit configurations over defaults when clarity is needed
