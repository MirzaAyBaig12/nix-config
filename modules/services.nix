{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # -------------------------------------------------------------------------
  # Accounts and security
  # -------------------------------------------------------------------------

  users.users."ayaan_mirza" = {
    isNormalUser = true;
    description = "Ayaan Mirza";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    shell = pkgs.zsh;

    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];

    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  # -------------------------------------------------------------------------
  # Security & privileges
  # -------------------------------------------------------------------------

  # sudo-rs (Rust sudo) is the default privilege escalation tool
  security.sudo-rs.enable = true;
  # no asterisks while typing the password. pwfeedback makes sudo-rs switch the tty out
  # of canonical mode to read keys one at a time, which breaks Ghostty's password prompt
  # detection (it wants ICANON on + ECHO off) so the lock cursor never shows up
  security.sudo-rs.extraConfig = ''
    Defaults !pwfeedback
  '';

  security.apparmor.enable = true;

  services.udisks2.enable = true; # Automatially mount drives when they are plugged in

  # -------------------------------------------------------------------------
  # Input devices
  # -------------------------------------------------------------------------

  hardware.uinput.enable = true;

  # Enable USBMUXD for iOS device management.
  services.usbmuxd.enable = true;

  # 3uTools udev rules (Apple USB device access), shipped by the package.
  services.udev.packages = [
    inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}."3utools"
  ];

  # -------------------------------------------------------------------------
  # Printing and scanning
  # -------------------------------------------------------------------------

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Printer/scanner discovery on the local network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}