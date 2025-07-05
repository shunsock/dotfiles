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
├── asagi/          # Primary Nix Darwin configuration
├── homem/          # Legacy Go-based configuration manager
├── yamabuki/       # Containerized Neovim environment
└── Taskfile.yml    # Legacy task automation
```

## Projects

### 🚀 Asagi (Primary System)

**Modern Nix Darwin configuration for macOS**

- **Target**: Apple Silicon Macs (aarch64-darwin)
- **Features**: Declarative system configuration, package management, modular shell setup
- **Status**: ✅ Active

**Key Components**:
- Nix Darwin system configuration
- Home Manager integration
- Modular Zsh configuration with automatic loading
- SKK Japanese input support
- Development tools: Claude Code, .NET 9 SDK, Rust, Go Task

**Quick Commands**:
```bash
cd asagi/
task apply     # Apply changes (requires sudo)
task build     # Test build without applying
task validate  # Comprehensive validation
```

### 🏗️ Homem (Legacy)

**Go-based dotfiles synchronization system**

- **Language**: Go 1.22.7
- **Features**: Type-safe file operations, multi-tool configuration management
- **Status**: ⚠️ Deprecated

**Architecture**:
- 5 executable entry points (nix, nvim, vscode, wezterm, zsh)
- Type-safe path handling with custom types
- Comprehensive test coverage (70.6% handlers, 87.1% path utilities)

**Development Commands**:
```bash
task fmt      # Format Go code
task test     # Run tests with coverage
task build    # Build all binaries
```

### 🐳 Yamabuki (Neovim Container)

**Containerized Neovim development environment**

- **Base**: Alpine Linux with Neovim
- **Features**: Lua-based plugin system, portable development environment
- **Status**: ✅ Active for development

**Usage**:
```bash
cd yamabuki/
docker build -t nvimc .
docker run -it --rm -v "$PWD":/workspace nvimc
```

## Development Environment

### Included Tools

**System Packages** (via Asagi):
- Claude Code - AI-powered development assistant
- .NET 9 SDK - Cross-platform development
- Git & GitHub CLI - Version control
- Go Task - Task automation
- Rust toolchain - Systems programming
- Hyperfine - Command-line benchmarking
- Tree - Directory visualization

**Homebrew Casks**:
- WezTerm - GPU-accelerated terminal
- AquaSKK - Japanese input method

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

1. **System Updates**:
   ```bash
   cd asagi/
   task update    # Update dependencies
   task apply     # Apply changes
   ```

2. **Configuration Changes**:
   - Edit files in `asagi/configs/`
   - Test with `task build`
   - Apply with `task apply`

3. **Container Development**:
   ```bash
   cd yamabuki/
   docker run -it --rm -v "$PWD":/workspace nvimc
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

### Configuration Flow

1. **Nix Darwin** manages system-level configuration
2. **Home Manager** handles user-space configuration  
3. **Modular imports** organize configuration by tool
4. **Automatic loading** reduces manual configuration management

### Type Safety

The legacy Go system demonstrates type-safe configuration management:
- `FilePath` - Guarantees file existence
- `DirectoryPath` - Guarantees directory existence
- `NonExistentDirectoryPath` - Safe for creation operations

### Environment Variables

All systems support environment variable expansion (e.g., `$HOME`, `$ZSH`) for portability across different user environments.

## Migration Status

- **✅ Current**: Asagi (Nix Darwin) - Primary development system
- **⚠️ Deprecated**: Homem (Go) - Legacy system, reference only
- **✅ Specialized**: Yamabuki (Container) - Development environment

## Troubleshooting

### Common Issues

1. **Sudo permissions**: Some commands require manual execution
2. **Nix Darwin not found**: Run `task init` first
3. **Container issues**: Ensure Docker is running

### Getting Help

- Check existing documentation in each project directory
- Review CLAUDE.md for Claude Code specific guidance
- Examine Taskfile.yml for available commands

## License

This repository is open source and available for use. Note that configurations may change without notice - use at your own risk.