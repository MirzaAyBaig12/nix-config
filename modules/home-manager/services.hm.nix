{
  config,
  pkgs,
  lib,
  ...
}:

{
  # -------------------------------------------------------------------------
  # User session services
  # -------------------------------------------------------------------------

  systemd.user.services = {
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

  # -------------------------------------------------------------------------
  # Home Manager activation
  # -------------------------------------------------------------------------
  #
  # These scripts are user-level tasks.
  #
  # Home Manager boot activation is skipped using INVOCATION_ID.
  #
  # Manual rebuild:
  #   TTY       -> normal user activations run
  #   Graphical -> normal user activations run
  #
  # The icon cache has one additional gate:
  #   graphical-session.target must be active.
  # -------------------------------------------------------------------------

  # Remove old backup files after every manual rebuild.
  home.activation.removeOldBaks =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${INVOCATION_ID:-}" ]; then
        echo "Systemd boot activation detected, skipping backup cleanup"
      else
        find "$HOME/.config" \
          -name "*.bak" \
          -delete \
          2>/dev/null \
          || true

        find "$HOME/.vscode" \
          -name "*.bak" \
          -delete \
          2>/dev/null \
          || true

        find "$HOME/.local/share/flatpak/overrides/" \
          -name "*.bak" \
          -delete \
          2>/dev/null \
          || true

        find "$HOME/.config/vesktop/themes/" \
          -name "*.css" \
          -delete \
          2>/dev/null \
          || true
      fi
    '';

  # Force COSMIC's own dark mode flag after every manual rebuild.
  home.activation.forceCosmicDark =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${INVOCATION_ID:-}" ]; then
        echo "Systemd boot activation detected, skipping COSMIC dark mode"
      else
        target="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

        mkdir -p "$(dirname "$target")"

        tmp="$target.tmp.$$"

        echo -n "true" > "$tmp"

        mv -f "$tmp" "$target"

        # Atomic rename fires MOVED_TO so cosmic-config's inotify watcher
        # picks up the change live.
      fi
    '';

  # Update Flatpaks after every manual rebuild.
  #
  # Runs as the user rather than root.
  # Intentionally not a service or timer.
  home.activation.flatpakAutoUpdate =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "''${INVOCATION_ID:-}" ]; then
        echo "Systemd boot activation detected, skipping Flatpak update"
      else
        ${pkgs.flatpak}/bin/flatpak update -y --noninteractive || true
      fi
    '';

  # -------------------------------------------------------------------------
  # Icon theme cache activation
  # -------------------------------------------------------------------------
  #
  # There are THREE gates:
  #
  # 1. Boot activation
  #      INVOCATION_ID is present -> skip.
  #
  # 2. Graphical session
  #      graphical-session.target is inactive -> skip.
  #
  # 3. Content fingerprint
  #      Cache is current -> skip.
  #
  # Therefore:
  #
  #   Boot activation       -> SKIP
  #   TTY nixos-rebuild     -> SKIP
  #   Graphical nixos-rebuild
  #       unchanged cache  -> SKIP
  #       changed cache    -> REBUILD
  # -------------------------------------------------------------------------

  home.activation.iconThemeCacheUser =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # ----------------------------------------------------------------------
      # BOOT ACTIVATION GUARD
      # ----------------------------------------------------------------------

      if [ -n "''${INVOCATION_ID:-}" ]; then
        echo "Systemd boot activation detected, skipping icon theme indexing"

      # ----------------------------------------------------------------------
      # GRAPHICAL SESSION GUARD
      # ----------------------------------------------------------------------

      elif ! ${pkgs.systemd}/bin/systemctl --user is-active \
        --quiet graphical-session.target; then

        echo "No graphical session detected, skipping icon theme indexing"

      else

        SYS="/run/current-system/sw/share/icons"
        USR="/etc/profiles/per-user/${config.home.username}/share/icons"
        FLATPAK="$HOME/.local/share/flatpak/exports/share/icons"
        LOCAL="$HOME/.local/share/icons"

        # --------------------------------------------------------------------
        # Calculate a content fingerprint for one theme across all providers.
        # --------------------------------------------------------------------

        theme_fingerprint() {
          name="$1"

          for dir in "$SYS/$name" "$USR/$name" "$FLATPAK/$name"; do
            [ -e "$dir" ] || continue

            echo "== $dir"

            if [ -L "$dir" ]; then
              echo "root $(readlink -f "$dir")"
            else
              ${pkgs.findutils}/bin/find \
                -H \
                "$dir" \
                -printf '%P -> %l\n' \
                2>/dev/null \
                | LC_ALL=C ${pkgs.coreutils}/bin/sort \
                || true
            fi
          done \
            | ${pkgs.coreutils}/bin/sha256sum \
            | ${pkgs.coreutils}/bin/cut -d' ' -f1
        }

        SEEN=""

        # --------------------------------------------------------------------
        # Rebuild one theme if its fingerprint changed.
        # --------------------------------------------------------------------

        rebuild_theme() {
          name="$1"

          stamp="$LOCAL/.stamp-$name"

          fingerprint="$(theme_fingerprint "$name" || true)"

          if [ -d "$LOCAL/$name" ] \
            && [ -f "$stamp" ] \
            && [ "$(cat "$stamp" 2>/dev/null)" = "$fingerprint" ]; then
            echo "$name cache is already up to date"
            return
          fi

          echo "$name changed, rebuilding icon cache"

          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name" 2>/dev/null || true

          $DRY_RUN_CMD rm -rf "$LOCAL/$name"

          $DRY_RUN_CMD mkdir -p "$LOCAL/$name"

          # System icon theme
          if [ -d "$SYS/$name" ]; then
            $DRY_RUN_CMD cp \
              -rL \
              --no-preserve=mode \
              "$SYS/$name/." \
              "$LOCAL/$name/" \
              2>/dev/null \
              || true
          fi

          # Per-user icon theme
          if [ -d "$USR/$name" ]; then
            $DRY_RUN_CMD cp \
              -rL \
              --no-preserve=mode \
              "$USR/$name/." \
              "$LOCAL/$name/" \
              2>/dev/null \
              || true
          fi

          # Flatpak icon theme
          if [ -d "$FLATPAK/$name" ]; then
            $DRY_RUN_CMD cp \
              -rL \
              --no-preserve=mode \
              "$FLATPAK/$name/." \
              "$LOCAL/$name/" \
              2>/dev/null \
              || true
          fi

          $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name"

          # Compile the cache.
          $DRY_RUN_CMD \
            ${pkgs.gtk3}/bin/gtk-update-icon-cache \
            -f \
            -t \
            "$LOCAL/$name" \
            >/dev/null 2>&1 \
            || true

          # Save fingerprint only after rebuilding.
          $DRY_RUN_CMD \
            sh -c "echo '$fingerprint' > '$stamp'"

          display="''${name%-Dark}"
          display="''${display%-Light}"

          case " $SEEN " in
            *" $display "*)
              ;;
            *)
              echo "Indexed $display Theme"
              SEEN="$SEEN $display"
              ;;
          esac
        }

        # --------------------------------------------------------------------
        # FAST PATH
        # --------------------------------------------------------------------

        NEEDS_REBUILD=0

        for theme in hicolor Papirus Papirus-Dark; do
          fingerprint="$(theme_fingerprint "$theme" || true)"
          stamp="$LOCAL/.stamp-$theme"

          if [ ! -d "$LOCAL/$theme" ] \
            || [ ! -f "$stamp" ] \
            || [ "$(cat "$stamp" 2>/dev/null)" != "$fingerprint" ]; then
            NEEDS_REBUILD=1
            break
          fi
        done

        if [ "$NEEDS_REBUILD" = "0" ]; then
          echo "Icon theme caches are already up to date"
        else
          $DRY_RUN_CMD mkdir -p "$LOCAL"

          for theme in hicolor Papirus Papirus-Dark; do
            rebuild_theme "$theme"
          done
        fi

      fi
    '';

  # -------------------------------------------------------------------------
  # Editor configuration
  # -------------------------------------------------------------------------

  home.file.".vscode/argv.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix-config/.config/.vscode/argv.json";
}