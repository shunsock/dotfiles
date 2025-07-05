# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Task Commands
- **Initialize project**: `task init`
- **Apply configuration**: `task apply`
- **Build configuration**: `task build`
- **Validate flake**: `task check`
- **Update dependencies**: `task update`
- **Comprehensive validation**: `task validate`

### Direct Commands (if needed)
- **Install nix-darwin system-wide**: `nix run nix-darwin -- switch --flake .#shunsock-darwin`
- **Apply configuration**: `darwin-rebuild switch --flake .#shunsock-darwin`
- **Build configuration**: `nix build .#darwinConfigurations.shunsock-darwin.system`
- **Check flake**: `nix flake check`
- **Update flake inputs**: `nix flake update`

### Installation Notes
- **First time setup**: Run `task init` to install nix-darwin system-wide
- **After init**: The `darwin-rebuild` command will be available in your PATH
- **Subsequent updates**: Use `task apply` or `darwin-rebuild switch --flake .#shunsock-darwin`

## Architecture

This is a Nix Home Manager configuration for macOS (aarch64-darwin) that manages dotfiles and system packages.

### Structure
- `flake.nix`: Main configuration defining packages, user settings, and zsh configuration
- `zsh/`: Modular zsh configuration files organized by purpose
  - `basic/`: Core shell configurations (aliases, editor settings, options, PATH)
  - `command/`: Command-specific configurations (docker, git aliases)

### Key Components
- **Package Management**: Uses nixpkgs unstable channel with unfree packages allowed
- **Shell Configuration**: Zsh with Oh My Zsh (kennethreitz theme) and modular config loading
- **Recursive Loading**: All `.zsh` files under `~/.config/zsh/` are automatically sourced
- **User**: Configured for user `shunsock` with home directory `/Users/shunsock`

### Installed Packages
Core development tools include: claude-code, dotnetCorePackages.dotnet_9.sdk, git, go-task, hyperfine, rustup, tree, zsh-autosuggestions, zsh-syntax-highlighting

### Configuration Flow
1. flake.nix defines the home-manager configuration
2. Zsh files are copied to `~/.config/zsh/` recursively
3. initContent in programs.zsh sources all `.zsh` files automatically
4. Oh My Zsh and autosuggestions are configured last

## Reference Documentation

- **Font Management**: See `.claude/how_to_check_font.md` for checking font installations on macOS