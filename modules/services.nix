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
  # Flatpak
  # -------------------------------------------------------------------------

  # Declarative Flatpak setup; package declarations live in flatpak.nix.
  services.flatpak.enable = true;

  services.flatpak.overrides = {
    global = {
      Context.filesystems = [
        "xdg-data/themes:ro"
        "xdg-data/icons:ro"
        "xdg-config/gtk-3.0:ro"
        "xdg-config/gtk-4.0:ro"
      ];

      # Force dark mode + Papirus-Dark icons for every Flatpak app.
      Environment = {
        ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
        GTK_THEME = "Catppuccin-Mauve-Dark";
        ICON_THEME = "Papirus-Dark";
      };
    };

    "com.kolumni.bazaar" = {
      Context.filesystems = [
        "xdg-config/gtk-3.0:ro"
        "xdg-config/gtk-4.0:ro"
      ];
    };
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

  # -------------------------------------------------------------------------
  # Boot-time / system activation
  # -------------------------------------------------------------------------
  #
  # Only scripts that genuinely need to participate in boot remain here.
  #
  # User-specific tasks are handled by Home Manager.
  # Lanzaboote handles EFI bootloader signing.
  #
  # The p3/p7 mount scripts should remain here.
  #
  # Keep your existing p3/p7 activation scripts below this point.
  # -------------------------------------------------------------------------

  # -------------------------------------------------------------------------
  # Input devices
  # -------------------------------------------------------------------------

  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      settings.main.leftmeta =
        "overload(meta, macro(M-S-space))";
    };

    # 2.4G Wireless Mouse (3938:1191).
    #
    # Holding Forward = Ctrl+Alt
    # Holding Back    = Ctrl+Shift+Alt
    #
    # Quick taps remain normal browser back/forward buttons.
    keyboards.mouse = {
      ids = [ "3938:1191" ];

      settings = {
        main = {
          mouseforward = "overloadt(fwdmod, mouseforward, 200)";
          mouseback = "overloadt(backmod, mouseback, 200)";
        };

        "fwdmod:C-A" = { };
        "backmod:C-S-A" = { };
      };
    };
  };

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

  # -------------------------------------------------------------------------
  # Flatpak sync service
  # -------------------------------------------------------------------------
  #
  # Watches for Flatpaks installed outside Nix and appends them to
  # flatpak.nix.
  #
  # Run manually with:
  #
  #   systemctl --user start flatpak-app-sync.service
  #
  systemd.user.services.flatpak-app-sync = {
    description = "Periodic sync for unmanaged Flatpaks into flatpak.nix";

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.custom.flatpakSyncScript}/bin/sync-flatpak-apps";
    };
  };

  # No timer. The service is intentionally manual.
}