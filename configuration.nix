    # Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "ayaan_mirza" ];  # Your exact username
    keepEnv = true;             # Preserves your shell path and environment
    persist = true;             # Remembers your password for a short time
  }];
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Allow generic dynamically-linked Linux binaries (AppImages, installers, etc.) to run
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

  environment.shellAliases = {
    nix-rebuild = "doas nixos-rebuild switch --flake ~/nix-config#Axiom";
    nix-push = "cd ~/nix-config && git add . && git commit -m \"update $(date +%Y-%m-%d_%H:%M)\" && git push";
    nix-clean = "doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d";
  };

  # Bootloader.
  boot.loader.grub.enable = false;

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 1; # Keeps only the latest NixOS generation
    extraInstallCommands = ''
      echo "auto-entries no" >> /boot/loader/loader.conf
      echo "auto-firmware no" >> /boot/loader/loader.conf

      # Secure Boot: only sign if our keys are actually enrolled in
      # firmware (Setup Mode disabled = keys enrolled). Sign
      # systemd-boot + fallback, then the current generation's
      # kernel/initrd wherever NixOS put them, then re-sign everything
      # sbctl already knows about (covers the two older kept
      # generations from nix-clean).
      if ${pkgs.sbctl}/bin/sbctl status 2>/dev/null | grep -qi "Setup Mode:.*Disabled"; then
        ${pkgs.sbctl}/bin/sbctl sign -s /boot/EFI/systemd/systemd-bootx64.efi || true
        ${pkgs.sbctl}/bin/sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI || true
        find /boot/EFI/nixos -maxdepth 1 -type f -iname "*.efi" \
          2>/dev/null -exec ${pkgs.sbctl}/bin/sbctl sign -s {} \; || true
        find /boot/kernels /boot/nixos -maxdepth 1 -type f \
          2>/dev/null -exec ${pkgs.sbctl}/bin/sbctl sign -s {} \; || true
        ${pkgs.sbctl}/bin/sbctl sign-all || true
      fi
    '';
  };

  boot.loader.timeout = 0; # Skip the systemd-boot menu, boot straight into NixOS

  boot.loader.efi.canTouchEfiVariables = true;

  # Mac-style Plymouth boot theme
  boot.plymouth = {
    enable = true;
    theme = "mac-style";
    themePackages = [ pkgs.mac-style-plymouth ];
  };

  # Needed for plymouth to actually display on shutdown/reboot (not just boot)
  boot.initrd.systemd.enable = true;

  # Silent boot — required for plymouth to actually take over the screen
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "Axiom"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Vancouver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the COSMIC Desktop Environment.
  services.displayManager.defaultSession = pkgs.lib.mkForce "cosmic";
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pantheon.apps.enable = false;

  # Polkit authentication agent — cosmic-osd isn't reliably registering
  # itself as the session's polkit agent, so run polkit_gnome as a
  # fallback graphical agent.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
  };
};
/*
  systemd.user.services.fcc-server = {
    description = "FCC Server Background Daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "%h/.local/bin/fcc-server"; # Or the absolute path to the binary if installed elsewhere
      Restart = "always";
      RestartSec = 5;
  };
};
*/

systemd.user.services.cosmic-osd-watcher = {
  description = "Watchdog for cosmic-osd";
  wantedBy = [ "graphical-session.target" ];
  partOf = [ "graphical-session.target" ];
  serviceConfig = {
    ExecStart = pkgs.writeShellScript "watch-cosmic-osd" ''
      while true; do
          if ! pgrep -x "cosmic-osd" > /dev/null; then
              systemctl --user restart cosmic-osd || true
              pkill cosmic-osd || true
          fi
          sleep 5
      done
    '';
    Restart = "always";
    RestartSec = "5s";
  };
};

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."ayaan_mirza" = {
    isNormalUser = true;
    description = "Ayaan Mirza";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Install librewolf (via the firefox module, package overridden)
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  # Nerd Fonts (needed for fastfetch/cosmic-term icon glyphs)
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # System-wide fastfetch default config (portable across machines via the flake)
  environment.etc."xdg/fastfetch/config.jsonc".source = ./dotfiles/fastfetch/config.jsonc;

  # AppImage support — registers .AppImage files with binfmt_misc so they run
  # via appimage-run automatically (NixOS lacks the FHS paths AppImages expect).
  # Also required for Gear Lever to launch AppImages on NixOS.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Symlink ~/.config/fastfetch/config.jsonc -> the live dotfiles copy, so plain `fastfetch`
  # (no -c flag) picks up edits instantly without needing a rebuild
  system.activationScripts.fastfetchSymlink = ''
    mkdir -p /home/ayaan_mirza/.config/fastfetch
    ln -sf /home/ayaan_mirza/nix-config/dotfiles/fastfetch/config.jsonc /home/ayaan_mirza/.config/fastfetch/config.jsonc
    chown -h ayaan_mirza:users /home/ayaan_mirza/.config/fastfetch/config.jsonc
  '';


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gdb
    python3
    firefoxpwa
    google-chrome
    fastfetch
    inputs.nix-software-center.packages.${stdenv.hostPlatform.system}.default
    baobab
    gnome-disk-utility
    kdePackages.partitionmanager
    curl
    #(pkgs.callPackage ./packages/cosmic-ext-control-center.nix {})
    efibootmgr
    sbctl
    claude-desktop-fhs
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
    }))
    kdePackages.kdenlive
    firefox
    libsForQt5.qtstyleplugin-kvantum
    inputs.nixos-conf-editor.packages.${system}.nixos-conf-editor
    kdePackages.kate
    gtk4
    ghostty
    ferdium
    parted
    polkit_gnome
  ];

  # ChatGPT Desktop (Codex Desktop for Linux) — installed via its
  # NixOS module (see flake.nix) instead of a raw package reference.
  # cliPackage wraps the launcher with CODEX_CLI_PATH baked in, so it
  # finds `codex` even from graphical autostart/warm-start launches
  # that don't inherit your shell's PATH.
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  
programs.steam = {
  enable = true; # Master switch, already covered in installation
  remotePlay.openFirewall = true;  # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
  # Other general flags if available can be set here.
};

programs = {
   zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        sudo-temp = "/usr/bin/sudo";
        waydroid = "/usr/bin/python3 /usr/bin/waydroid";
      };
      interactiveShellInit = ''
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.npm-global/bin:$PATH"
        fastfetch -c ~/nix-config/dotfiles/fastfetch/compact-config.jsonc
      '';
      ohMyZsh = {
         enable = true;
         theme = "xiong-chiamiov-plus";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
           "rust"
           "deno"
         ];
      };
   };
};
  
  services.flatpak.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # chiaki-ng / PS Remote Play
  networking.firewall.allowedTCPPorts = [ 9295 ];
  networking.firewall.allowedUDPPorts = [ 987 9295 9296 9297 9302 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
