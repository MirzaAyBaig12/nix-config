{ config, pkgs, lib, ... }:

{
  # Ensure the systemd user daemon is enabled in Home Manager
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

  # home-manager-ayaan_mirza.service is WantedBy=multi-user.target, so it
  # re-runs every boot, not just after a rebuild — meaning this used to
  # redo the full copy+cache for all 5 themes every single boot even when
  # nothing changed, slowing boot down for no reason. Fingerprint each
  # theme by its source /nix/store paths (which only change when a
  # package actually updates) and skip the whole rebuild for that theme
  # if the fingerprint matches what's already cached.
  home.activation.iconThemeCacheUser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        SYS="/run/current-system/sw/share/icons"
        USR="/etc/profiles/per-user/${config.home.username}/share/icons"
        FLATPAK="${config.home.homeDirectory}/.local/share/flatpak/exports/share/icons"
        LOCAL="${config.home.homeDirectory}/.local/share/icons"

        $DRY_RUN_CMD mkdir -p "$LOCAL"

        SEEN=""
        rebuild_theme() {
          name="$1"
          fingerprint="$(readlink -f "$SYS/$name" 2>/dev/null)|$(readlink -f "$USR/$name" 2>/dev/null)|$(readlink -f "$FLATPAK/$name" 2>/dev/null)"
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

        for theme in Adwaita hicolor Papirus Papirus-Dark Papirus-Light; do
          rebuild_theme "$theme"
        done
  '';
}