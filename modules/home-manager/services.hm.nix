{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
  # make sure the systemd user daemon is enabled in home manager
  systemd.user.services = {
    polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        WantedBy = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    fcc-server = {
      Unit = {
        Description = "FCC Server Background Daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "%h/.local/bin/fcc-server";
        Restart = "always";
        RestartSec = 5;
      };
    };
  };

  # icon lookups for anything only reachable through the hicolor fallback (not a
  # theme's own native icons) were taking ~5s on first use. traced it to no theme
  # having a compiled icon-theme.cache at all, which forces a full directory tree scan
  # on every lookup. /nix/store is read only so i cant write a cache into the theme's
  # own dir. instead i merge each theme's system + per user copies into
  # ~/.local/share/icons (icon lookups check that first, before XDG_DATA_DIRS) and
  # compile a real cache there
  # runs as a user activation script (not a systemd service) so it reruns on every
  # activation and the merged copy stays fresh whenever theme packages update. Cosmic,
  # Pop, and the Bibata-Material-* cursor themes are left alone on purpose, cursors
  # arent icon themes and gtk-update-icon-cache doesnt apply to them
  home.activation.iconThemeCacheUser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        SYS="/run/current-system/sw/share/icons"
        USR="/etc/profiles/per-user/${config.home.username}/share/icons"
        FLATPAK="${config.home.homeDirectory}/.local/share/flatpak/exports/share/icons"
        LOCAL="${config.home.homeDirectory}/.local/share/icons"

        $DRY_RUN_CMD mkdir -p "$LOCAL"

        SEEN=""
        rebuild_theme() {
          name="$1"
          fingerprint="$(readlink -f "$SYS/$name" 2>/dev/null || true)|$(readlink -f "$USR/$name" 2>/dev/null || true)|$(readlink -f "$FLATPAK/$name" 2>/dev/null || true)"
          stamp="$LOCAL/.stamp-$name"
          if [ -d "$LOCAL/$name" ] && [ -f "$stamp" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$fingerprint" ]; then
            return
          fi
          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name" 2>/dev/null || true
          $DRY_RUN_CMD rm -rf "$LOCAL/$name"
          $DRY_RUN_CMD mkdir -p "$LOCAL/$name"
          [ -d "$SYS/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$SYS/$name/." "$LOCAL/$name/" 2>/dev/null
          [ -d "$USR/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$USR/$name/." "$LOCAL/$name/" 2>/dev/null
          [ -d "$FLATPAK/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$FLATPAK/$name/." "$LOCAL/$name/" 2>/dev/null
          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name"
          $DRY_RUN_CMD ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "$LOCAL/$name" >/dev/null 2>&1 || true
          $DRY_RUN_CMD sh -c "echo '$fingerprint' > '$stamp'"
          display="''${name%-Dark}"
          display="''${display%-Light}"
          case " $SEEN " in
            *" $display "*) ;;
            *) echo "Indexed $display Theme"; SEEN="$SEEN $display" ;;
          esac
        }

        # home manager activation (unlike a plain systemd service) fires again on
        # every boot, not just on a real switch/rebuild. nixos reruns the whole
        # activation script at boot to keep runtime state in sync with the booted
        # generation. theres no clean signal from inside the script for "this run came
        # from switch" vs "this run came from boot" so i fake one:
        # /proc/sys/kernel/random/boot_id is a fresh UUID every kernel boot. the FIRST
        # activation seen for a given boot_id is assumed to be the automatic boot time
        # run and gets skipped, only a later activation in the same boot (aka i
        # actually ran home-manager/nixos-rebuild switch again) does the real work
        # caveat: if switch is genuinely the very first thing i run after a reboot it
        # skips that one too. just run switch again and it goes through
        BOOT_ID="$(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo unknown)"
        BOOT_STAMP="$LOCAL/.last-boot-id"
        if [ "$(cat "$BOOT_STAMP" 2>/dev/null)" = "$BOOT_ID" ]; then
          for theme in hicolor Papirus Papirus-Dark; do
            rebuild_theme "$theme"
          done
        fi
        $DRY_RUN_CMD sh -c "echo '$BOOT_ID' > '$BOOT_STAMP'"
  '';
}