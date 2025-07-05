# Home Manager

A comprehensive dotfiles configuration using Nix Home Manager for macOS development environment.

## Features

- **Package Management**: Declarative package installation using Nix
- **Modular Zsh Configuration**: Organized shell configuration with automatic loading
- **Development Tools**: Pre-configured development environment with essential tools
- **Version Control**: Git aliases and configuration

## Quick Start

### Prerequisites

- Nix package manager installed on macOS
- Git for cloning the repository

### Installation

1. **Install Home Manager**:
   ```bash
   nix profile install github:nix-community/home-manager
   ```

2. **Apply Configuration**:
   ```bash
   home-manager switch --flake .#shunsock -b backup
   ```

## Configuration Structure

```
├── flake.nix           # Main configuration file
├── flake.lock          # Locked dependency versions
└── zsh/                # Modular zsh configuration
    ├── basic/          # Core shell settings
    │   ├── alias.zsh   # System and utility aliases
    │   ├── editor.zsh  # Editor configuration
    │   ├── option.zsh  # Shell options
    │   └── path.zsh    # PATH modifications
    └── command/        # Command-specific configurations
        ├── docker/     # Docker-related settings
        └── git/        # Git aliases and configuration
```

## Included Packages

- **Development**: claude-code, dotnetCorePackages.dotnet_9.sdk, git, go-task, rustup
- **System Utilities**: hyperfine, tree
- **Shell Enhancement**: zsh-autosuggestions, zsh-syntax-highlighting

## Management Commands

```bash
# Apply configuration changes
home-manager switch --flake .#shunsock -b backup

# Build configuration (test without applying)
nix build .#homeConfigurations.shunsock.activationPackage

# Update all flake inputs
nix flake update

# Check flake configuration
nix flake check
```

## Customization

### Adding New Packages

Edit `flake.nix` and add packages to the `home.packages` list:

```nix
home.packages = with pkgs; [
  # existing packages...
  your-new-package
];
```

### Adding Zsh Configuration

Create new `.zsh` files in the appropriate directory under `zsh/`. Files are automatically sourced based on the directory structure.

### Modifying User Settings

Update the user configuration in `flake.nix`:

```nix
home.username      = "your-username";
home.homeDirectory = "/Users/your-username";
```

