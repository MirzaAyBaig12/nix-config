{ config, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ]; # provides claude-desktop-fhs below

  # Enable Zsh
  programs.zsh.enable = true; # config lives in modules/home-manager/zsh.nix

  # Enable NH 
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
    flake = "/home/ayaan_mirza/nix-config"; # sets NH_OS_FLAKE variable for you
  };

  # dconf backend — needed for GTK3/4 apps and anything reading/writing
  # via gsettings (theme, color-scheme, etc.)
  programs.dconf.enable = true;

  # Enable Direnv
  programs.direnv.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Enable Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
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

  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";

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
    linuxFeatures = [ "read-aloud" ];
  }; 

  # Session Variables
  environment.sessionVariables = {
    PATH = [ "/var/lib/snapd/snap/bin" ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # ==========================================
    # 1. BROWSERS & WEB
    # ==========================================
    google-chrome
    firefox
    floorp-bin
    firefoxpwa

    # ==========================================
    # 2. DEVELOPMENT & PROGRAMMING TOOLS
    # ==========================================
    vim
    neovim
    git
    gdb
    just
    nodejs
    sassc
    python3
    python3Packages.pip
    python3Packages.virtualenv
    vscode
    vscodium
    zed-editor
    jetbrains.idea
    jetbrains.webstorm
    jetbrains.pycharm
    sourcegit
    distrobox
    kdePackages.dolphin

    # ==========================================
    # 3. MEDIA, GRAPHICS & ENTERTAINMENT
    # ==========================================
    vlc
    gimp
    kdePackages.kdenlive
    kdePackages.kate
    adwaita-icon-theme
    gamemode
    winetricks
    ghostty
    grim
    slurp
    satty

    # ==========================================
    # 4. SYSTEM & UTILITIES (CLI / GUI)
    # ==========================================
    wget
    curl
    htop
    baobab
    gnome-disk-utility
    gnome-system-monitor
    kdePackages.partitionmanager
    parted
    efibootmgr
    sbctl
    refind
    wl-clipboard
    seahorse
    gnome-keyring
    kdePackages.ksshaskpass
    libimobiledevice
    idescriptor
    hplip
    system-config-printer
    gnome-boxes
    gsettings-desktop-schemas
    glib
    ptyxis
    ventoy-full-gtk
    proton-pass
    ferdium
    libsForQt5.qtstyleplugin-kvantum
    unzip
    flutter

    # External Inputs / Custom Desktop GUI Packages
    claude-desktop-fhs
    opencode-desktop # OpenCode GUI[cite: 2]
    (inputs.nix-software-center.packages.${stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.cacert ];
      env = (old.env or {}) // { SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; };
    }))
    (pkgs.callPackage ../packages/cosmic-ext-control-center.nix {})
    (pkgs.callPackage ../packages/cosmic-ext-applet-mounter.nix {})
    (pkgs.callPackage ../packages/bibata-material-cursor.nix {})
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: { 
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.cacert ];
      env = (old.env or {}) // { SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; };
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
    }))
    (inputs.efiboots.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.cacert ];
      env = (old.env or {}) // { SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; };
    }))
    (inputs.look.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.cacert ];
      env = (old.env or {}) // { SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; };
    }))
    (inputs.custom-packages.packages.${pkgs.stdenv.hostPlatform.system}.ab-download-manager.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.cacert ];
      env = (old.env or {}) // { SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; };
    }))

    # ==========================================
    # 5. DEDICATED AI CODING AGENTS (LLM Agents Flake)
    # ==========================================
    inputs.llm-agents.packages.${pkgs.system}.claude-code
    inputs.llm-agents.packages.${pkgs.system}.pi
    inputs.llm-agents.packages.${pkgs.system}.opencode
  ];
}