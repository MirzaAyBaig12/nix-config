<h2 align="center">:snowflake: Axiom Nix Config :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-26.11-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://github.com/nixos/flakes">
        <img src="https://img.shields.io/badge/Nix%20Flakes-enabled-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
  </a>
</p>

> My configuration is becoming more and more complex, and **it will be difficult for beginners to
> read**. If you are new to NixOS and want to see how I use it, I would recommend looking at older
> commits or branches first, which will be much easier to understand**.

This repository is home to the nix code that builds my system:

1. **NixOS Desktop**: My main daily driver - NixOS with Cosmic and Plasma6 desktop environments, PipeWire audio, Waydroid Android subsystem, and extensive customization

See [./modules/](./modules/) for details of each configuration module.

See [./dotfiles/](./dotfiles/) for user-specific configuration files synchronized via activation scripts.

## Why NixOS & Flakes?

Nix allows for easy-to-manage, collaborative, reproducible deployments. This means that once
something is setup and configured once, it works (almost) forever. If someone else shares their
configuration, anyone else can just use it (if you really understand what you're copying/referring
now).

As for Flakes, they make dependency management and reproducibility trivial by locking inputs
and providing a clean interface for outputs.

**Want to know NixOS & Flakes in detail? Looking for a beginner-friendly tutorial or best practices?
The NixOS documentation and the Nix Pills are excellent resources.**

## Components

|                                                                | Axiom NixOS                                                                                                        |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Bootloader**                                                 | systemd-boot with Secure Boot signing via sbctl                                                                    |
| **Boot Theme**                                                 | Plymouth (mac-style)                                                                                               |
| **Optional Boot Menu**                                         | rEFInd with Catppuccin macchiato theme                                                                             |
| **Display Manager**                                            | cosmic-greeter                                                                                                     |
| **Desktop Environments**                                       | Cosmic (primary) and Plasma6                                                                                       |
| **Window Managers**                                            | Cosmic's native WM and KWin (Plasma6)                                                                              |
| **Terminal Emulator**                                          | Ghostty (default)                                                                                                  |
| **Shell**                                                      | Zsh with Oh-My-Zsh (xiong-chiamiov-plus theme, plugins: git, npm, history, node, rust, deno, snap)                |
| **Status Bar / Notification Daemon**                           | Cosmic's native services                                                                                           |
| **Color Scheme**                                               | System-wide via Qt/GTK themes and terminal configurations                                                          |
| **Network Management Tool**                                    | NetworkManager                                                                                                     |
| **Input Method Framework**                                     | None (using default XKB/Wayland input)                                                                             |
| **System Resource Monitor**                                    | Fastfetch (terminal), Built-in DE monitors                                                                         |
| **File Manager**                                               | Files (COSMIC), Dolphin (KDE)                                                                      |
| **Shell**                                                      | Zsh                                                                                                                |
| **Media Player**                                               | mpv, VLC                                                                                                           |
| **Editors / IDE**                                              | Neovim, VS Code, Vim                                                                                               |
| **Fonts**                                                      | Noto fonts, Noto Color Emoji, JetBrains Mono Nerd Font                                                             |
| **Image Viewer**                                               | Gwenview, gThumb                                                                                                   |
| **Screenshot Software**                                        | COSMIC Screenshot (Wayland), Spectacle (KDE)                                                                       |
| **Screen Recording**                                           | OBS                                                              |
| **Filesystem & Encryption**                                    | Ext4 (No encryption, this is a Dual Boot System)                                                                   |
| **Secure Boot**                                                | Enabled with sbctl for automatic signing                                                                           |
| **Android Subsystem**                                          | Waydroid                                                                                                           |
| **Package Formats**                                            | Snap, Flatpak, AppImage, Nix                                                                                       |
| **Development Tools**                                          | Git, Python3, Node.js, Rust, Java, Go, etc.                                                                        |

Wallpapers: https://github.com/MirzaAyBaig12/nix-config/tree/main/wallpapers

## Screenshots

![desktop](./_img/axiom-desktop.webp)

![fastfetch](./_img/axiom-fastfetch.webp)


## System Modules

### system.nix
Handles low-level system configuration including bootloader (systemd-boot with sbctl Secure Boot), networking (NetworkManager), and Waydroid Android subsystem.

### desktop.nix
Configures the graphical environment with cosmic-greeter display manager, both Cosmic and Plasma6 desktop environments, PipeWire audio with PulseAudio compatibility, printing via CUPS, and font configuration.

### programs.nix
Defines user environment including Zsh with Oh-My-Zsh and extensive plugins, shell aliases for common operations, desktop applications (Steam, Firefox/Librewolf, Codex Desktop), and system packages ranging from development tools to multimedia applications.

### services.nix
Manages system services including Snap and Flatpak daemons, security configuration (doas and sudo for user ayaan_mirza), user account setup, and activation scripts for dotfile synchronization (Fastfetch config and bidirectional rEFInd sync).

## Why This Setup?

- **It should just work**: I spend zero time debugging basic functionality
- **Keep it recreational**: If configuring something takes more fun than it's worth, I'll use defaults
- **Version control everything**: If it's not in git, it might as well not exist
- **Hardware separation**: All machine-specific stuff lives in hardware-configuration.nix
- **Prefer flakes**: They make dependency management and reproducibility trivial

## What You Won't Find Here

- Instructions for others to install this (it's highly personalized to my hardware and preferences)
- Explanations of basic NixOS concepts (assumes familiarity with NixOS/Flakes)
- Attempts to make this "universal" or "generic" - this is my personal setup
- Apologies for using unfree packages (I need some proprietary stuff for my workflow)
- Over-engineering: I optimize for my actual usage, not hypothetical edge cases

This configuration evolves as my needs and interests change. What you see here is a snapshot of what works for me on August 8, 2026.

