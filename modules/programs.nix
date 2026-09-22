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
    flake = "/home/ayaan_mirza/nix-config"; # sets the NH_OS_FLAKE variable
  };

  # dconf backend, needed for gtk3/4 apps and anything that reads/writes through
  # gsettings (theme, color-scheme, etc)
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

  # winpodx runs a rootless podman pod for its windows container (dockur/windows)
  # kvm: /dev/kvm access for the kvm backed container
  # podman: rootless podman socket access
  users.users.ayaan_mirza.extraGroups = [
    "docker"
    "podman"
    "kvm"
  ];

  # nixos's containers module writes image_copy_tmp_dir = "/nix/containers/tmp" into
  # /etc/containers/containers.conf, which is root owned and not writable for regular
  # users. rootless `podman pull` (what winpodx uses) fails with "permission denied"
  # making a temp dir for the image copy. overriding to a location any user can write
  # to
  virtualisation.containers.containersConf.settings = {
    engine.image_copy_tmp_dir = lib.mkForce "/tmp";
  };

  # pin winpodx's windows version to tiny11. only written if the file doesnt exist
  # yet, `winpodx setup` honours pod.version so no --win-version flag needed
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
    # appends the fx-autoconfig config.js to librewolf's mozilla.cfg (keeps librewolf's own prefs)
    package = pkgs.librewolf.override (old: {
      extraPrefsFiles = (old.extraPrefsFiles or [ ]) ++ [
        "${inputs.fx-autoconfig}/program/config.js"
      ];
      # dark mode on websites: RFP pins prefers-color-scheme to light so use FPP with
      # only that target exempted. lives here (mozilla.cfg) on purpose, NOT in
      # librewolf.overrides.cfg, and uses defaultPref so i can still change these in
      # Settings / about:config
      extraPrefs = (old.extraPrefs or "") + ''
        defaultPref("privacy.resistFingerprinting", false);
        defaultPref("privacy.fingerprintingProtection", true);
        defaultPref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
      '';
    });
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
    google-chrome

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
    vesktop

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
    onlyoffice-desktopeditors
    iloader
    inputs.dank-calendar.packages.${pkgs.stdenv.hostPlatform.system}.default

    # External Inputs / Custom Desktop GUI Packages
    claude-desktop-fhs
    opencode-desktop # OpenCode GUI
    config.custom.bibataMaterialCursor
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cacert ];
      env = (old.env or { }) // {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      };
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
    }))
    (inputs.efiboots.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
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
