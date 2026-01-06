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
- **Subsequent updates**: Use `task apply` or `sudo darwin-rebuild switch --flake .#shunsock-darwin`
- **Claude Code Limitation**: Commands requiring sudo cannot be executed by Claude Code and must be run manually in terminal

## Architecture

This is a Nix Home Manager configuration for macOS (aarch64-darwin) that manages dotfiles and system packages.

### Structure
- `flake.nix`: Main Nix Darwin configuration defining packages, user settings, and zsh configuration
- `home.nix`: Home Manager configuration
- `modules/`: Nix configuration modules (wezterm.nix)
- `zsh/`: Modular zsh configuration files organized by purpose
  - `basic/`: Core shell configurations (aliases, editor settings, options, PATH)
  - `command/`: Command-specific configurations (docker, git aliases)
- `Taskfile.yml`: Task automation commands
- `.claude/`: Claude Code configuration and documentation

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

## SketchyBar Configuration

SketchyBar is a highly customizable status bar for macOS that replaces the default menu bar.

### Installation
SketchyBar is installed via Homebrew from the FelixKratz/formulae tap:
- Tap: `FelixKratz/formulae`
- Formula: `FelixKratz/formulae/sketchybar`

### Configuration Files
- **Main config**: `configs/sketchybar/sketchybarrc`
- **Color definitions**: `configs/sketchybar/colors.sh`
- **Plugins**: `configs/sketchybar/plugins/`
  - `apple.sh` - Apple logo
  - `spaces.sh` - Virtual desktop indicators
  - `front_app.sh` - Current application name
  - `clock.sh` - Date and time display
  - `battery.sh` - Battery status
  - `volume.sh` - System volume
  - `cpu.sh` - CPU usage
  - `network.sh` - Wi-Fi status

### Starting SketchyBar

After running `task apply`, start SketchyBar with:
```bash
/opt/homebrew/bin/brew services start sketchybar
```

To restart after configuration changes:
```bash
/opt/homebrew/bin/brew services restart sketchybar
```

### Manual Configuration Reload

If SketchyBar is running but not displaying correctly, manually reload the configuration:
```bash
bash ~/.config/sketchybar/sketchybarrc
```

### Verification

Check if SketchyBar is running and properly configured:
```bash
# Check service status
/opt/homebrew/bin/brew services list | grep sketchybar

# Check bar drawing status (should show "drawing": "on")
/opt/homebrew/opt/sketchybar/bin/sketchybar --query bar

# Check loaded items
/opt/homebrew/opt/sketchybar/bin/sketchybar --query bar | grep items
```

### Hiding macOS Default Menu Bar

After `task apply`, the default macOS menu bar is configured to auto-hide via:
```nix
system.defaults.NSGlobalDomain._HIHideMenuBar = true;
```

**Note**: This setting requires logout/login to take effect.

Alternatively, manually configure in System Settings:
- System Settings > Control Center > "Automatically hide and show the menu bar" > "Always"

### Troubleshooting

If SketchyBar doesn't display after starting:
1. Verify the service is running: `ps aux | grep sketchybar | grep -v grep`
2. Check bar status: `/opt/homebrew/opt/sketchybar/bin/sketchybar --query bar`
3. If `"drawing": "off"`, reload config: `bash ~/.config/sketchybar/sketchybarrc`
4. Restart service: `/opt/homebrew/bin/brew services restart sketchybar`

### Customization

Edit configuration files in `configs/sketchybar/`:
- Modify `sketchybarrc` for bar appearance and item definitions
- Edit plugin scripts for custom data display
- Adjust colors in `colors.sh`

After changes, run `task apply` and restart SketchyBar.

## Reference Documentation

- **Font Management**: See `.claude/how_to_check_font.md` for checking font installations on macOS