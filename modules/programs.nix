{ config, pkgs, inputs, ... }:

{
  # Shell aliases & zsh
  environment.shellAliases = {
    nix-hwgen = "doas nixos-generate-config --dir ~/nix-config";
    nix-rebuild = "doas nixos-rebuild switch --flake ~/nix-config#Axiom";
    nix-push = "cd ~/nix-config && git add . && git commit -m \"update $(date +%Y-%m-%d_%H:%M)\" && git push";
    nix-clean = "doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d";
    nix-generations = "nix-env -p /nix/var/nix/profiles/system --list-generations";
    sudo-temp = "/run/wrappers/bin/sudo";
    waydroid = "/usr/bin/python3 /usr/bin/waydroid";
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    zsh-autoenv.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="/var/lib/snapd/snap/bin:$PATH"
      fastfetch -c ~/nix-config/dotfiles/fastfetch/compact-config.jsonc
    '';
    ohMyZsh = {
      enable = true;
      theme = "xiong-chiamiov-plus";
      plugins = [ "git" "npm" "history" "node" "rust" "deno" "snap" ];
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Firefox / Librewolf
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  # AppImage & Nix-LD
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc zlib openssl curl glib libGL fuse3
  ];

  # Codex Desktop
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # Session Variables
  environment.sessionVariables = {
    PATH = [ "/var/lib/snapd/snap/bin" ];
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    vim #Text Editor
    wget #Network Downloader
    git #Version Control
    htop #Process Viewer
    gdb #Debugger
    python3 #Python Interpreter
    firefoxpwa #Firefox PWA Connector
    google-chrome #Google Chrome
    fastfetch #System Information Tool
    inputs.nix-software-center.packages.${stdenv.hostPlatform.system}.default #Install Nix Software Center
    baobab #Disk Usage Analyzer
    gnome-disk-utility #Disk Management Tool
    gnome-system-monitor #System Monitor
    kdePackages.partitionmanager #Partition Management Tool
    curl #Command Line Downloader
    (pkgs.callPackage ../packages/cosmic-ext-control-center.nix {}) #Control Center Applet for COSMIC DE
    efibootmgr #CLI EFI Entry Management
    sbctl #Secure Boot Management
    claude-desktop-fhs #Claude Desktop app for NixOS
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: { #WinPodX for Windows apps (e.x. Office 365)
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
    }))
    kdePackages.kdenlive #Video Editing Software
    firefox #Firefox Web Browser
    libreoffice #LibreOffice Suite
    vlc #VLC Media Player
    gimp #GIMP Image Editor
    libsForQt5.qtstyleplugin-kvantum #KDE Kvantum Theme Engine
    inputs.nixos-conf-editor.packages.${pkgs.stdenv.hostPlatform.system}.nixos-conf-editor #NixOS Configuration Editor
    #inputs.iloader.packages.${pkgs.stdenv.hostPlatform.system}.default #iLoader for iOS Sideloading
    kdePackages.kate #KDE Text Editor
    gtk4 #GTK4 Library
    gtk3 #GTK3 Library
    ghostty #Terminal Multiplexer
    ferdium #Ferdium Messaging App
    parted #Partition Management Tool
    polkit_gnome #Polkit Authentication Agent
    nodejs #Node.js JavaScript Runtime
    sassc #Sass Compiler
    seahorse #Seahorse Password Manager
    gnome-keyring #GNOME Keyring
    just #Just Task Runner
    refind #rEFInd Boot Manager CLI
    wl-clipboard #Wayland Clipboard Manager
    inputs.efiboots.packages.${pkgs.stdenv.hostPlatform.system}.default #GUI EFI Entry Management
    libimobiledevice #iOS Device Development Library
    proton-pass #Proton Pass Password Manager
  ];
}