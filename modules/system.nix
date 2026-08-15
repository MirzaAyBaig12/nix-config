{ config, lib, pkgs, ... }:

{

  # Explicit env vars for nh (belt-and-suspenders alongside programs.nh.flake,
  # since NH_FLAKE via the module option has been flaky to propagate to
  # already-open shells after a rebuild)
  environment.variables = {
    NH_FLAKE = "/home/ayaan_mirza/nix-config";
    NH_OS_FLAKE = "/home/ayaan_mirza/nix-config";
    NH_ELEVATION_STRATEGY = "doas";
    XCURSOR_THEME = "Bibata-Material-Slate";
    XCURSOR_SIZE = "20";
    GTK_THEME = "Orchis-Purple-Dark:dark";
  };


  environment.systemPackages = [ pkgs.exfatprogs ];

    fileSystems."/mnt/Shared" = {
      device = "/dev/disk/by-uuid/7AFE-F4AA";
      fsType = "exfat";
      options = [
        "nofail"                    # don't block boot if this fails to mount
        "x-systemd.device-timeout=5" # stop waiting after 5s instead of hanging
        "uid=1000"                  # mount owned by your user, not root
        "gid=100"
        "umask=0022" 
      ];
    };

  # Shell aliases
  environment.shellAliases = {
    nix-hwgen = "doas nixos-generate-config --dir ~/nix-config";
    nix-rebuild = "doas nixos-rebuild switch --flake ~/nix-config#Axiom";
    nix-push = "cd ~/nix-config && git add . && git commit -m \"update $(date +%Y-%m-%d_%H:%M)\" && git push";
    nix-clean = "doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d";
    nix-generations = "nix-env -p /nix/var/nix/profiles/system --list-generations";
    sudo-temp = "/run/wrappers/bin/sudo";
    waydroid = "/usr/bin/python3 /usr/bin/waydroid";
    zsh-reload = "omz reload";
  };

  # Bootloader setup (Lanzaboote — signed UKIs for Secure Boot)
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl"; # reuses your existing enrolled sbctl keys

    # Auto-generate Secure Boot keys in pkiBundle if they don't already
    # exist yet (runs as a systemd service on boot, not during switch/install)
    autoGenerateKeys.enable = true;

    # Auto-enroll the generated keys into firmware. Keeps Microsoft keys
    # included (default/safe) so Option ROMs signed by MS still load.
    autoEnrollKeys = {
      enable = true;
      includeMicrosoftKeys = true;
      autoReboot = true; # reboots once automatically so enrollment finishes same session
    };
  };

  boot.loader.timeout = 0;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Re-install rEFInd and re-sign it after every rebuild (chainloads
  # Lanzaboote's signed UKIs + Windows). Activation scripts already run
  # as root, so no doas here — doas caused emergency-mode boot failures
  # on gens 133/134 (PAM helper wasn't reachable this early in boot).
  # PATH is extended because activation scripts run with a stripped PATH
  # that doesn't include sed/coreutils, which refind-install needs internally.
  system.activationScripts.refind-sign = {
    text = ''
      export PATH="${lib.makeBinPath [ pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.gnugrep pkgs.util-linux ]}:$PATH"
      ${pkgs.refind}/bin/refind-install --yes
      ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/refind/refind_x64.efi
    '';
    deps = [ ];
  };

  # Plymouth boot theme & silent boot
  boot.plymouth = {
    enable = true;
    theme = "mac-style";
    themePackages = [ pkgs.mac-style-plymouth ];
  };
  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [ "squashfs" ]; #Enable squashfs for Snap

  # FHS compat symlinks — some non-Nix apps/scripts hardcode /bin/bash, /bin/sh
  # instead of resolving via PATH. /usr/bin/env is already provided by NixOS.
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    "L+ /bin/sh - - - - ${pkgs.bash}/bin/sh"
  ];

  # Networking & Firewall
  networking.hostName = "Axiom";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 9295 ];
  networking.firewall.allowedUDPPorts = [ 987 9295 9296 9297 9302 ];

  # Waydroid
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
}