<h2 align="center">:snowflake: ☭ Комиссар Блятников's Nix Config ☭ :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-26.11-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://github.com/nixos/flakes">
        <img src="https://img.shields.io/badge/Nix%20Flakes-enabled-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
</p>

> My configuration is becoming more and more complex, but it should be readable for beginners as it is clearly organized into modules and contains comments for guidance.

This repository is home to the nix code that builds my system:

- **NixOS Desktop (Axiom)** — my main daily driver, running Cosmic and Plasma6 desktop environments, PipeWire audio, Waydroid, and extensive customization.

See [`/.config/refind`](./.config/refind/) for my rEFInd configuration and theme. 

See [`/modules/`](./modules/) for each configuration module, and [`/modules/home-manager/`](./modules/home-manager/) for user-specific config files configured as modules within home-manager.
 
## Hardware

**Axiom** — HP Pavilion x360
- **CPU:** Intel Core i7-1255U
- **GPU:** Intel Iris Xe (integrated)
- **RAM:** 16GB

> Getting a new machine at some point down the line — when that happens this section (and probably a lot of hardware-specific config) gets an update.

## Structure

```
.
├── .config/
│   ├── fastfetch/                 # fastfetch configs (synced to Home Manager)
│   ├── refind/                    # rEFInd configuration files
│   ├── themes/
│   └── wallpapers/
├── modules/
│   ├── desktop.nix                 # cosmic-greeter, Cosmic + Plasma6, PipeWire, CUPS, fonts, 
│   ├── flatpak.nix                 # declarative Flatpak remotes/packages + sync-flatpak-apps (auto-commits installs/removals)
│   ├── flatpak.packages.nix        # generated — do not hand-edit, sync-flatpak-apps owns this file
│   ├── home-manager.nix            # wires up Home Manager, imports the home-manager/ modules below
│   ├── home-manager/
│   │   ├── fastfetch.nix           # links .config/fastfetch into the HM profile
│   │   ├── nixd.nix                # VS Code nixd LSP settings, points at this flake's own option tree
│   │   ├── programs.hm.nix         # user-level home.packages
│   │   └── zsh.nix                 # Oh-My-Zsh, PATH exports, flatpak() wrapper that triggers the sync script
│   ├── programs.nix                # shell aliases, system packages, Steam/Librewolf/Codex Desktop, nix-ld, appimage support
│   ├── services.nix                # doas/sudo, user account
│   └── system.nix                  # bootloader, Secure Boot signing via sbctl, Plymouth, networking, Waydroid
├── packages/
│   ├── cosmic-ext-applet-mounter.nix
│   ├── cosmic-ext-control-center.nix
│   └── winpodx.nix                 # containerized Windows via Podman, built from its own flake
├── _img/                           # README screenshots
├── CLAUDE.md                       
├── configuration.nix               # entry point — imports every module
├── flake.nix / flake.lock
└── hardware-configuration.nix
```

## Components

### Desktop Environment & Shell
| | |
|---|---|
| **Bootloader** | rEFInd chainloading systemd-boot with Secure Boot signing via sbctl |
| **Boot Theme** | Plymouth (mac-style) |
| **Optional Boot Menu** | rEFInd with Catppuccin macchiato theme |
| **Display Manager** | cosmic-greeter |
| **Desktop Environments** | Cosmic (primary), Plasma6 |
| **Window Managers** | Cosmic native WM, KWin (Plasma6) |
| **Terminal Emulator** | Ghostty |
| **Shell** | Zsh + Oh-My-Zsh (xiong-chiamiov-plus theme; plugins: git, npm, history, node, rust, deno, snap) |
| **Notification Daemon** | Cosmic native services |
| **Network Management** | NetworkManager |
| **Input Method** | None (default XKB/Wayland input) |

### Apps & Tools
| |                                                        |
|---|--------------------------------------------------------|
| **System Monitor** | Fastfetch (terminal), built-in DE monitors             |
| **File Manager** | Files (COSMIC), Dolphin (KDE)                          |
| **Media Player** | mpv, VLC                                               |
| **Editors / IDE** | IntelliJ IDEA, PyCharm, VSCode, VSCodium, Neovim       |
| **Fonts** | Noto fonts, Noto Color Emoji, JetBrains Mono Nerd Font |
| **Image Viewer** | Gwenview, gThumb                                       |
| **Screenshots** | COSMIC Screenshot (COSMIC), Spectacle (KDE)            |
| **Screen Recording** | OBS                                                    |
| **Development Tools** | Git, Python3, Node.js, Rust, Java, Go, etc.            |

### System-Level
| | |
|---|---|
| **Filesystem & Encryption** | Ext4, no encryption (dual-boot system) |
| **Secure Boot** | Enabled via sbctl, auto-signing |
| **Android Subsystem** | Waydroid |
| **Package Formats** | Snap, Flatpak, AppImage, Nix |
 
Wallpapers: [`/wallpapers`](./.config/wallpapers)

## Screenshots

| Desktop | Fastfetch |
|---|---|
| ![desktop](_img/desktop.png) | ![fastfetch](_img/fastfetch.png) |

## System Modules

### flake.nix
Entry point — defines inputs (nixpkgs channel, home-manager, any overlays) and outputs for the system.

### system.nix
Low-level system configuration: bootloader (systemd-boot + sbctl Secure Boot), networking (NetworkManager), Waydroid Android subsystem.

### desktop.nix
Graphical environment: cosmic-greeter display manager, Cosmic + Plasma6 desktop environments, PipeWire audio (PulseAudio compat), CUPS printing, font configuration.

### programs.nix
User environment: Zsh + Oh-My-Zsh with plugins, shell aliases, desktop apps (Steam, Firefox/Librewolf, Codex Desktop), and system packages (dev tools → multimedia).

### services.nix
System services: Snap/Flatpak daemons, security config (doas + sudo for `ayaan_mirza`), user account setup, activation scripts for dotfile sync (Fastfetch config, bidirectional rEFInd sync).

### home-manager.nix
User-level configuration managed through Home Manager. Mirrors the modular structure of the main configuration, keeping dotfiles and program configs organized into separate modules. (See [`/modules/home-manager`](./modules/home-manager/))

## Why This Setup?

- **It should just work** — zero time spent debugging basic functionality
- **Keep it recreational** — if configuring something takes more effort than it's worth, I use defaults
- **Version control everything** — if it's not in git, it might as well not exist
- **Organization** — rather than directly declaring everything, they are loaded as modules (See [`/modules/`](./modules/))
- **Prefer flakes** — trivial dependency management and reproducibility

## What You Won't Find Here

- Instructions for others to install this (highly personalized to my hardware/preferences)
- Explanations of basic NixOS concepts (assumes familiarity with NixOS/Flakes)
- Attempts to make this "universal" or "generic" — this is my personal setup
- Apologies for unfree packages (I need some proprietary stuff for my workflow)
- Over-engineering — I optimize for actual usage, not hypothetical edge cases

This configuration evolves as my needs and interests change — check `git log` for what's current.
