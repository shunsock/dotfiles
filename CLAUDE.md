# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a comprehensive dotfiles repository containing three main projects:

- **`asagi/`** - Nix Darwin configuration (active, primary system)
- **`homem/`** - Legacy Go-based dotfiles manager (deprecated)
- **`yamabuki/`** - Dockerized Neovim container

## Commands

### Root Level (Legacy homem system)
```bash
# Go development
task fmt          # Format Go code
task test         # Run tests with coverage
task build        # Build all binaries to bin/darwin/

# Update configurations (deprecated - use asagi instead)
task update-wezterm
task update-nvim
task update-nix
task update-vscode
task update-zsh

# Install dependencies
task install-font     # Download and install fonts
task install-jetpack  # Install Neovim jetpack plugin manager
```

### Asagi (Primary Nix Darwin System)
```bash
cd asagi/

# System management
task init      # First-time setup (installs nix-darwin system-wide)
task apply     # Apply configuration changes (requires sudo)
task build     # Build configuration without applying
task check     # Validate flake configuration
task update    # Update flake dependencies
task validate  # Comprehensive validation (build + check)

# Direct commands (if task fails)
sudo darwin-rebuild switch --flake .#shunsock-darwin
nix build .#darwinConfigurations.shunsock-darwin.system
nix flake check
nix flake update
```

### Yamabuki (Neovim Container)
```bash
cd yamabuki/

# Container operations
docker build -t nvimc .
docker run -it --rm -v "$PWD":/workspace -v "$HOME/.nvimc/share":/root/.local/share/nvim -v "$HOME/.nvimc/cache":/root/.cache/nvim -v "$HOME/.nvimc/state":/root/.local/state/nvim -w /workspace nvimc

# Or use pre-built image
docker pull tsuchiya55docker/nvimc:v0.0.2
```

## Architecture

### Active System: Asagi (Nix Darwin)
- **Purpose**: Declarative macOS system configuration using Nix Darwin
- **Target**: aarch64-darwin (Apple Silicon Macs)
- **User**: shunsock with home directory `/Users/shunsock`
- **Configuration Flow**:
  1. `flake.nix` - Main system configuration with Homebrew integration
  2. `home.nix` - Home Manager configuration importing modular components
  3. `modules/` - Modular configurations (wezterm.nix, zsh.nix, skk.nix)
  4. `configs/` - Raw configuration files organized by tool

**Key Features**:
- Homebrew casks: wezterm, aquaskk
- Home Manager packages: claude-code, dotnet 9 SDK, gh, git, go-task, hackgen-nf-font, hyperfine, rustup, tree
- Modular zsh configuration with automatic loading
- SKK Japanese input configuration
- Font management with fontconfig

### Legacy System: Homem (Go-based Manager)
- **Purpose**: Type-safe dotfiles synchronization system
- **Language**: Go 1.22.7
- **Architecture**: 
  - 5 entry points: nix, nvim, vscode, wezterm, zsh
  - Type-safe path handling with FilePath, DirectoryPath, NonExistentDirectoryPath
  - Safe file operations through internal/handler and internal/updater packages
- **Test Coverage**: 70.6% handlers, 87.1% path utilities

### Container System: Yamabuki (Neovim)
- **Purpose**: Containerized Neovim environment
- **Base**: Alpine Linux with Neovim and plugin ecosystem
- **Volume Mounts**: Workspace, share, cache, state directories
- **Configuration**: Lua-based modular plugin system with lazy loading

## Important Notes

### Claude Code Limitations
- **Sudo Commands**: Commands requiring sudo (like `task apply` in asagi) cannot be executed by Claude Code and must be run manually
- **Docker Operations**: Docker commands may require manual execution depending on setup

### Development Workflow
1. **Primary System**: Use asagi for system-wide configuration changes
2. **Testing**: Use `task build` and `task validate` before applying changes
3. **Go Development**: Use homem for understanding the legacy configuration manager
4. **Neovim Development**: Use yamabuki for containerized Neovim development

### File Organization
- Configuration files are organized by tool within each project
- Nix configurations use modular imports for maintainability
- Go project follows clean architecture with internal packages
- Lua configurations use plugin-specific directories with setup/keymap separation

## Migration Status
- **Active**: asagi (Nix Darwin) - current production system
- **Deprecated**: homem (Go manager) - legacy system, not actively maintained
- **Specialized**: yamabuki (Neovim container) - development environment