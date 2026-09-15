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

  # Icon lookups for anything only reachable via hicolor fallback (not a
  # theme's own native icons) were taking ~5s to resolve on first use —
  # traced to no theme having a compiled icon-theme.cache at all, forcing
  # a full directory-tree scan per lookup. /nix/store paths are read-only
  # so a cache can't be written into the theme's own directory; instead,
  # merge each theme's system + per-user copies into ~/.local/share/icons
  # (which icon lookups check first, ahead of XDG_DATA_DIRS) and compile
  # a real cache there. Runs as a user activation script (not a systemd
  # service) so it re-runs on every activation, keeping the merged copy
  # fresh whenever theme packages update. Cosmic, Pop, and the
  # Bibata-Material-* cursor themes deliberately left alone — cursors
  # aren't icon themes, gtk-update-icon-cache doesn't apply to them.
  home.activation.iconThemeCacheUser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        SYS="/run/current-system/sw/share/icons"
        USR="/etc/profiles/per-user/${config.home.username}/share/icons"
        FLATPAK="${config.home.homeDirectory}/.local/share/flatpak/exports/share/icons"
        LOCAL="${config.home.homeDirectory}/.local/share/icons"

        $DRY_RUN_CMD mkdir -p "$LOCAL"

        rebuild_theme() {
          name="$1"
          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name" 2>/dev/null || true
          $DRY_RUN_CMD rm -rf "$LOCAL/$name"
          $DRY_RUN_CMD mkdir -p "$LOCAL/$name"
          [ -d "$SYS/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$SYS/$name/." "$LOCAL/$name/" 2>/dev/null
          [ -d "$USR/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$USR/$name/." "$LOCAL/$name/" 2>/dev/null
          [ -d "$FLATPAK/$name" ] && $DRY_RUN_CMD cp -rL --no-preserve=mode "$FLATPAK/$name/." "$LOCAL/$name/" 2>/dev/null
          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name"
          $DRY_RUN_CMD ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t "$LOCAL/$name" >/dev/null 2>&1 || true
          display="''${name%-Dark}"
          display="''${display%-Light}"
          echo "Indexed $display Theme"
        }

        for theme in Adwaita hicolor Papirus Papirus-Dark Papirus-Light; do
          rebuild_theme "$theme"
        done
  '';
}