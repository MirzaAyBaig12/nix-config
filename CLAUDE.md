# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Overview

This is a NixOS system configured using the Nix Flakes paradigm. The system is named "Axiom" and follows a modular structure where different aspects of the system are separated into distinct modules.

Key directories:
- `modules/` - NixOS modules organized by concern (system, desktop, programs, services)
- `dotfiles/` - User-specific configuration files
- `packages/` - Custom Nix packages
- `wallpapers/` - Desktop wallpapers

## Common Commands

### System Management
- `nix-rebuild` - Rebuild and switch to the new configuration (`doas nixos-rebuild switch --flake ~/nix-config#Axiom`)
- `nix-push` - Commit and push configuration changes (`cd ~/nix-config && git add . && git commit -m "update $(date +%Y-%m-%d_%H:%M)" && git push`)
- `nix-clean` - Delete old generations and garbage collect (`doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d`)
- `nix-generations` - List system generations (`nix-env -p /nix/var/nix/profiles/system --list-generations`)

### Development Workflow
1. Make changes to configuration files
2. Test with `nixos-rebuild test --flake ~/nix-config#Axiom` (non-destructive test)
3. If successful, apply with `nix-rebuild`
4. Commit changes with `nix-push`

### Shell Environment
- Uses Zsh with Oh-My-Zsh (theme: xiong-chiamiov-plus, plugins: git, npm, history, node, rust, deno, snap)
- Custom aliases defined in `programs.nix` under `environment.shellAliases`
- PATH includes `$HOME/.local/bin`, `$HOME/.npm-global/bin`, and `/var/lib/snapd/snap/bin`

## Module Structure

### system.nix
Handles low-level system configuration:
- Bootloader: systemd-boot with Secure Boot signing via sbctl
- rEFInd configuration (disabled by default)
- Plymouth boot theme (mac-style)
- Networking: NetworkManager enabled, specific firewall rules
- Waydroid (Android subsystem) enabled

### desktop.nix
Manages graphical environment:
- Display Manager: cosmic-greeter enabled
- Desktop Environments: Cosmic and Plasma6 both enabled
- Audio: PipeWire with PulseAudio compatibility
- Printing: CUPS enabled
- Fonts: Noto fonts, Noto Color Emoji, JetBrains Mono Nerd Font
- Background services: polkit-gnome-authentication-agent, FCC server, cosmic-osd watcher

### programs.nix
Configures user-space applications and environment:
- Zsh configuration with autosuggestions, syntax highlighting, autoenv
- Shell aliases for common Nix/Git operations
- Steam (with firewall rules for remote play)
- Firefox/Librewolf selection
- AppImage support, Nix-LD enabled
- Codex Desktop (ChatGPT) integration
- Session variables and system packages (extensive list including development tools)

### services.nix
Handles system services and security:
- Snap and Flatpak enabled
- Security: doas and sudo configured for user ayaan_mirza
- User account: ayaan_mirza (normal user, in networkmanager and wheel groups, uses zsh)
- Activation scripts:
  - Fastfetch configuration synchronization
  - Bidirectional rEFInd synchronization between ESP and git repo

## Configuration Philosophy

This system follows a declarative, reproducible approach where:
- All system configuration is version-controlled in this repository
- Changes are made by modifying Nix expression files
- The system can be entirely recreated from the flake
- Hardware-specific configuration is isolated in `hardware-configuration.nix`
- User preferences are maintained in the `dotfiles/` directory

When making changes:
1. Edit the appropriate module file based on concern
2. Rebuild and test before committing
3. Ensure changes are deterministic and reproducible