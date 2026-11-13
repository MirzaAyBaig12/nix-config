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
      firefox
      helium
      tor-browser
      ungoogled-chromium
    ];

    # Editors, language runtimes, and developer tools.
    development = [
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
      dux-calendar
      chatgpt
    ];

    # Chat and communication clients.
    communication = [
      vesktop
      teams-for-linux
      telegram-desktop
      slack
    ];

    # Audio and video playback.
    mediaPlayback = [
      vlc
      kid3-qt # bulk tag + cover art editing
    ];

    # GStreamer core + plugins (Arch names mapped to nixpkgs).
    gstreamer = with pkgs.gst_all_1; [
      gstreamer # gstreamer
      gst-plugins-base # gst-plugins-base + gst-plugins-base-libs
      gst-plugins-bad # gst-plugins-bad-libs + gst-plugin-va (va plugin lives in -bad)
      gst-plugins-good # MKV support, format conversion, photo compression (dms Cast)
      gst-libav # ffmpeg-based codecs, format conversion (dms Cast)
      pkgs.libheif # HEIC support (dms Cast)
      pkgs.pipewire # gst-plugin-pipewire (ships inside the pipewire package)
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
      protonplus

      # Needed by hydralauncher/umu-run's Steam Runtime container.
      bubblewrap
      chiaki-ng
    ];

    # File management, terminal, screenshots, and desktop themes.
    desktop = [
      kdePackages.dolphin
      kdePackages.keepsecret
      (yazi.override { _7zz = _7zz-rar; }) # RAR extraction support
      ghostty
      alacritty
      wl-clipboard
      grim
      slurp
      satty
      adwaita-icon-theme
      papirus-icon-theme
      hicolor-icon-theme
      openscreen
    ];

    # General command line and desktop utilities.
    systemUtilities = [
      wget
      curl
      icu
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
      matugen
      ffmpeg
      nil
      iloader # iOS sideloader (overlay in flake.nix), talks to usbmuxd, see modules/services.nix
      (python3.withPackages (ps: [ ps.pillow ]))
    ];

    # Keyring, authentication, and password tools.
    security = [
      seahorse
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
      acpi
    ];

    # Applications and packages supplied by other flakes.
    externalApps = [

      # WinPodX
      (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.cacert ];
        env = (old.env or { }) // {
          SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        };
        doCheck = false;
        checkPhase = "echo skipping winpodx tests";
        installCheckPhase = "echo skipping winpodx tests";
      }))

      # Utilities
      inputs.dux-gop.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.lumine-capture.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.doubletake # AirPlay sender (dms Cast)
      pkgs.pulseaudio # pactl only, AirPlay audio routing (daemon stays off, pipewire-pulse handles it)

      # Development
      inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.compas-tools
      inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.openidea
    ];

    # Command line coding agents.
    aiAgents = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex  
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi

      # Claude Desktop (wrapped via the overlay in flake.nix).
      pkgs.claude-desktop
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
    ++ appPackages.gstreamer
    ++ appPackages.creativeTools
    ++ appPackages.gaming
    ++ appPackages.desktop
    ++ appPackages.systemUtilities
    ++ appPackages.security
    ++ appPackages.hardware
    ++ appPackages.externalApps
    ++ appPackages.aiAgents;

    
  services.cpak.enable = true;

  # Shell and desktop utilities.
  programs.zsh.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
    flake = "/home/ayaan_mirza/nix-config";
  };

  programs.dconf.enable = true;
  programs.direnv.enable = true;
  programs.kdeconnect.enable = true;

  # Container tools.
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # dockur/windows runs wsddn as uid 995 inside the container, which is the
  # same uid as the host's rtkit user (no userns remap). rtkit-daemon caps
  # RLIMIT_NPROC at 3 for that uid, so if the container restarts first,
  # rtkit's pthread_create fails, it hangs without answering on D-Bus, and
  # xdg-desktop-portal/WirePlumber time out. Start rtkit before docker.
  systemd.services.docker = {
    after = [ "rtkit-daemon.service" ];
    wants = [ "rtkit-daemon.service" ];
  };

  virtualisation.containers.containersConf.settings.engine.image_copy_tmp_dir =
    lib.mkForce "/tmp";

  system.userActivationScripts.winpodxConfig = ''
    cfg="$HOME/.config/winpodx/winpodx.toml"
    if [[ ! -f "$cfg" ]]; then
      mkdir -p "$HOME/.config/winpodx"
      printf '[pod]\nversion = "tiny11"\n' > "$cfg"
      chmod 600 "$cfg"
    fi
  '';

  # Gaming.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;

  # Browsers.
  # LibreWolf is configured through programs.natsumi.
  programs.natsumi = {
    enable = false;
    browser = "librewolf";
    homeDirectory = "/home/ayaan_mirza";
    profile = "f4jwAmgv.Profile 1";
    librewolf.DarkModeFix = true;
  };

  # App compatibility and desktop integrations.
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

    # dlopen'd by dms Cast's prebuilt cast-helper (libgstreamer/app/video/pbutils).
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

  programs.blip.enable = true;
  programs.blip.autostart.enable = false;

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
  };
}
