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

  # snap & flatpak (declarative, see flatpak.nix)
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
      # force dark mode + Papirus-Dark icons for every flatpak app.
      # ADW_DEBUG_COLOR_SCHEME covers libadwaita/gtk4 apps (skips the portal's
      # color-scheme setting entirely), GTK_THEME covers older gtk2/3 apps that dont
      # read the portal at all, and ICON_THEME covers apps that use the env var
      # directly instead of dconf
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

  # reinstalls rEFInd and re-signs it after every rebuild (chainloads lanzaboote's
  # signed UKIs + windows). activation scripts already run as root so no doas here,
  # doas caused emergency mode boot failures on gens 133/134 (PAM helper wasnt
  # reachable that early in boot). PATH is extended cuz activation scripts run with a
  # stripped PATH that doesnt include sed/coreutils, which refind-install needs
  # internally
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
      find /home/ayaan_mirza/.vscode -name "*.bak" -delete 2>/dev/null || true
      find /home/ayaan_mirza/.local/share/flatpak/overrides/ -name "*.bak" -delete 2>/dev/null || true
      find /home/ayaan_mirza/.config/vesktop/themes/ -name "*.css" -delete 2>/dev/null || true
    '';
    deps = [ ];
  };

  # system wide version of the per user icon cache in home-manager/services.hm.nix.
  # same problem (no theme ships a compiled icon-theme.cache so every lookup does a
  # full directory scan, ~5s on first use for anything only reachable through the
  # hicolor fallback) and same fix, just for the system profile instead of the per
  # user one
  # /nix/store is read only so the cache cant live in each theme's own store path.
  # /usr/share/icons is a real writable dir on nixos (unlike most of /usr) and its a
  # standard XDG icon search location that apps check even without XDG_DATA_DIRS
  # pointing at it explicitly. Cosmic, Pop, and the Bibata-Material-* cursor themes
  # are left alone on purpose, cursors arent icon themes and gtk-update-icon-cache
  # doesnt apply to them
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
      SEEN=""
      for theme in hicolor Papirus Papirus-Dark; do
        fingerprint="$(readlink -f "$SYS/$theme" 2>/dev/null || true)|$(readlink -f "$FLATPAK/$theme" 2>/dev/null || true)"
        stamp="$LOCAL/.stamp-$theme"
        if [ -d "$LOCAL/$theme" ] && [ -f "$stamp" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$fingerprint" ]; then
          continue
        fi
        rm -rf "$LOCAL/$theme"
        mkdir -p "$LOCAL/$theme"
        found=0
        [ -d "$SYS/$theme" ] && { cp -rL "$SYS/$theme/." "$LOCAL/$theme/" 2>/dev/null; found=1; }
        [ -d "$FLATPAK/$theme" ] && { cp -rL "$FLATPAK/$theme/." "$LOCAL/$theme/" 2>/dev/null; found=1; }
        if [ "$found" = "1" ]; then
          chmod -R u+w "$LOCAL/$theme"
          gtk-update-icon-cache -f -t "$LOCAL/$theme" >/dev/null 2>&1 || true
          echo "$fingerprint" > "$stamp"
          display="''${theme%-Dark}"
          display="''${display%-Light}"
          case " $SEEN " in
            *" $display "*) ;;
            *) echo "Indexed $display Theme"; SEEN="$SEEN $display" ;;
          esac
        else
          rmdir "$LOCAL/$theme" 2>/dev/null || true
        fi
      done
    '';
    deps = [ ];
  };

  # auto update flatpaks on every rebuild
  system.activationScripts.flatpakAutoUpdate = {
    text = ''
      ${pkgs.flatpak}/bin/flatpak update -y --noninteractive || true
    '';
    deps = [ ];
  };

  # forces COSMIC's own dark mode flag on every rebuild (stylix has no target for
  # COSMIC's native theme daemon so this is a manual pin)
  system.activationScripts.forceCosmicDark = {
    text = ''
      target=/home/ayaan_mirza/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark
      mkdir -p "$(dirname "$target")"
      tmp="$target.tmp.$$"
      echo -n "true" > "$tmp"
      chown ayaan_mirza:users "$tmp"
      mv -f "$tmp" "$target"   # atomic rename, fires MOVED_TO so cosmic-config's
                                # inotify watcher picks up the change live
    '';
    deps = [ ];
  };

  # keyd: tapping bare Super/Mod alone sends Alt+Space (DMS's own spotlight-bar bind,
  # see dms/binds.kdl) cuz niri cant natively bind a modifier only tap. holding
  # leftmeta still acts as a normal modifier for every other Mod+ bind in niri,
  # overload() handles that
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.leftmeta = "overload(meta, macro(M-S-space))";
    };

    # 2.4G Wireless Mouse (3938:1191). "*" above only matches keyboards, so the mouse
    # needs its own explicit id block. holding a side button = modifier layer, so
    # niri can bind modifier+wheel (see the binds{} block in .config/niri/config.kdl):
    #   hold Forward = Ctrl+Alt        -> scroll windows
    #   hold Back    = Ctrl+Shift+Alt  -> scroll workspaces
    # overloadt: a quick tap (<200ms) is still a normal back/forward click, holding
    # longer never fires the click, so scrolling doesn't randomly navigate a browser
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

  #Enable USBMUXD for iOS device management
  services.usbmuxd.enable = true;

  # cups printing, only using hplip drivers (the hp-* gui utilities are broken on
  # python3.14, see the hplip URLopener issue). the cups web ui at localhost:631
  # doesnt depend on those scripts and the drivers still work
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

  # watches for flatpaks installed outside of nix (like through bazaar) and appends
  # them to flatpak.nix, formatted correctly for flathub vs cosmic
  # the script itself is defined in flatpak.nix (options.custom.flatpakSyncScript)
  # systemd user service that runs the sync script
  systemd.user.services.flatpak-app-sync = {
    description = "Periodic sync for unmanaged Flatpaks into flatpak.nix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.custom.flatpakSyncScript}/bin/sync-flatpak-apps";
    };
  };

  # removed the timer, it was firing every 15s on its own. service is still here and
  # can be run manually whenever:
  #   systemctl --user start flatpak-app-sync.service

}
