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

- **NixOS Desktop (Axiom)** — my main daily driver. Daily session is **niri** (scrollable-tiling Wayland compositor) shelled by **DankMaterialShell (DMS)**, with **COSMIC** kept installed as an alt session at the greeter. Lanzaboote-signed boot, PipeWire audio, Waydroid, and extensive customization.

See [`/.config/refind`](./.config/refind/) for my rEFInd configuration and theme, and [`/.config/niri`](./.config/niri/) for my niri + DMS config.

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
│   ├── fastfetch/                  # fastfetch configs (synced to Home Manager)
│   ├── niri/                       # niri + DMS config (kdl) — symlinked in-place via home-manager/niri.nix
│   ├── refind/                     # rEFInd configuration files
│   └── wallpapers/
├── modules/
│   ├── desktop.nix                 # dank-greeter (greetd) + niri default session, COSMIC alt session, PipeWire, CUPS, fonts, keymap
│   ├── flatpak.nix                 # declarative Flatpak remotes/packages + sync-flatpak-apps (auto-commits installs/removals)
│   ├── flatpak.packages.nix        # generated — do not hand-edit, sync-flatpak-apps owns this file
│   ├── home-manager.nix            # wires up Home Manager, imports the home-manager/ modules below
│   ├── home-manager/
│   │   ├── fastfetch.nix           # links .config/fastfetch into the HM profile
│   │   ├── niri.nix                # niri config symlink, DMS dark-mode pin + service-relink activation fixes
│   │   ├── nixd.nix                # VS Code nixd LSP settings, points at this flake's own option tree
│   │   ├── programs.hm.nix         # user-level home.packages, Flameshot, DankSearch, nix-monitor
│   │   ├── services.hm.nix         # user systemd services (polkit auth agent, fcc-server)
│   │   ├── stylix.nix              # HM-side Stylix (cursor package, GTK/dconf theming, forced dark mode)
│   │   └── zsh.nix                 # Oh-My-Zsh, PATH exports, flatpak() sync wrapper, dms shell completion
│   ├── niri.nix                    # niri compositor + DankMaterialShell shell, portals, xwayland-satellite
│   ├── programs.nix                # shell aliases, system packages, Steam/Librewolf/Codex Desktop, nix-ld, appimage support
│   ├── services.nix                # doas/sudo, user account, keyd, printing/scanning, rEFInd/systemd-boot signing
│   ├── stylix.nix                  # system-wide Stylix theming (fonts, base16 scheme, GTK/QT targets)
│   └── system.nix                  # Lanzaboote + rEFInd bootloader, Plymouth, networking, Waydroid, swap
├── packages/
│   ├── bibata-material-cursor.nix
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
| **Bootloader** | systemd-boot with Lanzaboote (signed UKIs) for Secure Boot, chainloaded from rEFInd (Catppuccin Macchiato theme) |
| **Boot Theme** | Plymouth (mac-style) |
| **Display Manager** | greetd + dank-greeter (DMS-themed login screen, niri compositor) |
| **Desktop Environments** | niri (primary — scrollable-tiling Wayland) shelled by DankMaterialShell; COSMIC kept as an alt session at the greeter |
| **Window Managers** | niri (native), COSMIC native WM (alt session) |
| **Terminal Emulator** | Ghostty |
| **Shell** | Zsh + Oh-My-Zsh (xiong-chiamiov-plus theme; plugins: git, npm, history, node, rust, deno, snap) |
| **Notification Daemon** | DankMaterialShell (niri session), COSMIC native services (alt session) |
| **Network Management** | NetworkManager |
| **Input Method** | None (default XKB/Wayland input) |
| **Web Browser** | LibreWolf (daily driver, run under `programs.firefox`'s package slot) |

### Apps & Tools
| |                                                        |
|---|--------------------------------------------------------|
| **System Monitor** | Mission Center (Flatpak, primary), GNOME System Monitor, Fastfetch (terminal), DMS system monitor widget |
| **File Manager** | COSMIC Files |
| **Media Player** | Spotify (primary), Vinyl (music), Celluloid (video) — all Flatpak |
| **Editors / IDE** | VSCodium (primary), JetBrains IDEs — IntelliJ IDEA / PyCharm / WebStorm (second), VSCode (last resort); Zed and Neovim also installed |
| **Fonts** | Noto fonts, Noto Color Emoji, JetBrains Mono Nerd Font installed system-wide; Stylix themes GTK/QT apps in DejaVu Sans / DejaVu Sans Mono |
| **Icon Theme** | Papirus-Dark, forced system-wide via Stylix (GTK + dconf) and applied to Flatpak apps via override |
| **Image Viewer** | GNOME Image Viewer / Loupe (Flatpak) |
| **Mail** | Thunderbird (Flatpak) |
| **Screenshots** | DMS Screenshot (DankMaterialShell) |
| **Screen Recording** | Kooha (Flatpak) |
| **ISO Flashing** | KDE ISO Image Writer, Impression (Flatpak) |
| **Disk & Partition Management** | GNOME Disks, KDE Partition Manager |
| **App Store / Sideloading** | Bazaar, Gear Lever, Warehouse (Flatpak) |
| **Development Tools** | Git, Python3 (pip, virtualenv), Node.js, GDB, Just, Sass |

### System-Level
| | |
|---|---|
| **Filesystem & Encryption** | Ext4, no encryption (triple-boot system) |
| **Secure Boot** | Lanzaboote (signed UKIs) + sbctl, with auto-generate and auto-enroll of keys |
| **Nix Implementation** | Lix, pinned via nixpkgs' own `lixPackageSets.stable` (always tracks this flake's exact nixpkgs rev) |
| **Android Subsystem** | Waydroid |
| **Package Formats** | Flatpak, AppImage, Nix |
 
Wallpapers: [`/wallpapers`](./.config/wallpapers)

## Screenshots

| Desktop | Fastfetch |
|---|---|
| ![desktop](_img/desktop.png) | ![fastfetch](_img/fastfetch.png) |

## System Modules

### flake.nix
Entry point — defines inputs (nixpkgs channel, home-manager, niri, DankMaterialShell, and every other flake-packaged app/overlay) and the `Axiom` nixosConfiguration output.

### system.nix
Low-level system configuration: Lanzaboote (signed UKIs) + rEFInd chainloading, Plymouth boot theme, networking (NetworkManager, firewall rules), Waydroid Android subsystem, swap, exFAT/NTFS mount points.

### desktop.nix
Graphical environment: dank-greeter (greetd) as the display manager with niri as the default session, COSMIC kept installed as an alt session, PipeWire audio (PulseAudio compat), CUPS printing, keymap, font packages.

### niri.nix
niri compositor + DankMaterialShell (panel, dock, launcher, lock screen, notifications), xwayland-satellite (pinned to 0.8.1 for a nixos-unstable regression), and per-session portal routing (COSMIC portal first, wlr fallback for screenshots/screencast).

### stylix.nix
System-wide Stylix theming: cursor theme, font stack, base16 colour scheme, and GTK/QT targets.

### programs.nix
User environment: Zsh + Oh-My-Zsh with plugins, shell aliases, desktop apps (Steam, Firefox/Librewolf, Codex Desktop), and system packages (dev tools → multimedia → custom flake-packaged GUI apps).

### services.nix
System services: Flatpak daemon (with global dark-mode + Papirus-Dark icon overrides), doas + sudo for `ayaan_mirza`, user account setup, keyd (Super-tap override for DMS spotlight), printing/scanning (hplip/sane), activation scripts for rEFInd/systemd-boot signing and dotfile cleanup.

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
