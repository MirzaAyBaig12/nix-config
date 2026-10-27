{
  config,
  pkgs,
  lib,
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

  security.doas.enable = true;

  security.doas.extraRules = [
    {
      users = [ "ayaan_mirza" ];
      keepEnv = true;
      persist = true;
    }
  ];

  security.sudo.enable = true;

  security.apparmor.enable = true;

  services.udisks2.enable = true; # Automatially mount drives when they are plugged in

  # -------------------------------------------------------------------------
  # Input devices
  # -------------------------------------------------------------------------

  hardware.uinput.enable = true;

  # Enable USBMUXD for iOS device management.
  services.usbmuxd.enable = true;

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