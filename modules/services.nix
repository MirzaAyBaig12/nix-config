{
  config,
  pkgs,
  lib,
  ...
}:

{

  # User Account
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

  # Snap & Flatpak (declarative — see flatpak.nix)
  services.snap.enable = false;
  services.flatpak.enable = true;
  services.flatpak.overrides = {
    global = {
      Context.filesystems = [
        "xdg-data/themes:ro"
        "xdg-data/icons:ro"
        "xdg-config/gtk-3.0:ro"
        "xdg-config/gtk-4.0:ro"
      ];
      # Force dark mode + Papirus-Dark icons for every Flatpak app:
      # ADW_DEBUG_COLOR_SCHEME covers libadwaita/GTK4 apps (bypasses the
      # portal's color-scheme setting entirely), GTK_THEME covers older
      # GTK2/3 apps that don't read the portal at all, and ICON_THEME
      # covers apps that respect the env var directly instead of dconf.
      Environment = {
        ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
        GTK_THEME = "Adwaita:dark";
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

  # Security & Privileges (Doas & Sudo)
  security.doas.enable = true;
  security.doas.extraRules = [
    {
      users = [ "ayaan_mirza" ];
      keepEnv = true;
      persist = true;
    }
  ];

  security.sudo.enable = true;

  security.apparmor.enable = true; # Enable AppArmor for Snap confinement

  # Re-install rEFInd and re-sign it after every rebuild (chainloads
  # Lanzaboote's signed UKIs + Windows). Activation scripts already run
  # as root, so no doas here — doas caused emergency-mode boot failures
  # on gens 133/134 (PAM helper wasn't reachable this early in boot).
  # PATH is extended because activation scripts run with a stripped PATH
  # that doesn't include sed/coreutils, which refind-install needs internally.
  system.activationScripts.refind-sign = {
    text = ''
      export PATH="${
        lib.makeBinPath [
          pkgs.gnused
          pkgs.gawk
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.util-linux
        ]
      }:$PATH"
      ${pkgs.refind}/bin/refind-install --yes
      ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/refind/refind_x64.efi
    '';
    deps = [ ];
  };

  system.activationScripts.systemd-boot-sign = {
    text = ''
      export PATH="${
        lib.makeBinPath [
          pkgs.gnused
          pkgs.gawk
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.util-linux
        ]
      }:$PATH"
      ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/systemd/systemd-bootx64.efi
    '';
    deps = [ ];
  };

  system.activationScripts.removeOldBaks = {
    text = ''
      find /home/ayaan_mirza/.config -name "*.bak" -delete 2>/dev/null || true
    '';
    deps = [ ];
  };

  # System-wide counterpart to the per-user icon cache in
  # home-manager/services.hm.nix — same problem (no theme ships a
  # compiled icon-theme.cache, forcing a full directory scan per lookup,
  # ~5s on first use for anything only reachable via hicolor fallback),
  # fixed the same way but for the system profile instead of the
  # per-user one. /nix/store is read-only so the cache can't live inside
  # each theme's own store path; /usr/share/icons is a real writable
  # directory on NixOS (unlike most of /usr) and is a standard XDG icon
  # search location apps check even without XDG_DATA_DIRS pointing at it
  # explicitly. Cosmic, Pop, and the Bibata-Material-* cursor themes
  # deliberately left alone — cursors aren't icon themes,
  # gtk-update-icon-cache doesn't apply to them.
  system.activationScripts.iconThemeCacheSystem = {
    text = ''
      export PATH="${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.gtk3
        ]
      }:$PATH"
      SYS="/run/current-system/sw/share/icons"
      FLATPAK="/var/lib/flatpak/exports/share/icons"
      LOCAL="/usr/share/icons"
      mkdir -p "$LOCAL"
      for theme in Adwaita hicolor Papirus Papirus-Dark Papirus-Light; do
        rm -rf "$LOCAL/$theme"
        mkdir -p "$LOCAL/$theme"
        found=0
        [ -d "$SYS/$theme" ] && { cp -rL "$SYS/$theme/." "$LOCAL/$theme/" 2>/dev/null; found=1; }
        [ -d "$FLATPAK/$theme" ] && { cp -rL "$FLATPAK/$theme/." "$LOCAL/$theme/" 2>/dev/null; found=1; }
        if [ "$found" = "1" ]; then
          chmod -R u+w "$LOCAL/$theme"
          gtk-update-icon-cache -f -t "$LOCAL/$theme" >/dev/null 2>&1 || true
          display="''${theme%-Dark}"
          display="''${display%-Light}"
          echo "Indexed $display Theme"
        else
          rmdir "$LOCAL/$theme" 2>/dev/null || true
        fi
      done
    '';
    deps = [ ];
  };

  # Forces COSMIC's own dark-mode flag on every rebuild (stylix has no
  # target for COSMIC's native theme daemon, so this is a manual pin).
  system.activationScripts.forceCosmicDark = {
    text = ''
      target=/home/ayaan_mirza/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark
      mkdir -p "$(dirname "$target")"
      tmp="$target.tmp.$$"
      echo -n "true" > "$tmp"
      chown ayaan_mirza:users "$tmp"
      mv -f "$tmp" "$target"   # atomic rename -> fires MOVED_TO so cosmic-config's
                                # inotify watcher actually picks up the change live
    '';
    deps = [ ];
  };

  # keyd: tapping bare Super/Mod alone sends Alt+Space (DMS's own
  # spotlight-bar bind, see dms/binds.kdl) since niri can't natively bind
  # a modifier-alone tap. Holding leftmeta still behaves as a normal
  # modifier for every other Mod+ bind in niri — overload() handles that.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.leftmeta = "overload(meta, macro(M-S-space))";
    };
  };

  hardware.uinput.enable = true;

  #Enable USBMUXD for iOS device management
  services.usbmuxd.enable = true;

  # CUPS printing — using hplip drivers only (hp-* GUI utilities are
  # broken on python3.14, see hplip URLopener issue; CUPS web UI at
  # localhost:631 doesn't depend on those scripts, drivers still work)
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enables scanning support (also uses hplip's sane backend)
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Printer/scanner discovery on the local network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Watches for Flatpaks installed outside of Nix (e.g. via Bazaar) and
  # appends them into flatpak.nix, correctly formatted for flathub vs cosmic.
  # Script itself is defined in flatpak.nix (options.custom.flatpakSyncScript).
  # Systemd user service to execute the sync script
  systemd.user.services.flatpak-app-sync = {
    description = "Periodic sync for unmanaged Flatpaks into flatpak.nix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.custom.flatpakSyncScript}/bin/sync-flatpak-apps";
    };
  };

  # Timer removed — was firing every 15s automatically. Service is still
  # here and can be run manually whenever needed:
  #   systemctl --user start flatpak-app-sync.service

}
