{ config, lib, pkgs, ... }:

{
  # Explicit env vars for nh (belt-and-suspenders alongside programs.nh.flake,
  # since NH_FLAKE via the module option has been flaky to propagate to
  # already-open shells after a rebuild)
  environment.variables = {
    NH_FLAKE = "/home/ayaan_mirza/nix-config";
    NH_OS_FLAKE = "/home/ayaan_mirza/nix-config";
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
    flatpak = "flatpak && sync-flatpak-apps";
  };

  # Bootloader setup (systemd-boot + rEFInd + Secure Boot signing)
  boot.loader.grub = {
    enable = false;
    device = "nodev";
    useOSProber = true;
    theme = ../.config/themes/nixos;
    gfxmodeEfi = "auto";
    gfxpayloadEfi = "keep";
  };
  # Lanzaboote replaces systemd-boot's own bootloader install step, but the
  # systemd-boot options below (configurationLimit, timeout) still apply —
  # lanzaboote uses them, it just signs everything automatically on top.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl"; # reuses your existing enrolled sbctl keys
  };

  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.refind =
    let
      catppuccinSrc = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "refind";
        rev = "main";
        sha256 = "sha256-34+MkvWEp3xq6Di1uWKR4ieaG4t2rufnRRN1/V0WRfw=";
      };
      macchiatoFiles =
        [
          "macchiato.conf"
          "assets/macchiato/background.png"
          "assets/macchiato/selection_big.png"
          "assets/macchiato/selection_small.png"
        ]
        ++ (map (n: "assets/macchiato/icons/${n}") (
          builtins.attrNames (builtins.readDir "${catppuccinSrc}/assets/macchiato/icons")
        ));
    in
    {
      enable = false;
      maxGenerations = 3;
      additionalFiles = builtins.listToAttrs (
        map (f: {
          name = "themes/catppuccin/${f}";
          value = "${catppuccinSrc}/${f}";
        }) macchiatoFiles
      );
      extraConfig = ''
        use_nvram false
        use_graphics_for osx,linux
        scanfor manual
        scan_delay 0
        dont_scan_volumes "9cc244c7-0ef4-463a-8876-9afc06b4f215","6ff20efd-cbe1-4459-8a0a-8e38c6d48a8e","35a298ab-dbdf-438e-a712-dfec34374038","29bc3b9e-3bcd-4a2d-9e66-0fad4a35a722","1839e475-1562-4a2d-9d50-53af13704d6f","16351340-528f-4f78-9bd3-165233108d2d","58cc772e-2015-42f9-b47b-e9c331654f93"
        include themes/catppuccin/macchiato.conf
        showtools shell, reboot, shutdown, firmware, about

        menuentry "NixOS (systemd-boot)" {
          loader /EFI/systemd/systemd-bootx64.efi
        }
      '';
    };

  # (Manual sbctl signing service removed — lanzaboote handles signing
  # automatically on every generation now, no separate service needed.)

  # Re-install rEFInd and re-sign it for secure boot after every rebuild
  system.activationScripts.refind-sign = {
    text = ''
      ${pkgs.doas}/bin/doas ${pkgs.refind}/bin/refind-install
      ${pkgs.doas}/bin/doas ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/refind/wtvvr
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