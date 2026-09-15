{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

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
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # WinPodX runs a rootless Podman pod for its Windows container (dockur/windows).
  # kvm    — /dev/kvm access for the KVM-backed container
  # podman — rootless Podman socket access
  users.users.ayaan_mirza.extraGroups = [
    "docker"
    "podman"
    "kvm"
  ];

  # NixOS's containers module writes image_copy_tmp_dir = "/nix/containers/tmp"
  # into /etc/containers/containers.conf, which is root-owned with no write
  # access for regular users — rootless `podman pull` (used by winpodx) fails
  # with "permission denied" creating a temp dir for the image copy.
  # Override to a location every user can write to.
  virtualisation.containers.containersConf.settings = {
    engine.image_copy_tmp_dir = lib.mkForce "/tmp";
  };

  # Pin winpodx's Windows version to Tiny11. Written only if the file doesn't
  # already exist — `winpodx setup` honours pod.version, no --win-version
  # flag needed.
  system.userActivationScripts.winpodxConfig = ''
    cfg="$HOME/.config/winpodx/winpodx.toml"
    if [[ ! -f "$cfg" ]]; then
      mkdir -p "$HOME/.config/winpodx"
      printf '[pod]\nversion = "tiny11"\n' > "$cfg"
      chmod 600 "$cfg"
    fi
  '';

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
    stdenv.cc.cc
    zlib
    openssl
    curl
    glib
    libGL
    fuse3
  ];

  # Codex Desktop
  programs.codexDesktopLinux = {
    enable = true;
    linuxFeatures = [ "read-aloud" ];
  };

  # Session Variables
  environment.sessionVariables = {
    PATH = [ "/var/lib/snapd/snap/bin" ];
    XDG_DATA_DIRS = [ "/run/current-system/sw/share" ];
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # ==========================================
    # 1. BROWSERS & WEB
    # ==========================================
    firefox
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
    papirus-icon-theme
    hicolor-icon-theme
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
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cacert ];
      env = (old.env or { }) // {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
    }))
    (pkgs.callPackage ../packages/cosmic-ext-control-center.nix { })
    (pkgs.callPackage ../packages/cosmic-ext-applet-mounter.nix { })
    (pkgs.callPackage ../packages/bibata-material-cursor.nix { })
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.cacert
        pkgs.makeWrapper
      ];
      env = (old.env or { }) // {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
      # Nix-store source files are always 444 (read-only). winpodx's
      # shutil.copy2() preserves that mode on the *destination* copy (the
      # icon + .desktop launchers under ~/.local/share/...), so the first
      # `winpodx setup` succeeds but any re-run trying to overwrite those
      # same files crashes with PermissionError (kernalix7/winpodx#867).
      # Force the write bit back on before each run so re-running setup
      # never chokes on its own previous output.
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/winpodx --run '
          chmod -f u+w \
            "$HOME/.local/share/icons/hicolor/scalable/apps/winpodx.svg" \
            "$HOME/.local/share/applications/winpodx.desktop" \
            "$HOME/.local/share/applications/winpodx-gui.desktop" 2>/dev/null || true
        '
      '';
    }))
    (inputs.efiboots.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cacert ];
      env = (old.env or { }) // {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
    }))
    (inputs.look.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cacert ];
      env = (old.env or { }) // {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
    }))
    inputs.nix-fdm.packages.${pkgs.system}.default # Free Download Manager

    # ==========================================
    # 5. DEDICATED AI CODING AGENTS (LLM Agents Flake)
    # ==========================================
    inputs.llm-agents.packages.${pkgs.system}.claude-code
    inputs.llm-agents.packages.${pkgs.system}.pi
    inputs.llm-agents.packages.${pkgs.system}.opencode
  ];
}
