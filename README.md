# Dotfiles

A comprehensive development environment configuration using Nix Darwin, Go-based configuration management, and containerized development tools.

## Quick Start

### Prerequisites

- macOS (Apple Silicon recommended)
- Nix package manager
- Git
- Docker (for containerized Neovim)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd dotfiles
   ```

2. **Set up Nix Darwin system** (recommended):
   ```bash
   cd asagi/
   task init    # First-time setup
   task apply   # Apply configuration
   ```

## Repository Structure

```
dotfiles/
├── asagi/          # Nix Darwin configuration for macOS
├── azuma/          # NixOS configuration for Linux
└── akatsuki/       # Docker container environments
```

## Projects

### 🚀 Asagi

**Nix Darwin configuration for macOS**

- **Target**: Apple Silicon Macs (aarch64-darwin)
- **Features**: Declarative system configuration, package management, modular shell setup
- **Status**: ✅ Active

**Key Components**:
- Nix Darwin system configuration
- Home Manager integration
- Modular Zsh configuration with automatic loading
- SKK Japanese input support
- Development tools: Claude Code, .NET 10 SDK, Rust, Go Task, mise

**Quick Commands**:
```bash
cd asagi/
task apply     # Apply changes (requires sudo)
task build     # Test build without applying
task validate  # Comprehensive validation
```

### 🐧 Azuma

**NixOS configuration for Linux systems**

- **Target**: x86_64-linux
- **Features**: Complete Linux desktop environment with GNOME, development tools
- **Status**: ✅ Active

**Key Components**:
- NixOS system configuration with flakes
- GNOME Desktop Environment
- Fcitx5 Japanese input (SKK)
- Docker support
- Development tools: WezTerm, Neovim, Claude Code, Git

**Quick Commands**:
```bash
cd azuma/
sudo nixos-rebuild switch --flake .#myNixOS
nix flake update
```

### 🐳 Akatsuki

**Docker container environments for development**

- **Base**: Ubuntu 24.04
- **Features**: Pre-configured development containers with Neovim
- **Status**: ✅ Active

**Available Containers**:
- `akatsuki-default-arm` - ARM architecture
- `akatsuki-default-amd` - AMD/Intel architecture
- `akatsuki-python` - Python development environment

**Quick Commands**:
```bash
cd akatsuki/
task build:default:arm    # Build ARM container
task run:default:arm      # Run ARM container
task build:python         # Build Python container
```

## Development Environment

### Included Tools

**System Packages** (via Asagi):
- Claude Code - AI-powered development assistant
- .NET 10 SDK - Cross-platform development
- Git & GitHub CLI - Version control
- Go Task - Task automation
- Rust toolchain - Systems programming
- Hyperfine - Command-line benchmarking
- Tree - Directory visualization
- mise - Polyglot runtime manager

**Homebrew Casks**:
- WezTerm - GPU-accelerated terminal
- AquaSKK - Japanese input method
- Arc - Modern web browser
- Docker - Container platform
- Steam - Gaming platform
- Zoom - Video conferencing

### Shell Configuration

**Modular Zsh Setup**:
- Automatic loading of all `.zsh` files
- Organized by purpose (basic/, command/)
- Oh My Zsh integration with kennethreitz theme
- Enhanced with autosuggestions and syntax highlighting

**Directory Structure**:
```
configs/zsh/
├── basic/
│   ├── alias.zsh      # System aliases
│   ├── editor.zsh     # Editor configuration
│   ├── option.zsh     # Shell options
│   └── path.zsh       # PATH modifications
└── command/
    ├── docker/        # Docker-specific settings
    └── git/           # Git aliases and functions
```

## Usage

### Daily Development

1. **macOS System Updates** (Asagi):
   ```bash
   cd asagi/
   task update    # Update dependencies
   task apply     # Apply changes
   ```

2. **Linux System Updates** (Azuma):
   ```bash
   cd azuma/
   sudo nixos-rebuild switch --flake .#myNixOS
   ```

3. **Container Development** (Akatsuki):
   ```bash
   cd akatsuki/
   task build:default:arm
   task run:default:arm /path/to/workspace
   ```

### Adding New Packages

Edit `asagi/home.nix`:
```nix
home.packages = with pkgs; [
  # existing packages...
  your-new-package
];
```

### Extending Shell Configuration

Create new `.zsh` files in `asagi/configs/zsh/`:
- Files are automatically sourced
- Organize by purpose (basic/ for core, command/ for tool-specific)

## Architecture Notes

### Configuration Management

**Declarative Systems**:
- **Asagi** (macOS): Nix Darwin + Home Manager
- **Azuma** (Linux): NixOS with flakes

Both use modular imports to organize configurations by tool, making them maintainable and reusable.

### Multi-Platform Support

This repository supports multiple platforms:
- **macOS**: Native system via Nix Darwin (aarch64-darwin)
- **Linux**: Native system via NixOS (x86_64-linux)
- **Containers**: Portable environments via Docker (multi-arch)

### Configuration Flow

1. **Nix-based systems** manage both system and user-space configuration
2. **Modular imports** organize configuration by tool
3. **Automatic loading** reduces manual configuration management
4. **Flakes** ensure reproducible builds

## Project Status

- **✅ Active**: Asagi - macOS system configuration
- **✅ Active**: Azuma - Linux system configuration
- **✅ Active**: Akatsuki - Docker container environments

## Troubleshooting

### Common Issues

1. **Sudo permissions**: Some commands (Nix Darwin/NixOS rebuilds) require manual execution
2. **Nix not found**: Install Nix package manager first
3. **Container issues**: Ensure Docker is running

### Getting Help

- Check existing documentation in each project directory
- Review CLAUDE.md for Claude Code specific guidance
- Examine Taskfile.yml for available commands

## License

This repository is open source and available for use. Note that configurations may change without notice - use at your own risk.
