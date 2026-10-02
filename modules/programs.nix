{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  appPackages = with pkgs; {
    # Web browsers and progressive web app support.
    browsers = [
      firefoxpwa
      google-chrome
      inputs.helium.packages.x86_64-linux.default
      inputs.brave-origin.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # Editors, language runtimes, and developer tools.
    development = [
      neovim
      git
      gdb
      just
      nodejs
      sassc
      python3
      python3Packages.pip
      python3Packages.virtualenv
      vscodium
      zed-editor
      sourcegit
      kdePackages.kate
      flutter
      distrobox
    ];

    # Notes, office work, and personal productivity.
    productivity = [
      obsidian
      ferdium
      onlyoffice-desktopeditors
    ];

    # Chat and communication clients.
    communication = [
      vesktop
    ];

    # Audio and video playback.
    mediaPlayback = [
      vlc
    ];

    # Image editing and video production.
    creativeTools = [
      gimp
      kdePackages.kdenlive
    ];

    # Games, compatibility tools, and their runtime support.
    gaming = [
      gamemode
      winetricks
      hydralauncher
      # Needed by hydralauncher/umu-run's Steam Runtime container.
      bubblewrap
    ];

    # File management, terminal, screenshots, and desktop themes.
    desktop = [
      kdePackages.dolphin
      nautilus
      ghostty
      wl-clipboard
      grim
      slurp
      satty
      adwaita-icon-theme
      papirus-icon-theme
      hicolor-icon-theme
    ];

    # General command line and desktop utilities.
    systemUtilities = [
      wget
      curl
      htop
      baobab
      gnome-system-monitor
      gh
      gsettings-desktop-schemas
      glib
      libnotify
      espeak
      unzip
      libsForQt5.qtstyleplugin-kvantum
    ];

    # Keyring, authentication, and password tools.
    security = [
      seahorse
      gnome-keyring
      kdePackages.ksshaskpass
      proton-pass
    ];

    # Storage, devices, printing, virtualization, and boot tools.
    hardware = [
      gnome-disk-utility
      kdePackages.partitionmanager
      parted
      sbctl
      refind
      libimobiledevice
      hplip
      system-config-printer
      gnome-boxes
      ventoy-full-gtk
      acpi
    ];

    # Applications and packages supplied by other flakes.
    externalApps = [
      inputs.chatgpt-desktop.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt
      claude-desktop-fhs
      opencode-desktop
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
      inputs.nix-fdm.packages.${pkgs.system}.default
      inputs.iloader.packages.${pkgs.system}.default
    ];

    # Command line coding agents.
    aiAgents = [
      inputs.llm-agents.packages.${pkgs.system}.claude-code
      inputs.llm-agents.packages.${pkgs.system}.opencode
    ];
  };
in

{

  # Keep installed applications grouped by purpose.
  environment.systemPackages =
    appPackages.browsers
    ++ appPackages.development
    ++ appPackages.productivity
    ++ appPackages.communication
    ++ appPackages.mediaPlayback
    ++ appPackages.creativeTools
    ++ appPackages.gaming
    ++ appPackages.desktop
    ++ appPackages.systemUtilities
    ++ appPackages.security
    ++ appPackages.hardware
    ++ appPackages.externalApps
    ++ appPackages.aiAgents;

  imports = [
    inputs.blip.nixosModules.default
    inputs.natsumi.nixosModules.default
    inputs.cpak.nixosModules.default
  ];

  services.cpak.enable = true;

  # Shell and desktop utilities
  programs.zsh.enable = true; # config lives in modules/home-manager/zsh.nix
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
    flake = "/home/ayaan_mirza/nix-config";
  };
  programs.dconf.enable = true;
  programs.direnv.enable = true;
  programs.kdeconnect.enable = true;

  # Container tools
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  users.users.ayaan_mirza.extraGroups = [
    "docker"
    "podman"
    "kvm"
  ];
  virtualisation.containers.containersConf.settings.engine.image_copy_tmp_dir = lib.mkForce "/tmp";
  system.userActivationScripts.winpodxConfig = ''
    cfg="$HOME/.config/winpodx/winpodx.toml"
    if [[ ! -f "$cfg" ]]; then
      mkdir -p "$HOME/.config/winpodx"
      printf '[pod]\nversion = "tiny11"\n' > "$cfg"
      chmod 600 "$cfg"
    fi
  '';

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # Browsers
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf.override (old: {
      extraPrefsFiles = (old.extraPrefsFiles or [ ]) ++ [ "${inputs.fx-autoconfig}/program/config.js" ];
      extraPrefs = (old.extraPrefs or "") + ''
        defaultPref("privacy.resistFingerprinting", false);
        defaultPref("privacy.fingerprintingProtection", true);
        defaultPref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
      '';
    });
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };
  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";
  programs.natsumi = {
    enable = true;
    browser = "firefox";
    homeDirectory = "/home/ayaan_mirza";
    profile = "x9ezxqe3.default-default";
  };

  # App compatibility and desktop integrations
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
  programs.blip.enable = true;

}
