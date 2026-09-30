{
  config,
  lib,
  pkgs,
  ...
}:

{
  # System-wide environment
  # setting the nh env vars explicitly too just in case. NH_FLAKE from
  # programs.nh.flake is flaky about reaching shells that are already open after a
  # rebuild
  environment.variables = {
    NH_FLAKE = "/home/ayaan_mirza/nix-config";
    NH_OS_FLAKE = "/home/ayaan_mirza/nix-config";
    NH_ELEVATION_STRATEGY = "doas";
    XCURSOR_THEME = "Bibata-Material-Lilac";
    XCURSOR_SIZE = "30";
    NIXOS_INSTALL_BOOTLOADER = "true";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # Graphical and user session environment
  environment.sessionVariables = {
    # /home/ayaan_mirza/.local/bin (fcc-claude and other personal scripts)
    # was only ever on PATH inside interactive zsh — GUI apps launched from
    # the niri/DMS session directly (VSCode, GitCharm's spawn calls, etc)
    # never saw it. This puts it in the actual session-wide PATH instead.
    PATH = [
      "/var/lib/snapd/snap/bin"
      "/home/ayaan_mirza/.local/bin"
    ];
    XDG_DATA_DIRS = [ "/run/current-system/sw/share" ];
  };

  environment.systemPackages = [ pkgs.exfatprogs ];

  # Data partitions and mounts
  fileSystems."/mnt/nvme0n1p7" = {
    device = "/dev/disk/by-uuid/EBBE-BBC8";
    fsType = "exfat";
    options = [
      "nofail" # dont block boot if it fails to mount
      "x-systemd.device-timeout=5" # dont hang, give up after 5s
      "uid=1000" # owned by me not root
      "gid=100"
      "umask=0022"
    ];
  };

  fileSystems."/mnt/nvme0n1p3" = {
    device = "/dev/disk/by-uuid/E234F38734F35CCB";
    fsType = "ntfs";
    # no fsck for ntfs, linux doesnt have a real fsck.ntfs so the check unit just
    # fails every boot anyway
    options = [
      "nofail" # dont block boot if it fails to mount
      "x-systemd.device-timeout=5" # dont hang, give up after 5s
      "uid=1000" # owned by me not root
      "gid=100"
      "umask=0022"
    ];
  };

  # Shell shortcuts
  environment.shellAliases = {
    nix-hwgen = "doas nixos-generate-config --dir ~/nix-config";
    nix-rebuild = "doas nixos-rebuild switch --flake ~/nix-config#Axiom";
    nix-push = "cd ~/nix-config && git add . && git commit -m \"update $(date +%Y-%m-%d_%H:%M)\" && git push";
    nix-clean = "doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d";
    nix-generations = "nix-env -p /nix/var/nix/profiles/system --list-generations";
    sudo = "doas";
    sudo-temp = "/run/wrappers/bin/sudo";
    waydroid = "/usr/bin/python3 /usr/bin/waydroid";
    zsh-reload = "omz reload";
    enroll-tpm = "doas systemd-cryptenroll --wipe-slot=1 /dev/nvme0n1p6 && doas systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p6";
  };

  # Secure Boot and bootloader
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl"; # reusing my existing enrolled sbctl keys

    # auto generates secure boot keys in pkiBundle if they dont exist yet (runs as a
    # systemd service on boot, not during switch/install)
    autoGenerateKeys.enable = true;

    # auto enrolls the generated keys into firmware. keeping the microsoft keys so
    # option roms signed by ms still load
    autoEnrollKeys = {
      enable = true;
      includeMicrosoftKeys = true;
      autoReboot = true; # reboots once so enrollment finishes in the same session
    };
  };

  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Kernel, hibernation, and boot appearance
  boot.plymouth = {
    enable = true;
    theme = "mac-style";
    themePackages = [ pkgs.mac-style-plymouth ];
  };
  boot.initrd.systemd.enable = true;
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.resumeDevice = "/dev/disk/by-uuid/8f7d05ae-c0d8-49e0-8799-46e2ad9a514d";
  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
    "resume_offset=192512"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  powerManagement.enable = true;
  systemd.sleep.settings.Sleep = {
    HibernateMode = "shutdown";
  };

  boot.supportedFilesystems = [ "squashfs" ]; # Enable squashfs for Snap

  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # 16gb, covers my ~15.3gb of ram
    }
  ];

  # Compatibility paths for software that expects /bin/bash and /bin/sh
  # symlinks for /bin/bash and /bin/sh, some non nix apps and scripts hardcode them
  # instead of using PATH. /usr/bin/env is already there on nixos
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    "L+ /bin/sh - - - - ${pkgs.bash}/bin/sh"
  ];

  # Network identity and firewall
  networking.hostName = "Axiom";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 9295 ];
  networking.firewall.allowedUDPPorts = [
    987
    9295
    9296
    9297
    9302
    9303
  ];

  # Android compatibility
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
}
