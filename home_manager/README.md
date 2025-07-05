# Nix Darwin Configuration

A comprehensive dotfiles configuration using Nix Darwin for macOS development environment.

## Features

- **System Management**: Declarative system configuration using Nix Darwin
- **Package Management**: Declarative package installation using Nix
- **Modular Zsh Configuration**: Organized shell configuration with automatic loading
- **Development Tools**: Pre-configured development environment with essential tools
- **Version Control**: Git aliases and configuration

## Quick Start

### Prerequisites

- Nix package manager installed on macOS
- Git for cloning the repository

### Installation

1. **Initialize Project**:
   ```bash
   task init
   ```

2. **Apply Configuration**:
   ```bash
   task apply
   ```
   
   **Note:** This command requires sudo permissions. When using Claude Code, you may need to run this manually in your terminal.

## Configuration Structure

```
├── .claude/                    # Claude Code configuration
│   ├── how_to_check_font.md    # Font checking documentation
│   ├── settings.json           # Claude settings
│   └── settings.local.json     # Local Claude settings
├── CLAUDE.md                   # Claude Code instructions
├── flake.nix                   # Main Nix Darwin configuration
├── flake.lock                  # Locked dependency versions
├── home.nix                    # Home Manager configuration
├── modules/                    # Nix configuration modules
│   └── wezterm.nix            # WezTerm terminal configuration
├── README.md                   # This file
├── Taskfile.yml               # Task automation commands
└── zsh/                       # Modular zsh configuration
    ├── basic/                 # Core shell settings
    │   ├── alias.zsh          # System and utility aliases
    │   ├── editor.zsh         # Editor configuration
    │   ├── option.zsh         # Shell options
    │   └── path.zsh           # PATH modifications
    └── command/               # Command-specific configurations
        ├── docker/            # Docker-related settings
        │   └── docker.zsh     # Docker aliases and functions
        └── git/               # Git configuration
            └── alias.zsh      # Git aliases
```

## Included Packages

- **Development**: claude-code, dotnetCorePackages.dotnet_9.sdk, git, go-task, rustup
- **System Utilities**: hyperfine, tree
- **Shell Enhancement**: zsh-autosuggestions, zsh-syntax-highlighting

## Task Commands

```bash
# Apply configuration changes (requires sudo - run manually if using Claude Code)
task apply

# Build configuration (test without applying)
task build

# Update all flake inputs
task update

# Check flake configuration
task check

# Comprehensive validation (build + check)
task validate
```

## Direct Commands (if needed)

```bash
# Apply configuration changes
sudo darwin-rebuild switch --flake .#shunsock-darwin

# Build configuration (test without applying)
nix build .#darwinConfigurations.shunsock-darwin.system

# Update all flake inputs
nix flake update

# Check flake configuration
nix flake check
```

## Customization

### Adding New Packages

Edit `flake.nix` and add packages to the `environment.systemPackages` list:

```nix
environment.systemPackages = with pkgs; [
  # existing packages...
  your-new-package
];
```

### Adding Zsh Configuration

Create new `.zsh` files in the appropriate directory under `zsh/`. Files are automatically sourced based on the directory structure.

### Modifying User Settings

Update the user configuration in `flake.nix`:

```nix
users.users.your-username = {
  name = "your-username";
  home = "/Users/your-username";
};
```

