{ config, pkgs, ... }:

{
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

  # Bootloader setup (systemd-boot + rEFInd + Secure Boot signing)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
    extraInstallCommands = ''
      echo "auto-entries no" >> /boot/loader/loader.conf
      echo "auto-firmware no" >> /boot/loader/loader.conf

      if ${pkgs.sbctl}/bin/sbctl status 2>/dev/null | grep -qi "Setup Mode:.*Disabled"; then
        for dir in \
          /boot/EFI/BOOT \
          /boot/EFI/fydeos \
          /boot/EFI/grub \
          /boot/EFI/Linux \
          /boot/EFI/nixos \
          /boot/EFI/refind \
          /boot/EFI/systemd \
          /boot/EFI/tools
        do
          if [ -d "$dir" ]; then
            while IFS= read -r file; do
              ${pkgs.sbctl}/bin/sbctl sign -s "$file" || true
            done < <(find "$dir" -type f \( -iname "*.efi" -o -iname "bzimage" -o -iname "initrd*" -o -iname "initramfs*" \) 2>/dev/null)
          fi
        done
        ${pkgs.sbctl}/bin/sbctl sign-all || true
      fi
    '';
  };

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
        scanfor internal,manual
        scan_delay 0
        dont_scan_volumes "9cc244c7-0ef4-463a-8876-9afc06b4f215","6ff20efd-cbe1-4459-8a0a-8e38c6d48a8e","35a298ab-dbdf-438e-a712-dfec34374038","29bc3b9e-3bcd-4a2d-9e66-0fad4a35a722","1839e475-1562-4a2d-9d50-53af13704d6f","16351340-528f-4f78-9bd3-165233108d2d","58cc772e-2015-42f9-b47b-e9c331654f93"
        include themes/catppuccin/macchiato.conf
        showtools shell, reboot, shutdown, firmware, about
      '';
    };

  # Auto re-sign specified binaries/kernels safely on change with explicit paths
  systemd.services.sign-all-efi = {
    description = "Sign specified ESP binaries and kernels explicitly for Secure Boot";
    serviceConfig.Type = "oneshot";
    script = ''
      if ${pkgs.sbctl}/bin/sbctl status 2>/dev/null | grep -qi "Setup Mode:.*Disabled"; then
        for dir in \
          /boot/EFI/BOOT \
          /boot/EFI/fydeos \
          /boot/EFI/grub \
          /boot/EFI/Linux \
          /boot/EFI/nixos \
          /boot/EFI/refind \
          /boot/EFI/systemd \
          /boot/EFI/tools
        do
          if [ -d "$dir" ]; then
            while IFS= read -r file; do
              ${pkgs.sbctl}/bin/sbctl sign -s "$file" || true
            done < <(find "$dir" -type f \( -iname "*.efi" -o -iname "bzimage" -o -iname "initrd*" -o -iname "initramfs*" \) 2>/dev/null)
          fi
        done
        ${pkgs.sbctl}/bin/sbctl sign-all || true
      fi
    '';
  };

  systemd.paths.sign-all-efi = {
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathModified = "/boot/EFI/refind/BOOTX64.EFI";
      Unit = "sign-all-efi.service";
    };
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

  # Networking & Firewall
  networking.hostName = "Axiom";
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 9295 ];
  networking.firewall.allowedUDPPorts = [ 987 9295 9296 9297 9302 ];

  # Waydroid
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;
}