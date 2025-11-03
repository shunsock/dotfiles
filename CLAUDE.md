# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a comprehensive dotfiles repository containing three main projects:

- **`asagi/`** - Nix Darwin configuration for macOS (active)
- **`azuma/`** - NixOS configuration for Linux (active)
- **`akatsuki/`** - Docker container environments (active)

## Commands

### Asagi (Nix Darwin for macOS)
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

### Azuma (NixOS for Linux)
```bash
cd azuma/

# System management
sudo nixos-rebuild switch --flake .#myNixOS  # Apply configuration
nix flake check                               # Validate flake
nix flake update                              # Update dependencies

# Direct commands (if needed)
nix build .#nixosConfigurations.myNixOS.config.system.build.toplevel
```

### Akatsuki (Docker Containers)
```bash
cd akatsuki/

# Build containers
task build:default:arm    # Build ARM architecture container
task build:default:amd    # Build AMD/Intel architecture container
task build:python         # Build Python development container

# Run containers
task run:default:arm /path/to/workspace
task run:default:amd /path/to/workspace
task run:python /path/to/workspace

# Push to registry (requires authentication)
task push                 # Push all containers
task push:python         # Push Python container only
```

## Architecture

### Asagi (Nix Darwin for macOS)
- **Purpose**: Declarative macOS system configuration using Nix Darwin
- **Target**: aarch64-darwin (Apple Silicon Macs)
- **User**: shunsock with home directory `/Users/shunsock`
- **Configuration Flow**:
  1. `flake.nix` - Main system configuration with Homebrew integration
  2. `home.nix` - Home Manager configuration importing modular components
  3. `modules/` - Modular configurations (claude.nix, firefox.nix, skk.nix, wezterm.nix, zsh.nix)
  4. `configs/` - Raw configuration files organized by tool

**Key Features**:
- Homebrew casks: wezterm, aquaskk, arc, docker, steam, zoom
- Home Manager packages: claude-code, dotnet 10 SDK, gh, git, go-task, hackgen-nf-font, hyperfine, mise, rustup, tree
- Modular zsh configuration with automatic loading
- SKK Japanese input configuration
- Font management with fontconfig

### Azuma (NixOS for Linux)
- **Purpose**: Complete Linux desktop environment using NixOS
- **Target**: x86_64-linux
- **User**: shunsock
- **Configuration Flow**:
  1. `flake.nix` - NixOS system configuration
  2. `configuration.nix` - Main system configuration
  3. `hardware-configuration.nix` - Hardware-specific settings
  4. `modules/` - Modular configurations (claude-code.nix, neovim.nix, wezterm.nix, zsh.nix)
  5. `configs/` - Raw configuration files organized by tool

**Key Features**:
- GNOME Desktop Environment with GDM
- Fcitx5 Japanese input with SKK support
- Docker support with user in docker group
- System packages: curl, fastfetch, gh, go-task, vim
- Fonts: Noto CJK, Noto Emoji, JetBrains Mono Nerd Font
- Starship prompt, Git, Dconf

### Akatsuki (Docker Containers)
- **Purpose**: Portable development environments in Docker containers
- **Base**: Ubuntu 24.04
- **Architecture**: Multi-architecture support (ARM and AMD64)
- **Available Images**:
  1. `akatsuki-default-arm` - ARM architecture development environment
  2. `akatsuki-default-amd` - AMD/Intel architecture development environment
  3. `akatsuki-python` - Python-focused development environment

**Key Features**:
- Neovim v0.11.1 from source
- Node.js 24.x
- .NET 8.0 SDK
- Docker registry: tsuchiya55docker/akatsuki
- Volume mounting for workspace and persistent data

## Important Notes

### Claude Code Limitations
- **Sudo Commands**: Commands requiring sudo (like `task apply` in asagi) cannot be executed by Claude Code and must be run manually
- **Docker Operations**: Docker commands may require manual execution depending on setup

### Development Workflow
1. **macOS Development**: Use asagi for macOS system configuration changes
2. **Linux Development**: Use azuma for Linux system configuration changes
3. **Container Development**: Use akatsuki for portable development environments
4. **Testing**: Use `task build` and `task validate` (asagi) or `nix flake check` (azuma) before applying changes

### File Organization
- Configuration files are organized by tool within each project
- Nix configurations use modular imports for maintainability
- Both asagi and azuma share similar modular structure for consistency
- Docker containers use multi-stage builds for optimization

## Project Status
- **Active**: asagi (Nix Darwin) - macOS system configuration
- **Active**: azuma (NixOS) - Linux system configuration
- **Active**: akatsuki (Docker) - Portable container environments