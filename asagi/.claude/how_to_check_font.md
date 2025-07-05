# How to Check Fonts on macOS

This document describes various methods to check installed fonts on macOS, particularly useful when working with Nix Home Manager font installations.

## Font Locations on macOS

### User Fonts
```bash
ls -la ~/Library/Fonts/
```
- User-specific fonts installed via Home Manager or manually
- Most commonly used location for checking if fonts are available

### System Fonts
```bash
ls -la /System/Library/Fonts/
```
- System-wide fonts provided by macOS
- Generally not modified by package managers

### Nix Store Fonts
```bash
ls -la ~/.nix-profile/share/fonts/
```
- Fonts installed via Nix/Home Manager
- Symlinks to actual font files in the nix store

## Checking Specific Font Installation

### Check if a specific font is installed
```bash
# Look for HackGen font example
ls -la ~/Library/Fonts/ | grep -i hackgen
```

### Verify Nix font installation
```bash
# Check the nix store path
ls -la ~/.nix-profile/share/fonts/

# Follow symlinks to see actual font files
ls -la /nix/store/*/share/fonts/hackgen-nf/
```

## Font Cache and System Integration

### macOS Font Cache
- macOS automatically manages font cache
- Fonts in ~/Library/Fonts/ are immediately available to applications
- No manual cache refresh needed unlike Linux systems

### Note about fc-list
- `fc-list` (fontconfig) is not available by default on macOS
- Use directory listing methods instead
- If fontconfig is needed, install via Homebrew or Nix

## Common Issues and Solutions

### Font not showing in applications
1. Check if font file exists in ~/Library/Fonts/
2. Restart the application
3. If using Nix, ensure `fonts.fontconfig.enable = true;` is set

### Nix Home Manager font installation
- Fonts are automatically copied to ~/Library/Fonts/ when fontconfig is enabled
- Check both the nix store and user font directory
- Font names in applications match the font file names (without .ttf extension)

## Examples

### Checking HackGen Nerd Font installation
```bash
# Check user fonts directory
ls -la ~/Library/Fonts/ | grep -i hackgen

# Expected output:
# HackGen35ConsoleNF-Regular.ttf
# HackGen35ConsoleNF-Bold.ttf
# HackGenConsoleNF-Regular.ttf
# HackGenConsoleNF-Bold.ttf
```

### Verifying font availability for applications
- Font name in applications: "HackGen35 Console NF"
- Corresponds to file: "HackGen35ConsoleNF-Regular.ttf"
- Bold variant: "HackGen35ConsoleNF-Bold.ttf"