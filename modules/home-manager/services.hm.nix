{ 
  config, 
  pkgs, 
  lib, 
  ... 
}:

{
  # User session services
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

  # Icon theme cache activation
  # icon lookups for anything only reachable through the hicolor fallback (not a
  # theme's own native icons) were taking ~5s on first use. traced it to no theme
  # having a compiled icon-theme.cache at all, which forces a full directory tree scan
  # on every lookup. /nix/store is read only so i cant write a cache into the theme's
  # own dir. instead i merge each theme's system + per user + flatpak copies into
  # ~/.local/share/icons (icon lookups check that first, before XDG_DATA_DIRS) and
  # compile a real cache there
  # only hicolor, Papirus and Papirus-Dark get indexed. Cosmic, Pop, and the
  # Bibata-Material-* cursor themes are left alone on purpose, cursors arent icon
  # themes and gtk-update-icon-cache doesnt apply to them
  #
  # two gates keep this cheap:
  # 1. graphical session only. home manager activation also fires on every boot
  # (nixos reruns the whole activation to sync runtime state) long before anyone is
  # logged in, so the first thing it does is ask the user systemd manager if
  # graphical-session.target is active. no session (boot, tty only) = skip and touch
  # nothing. only a real switch from inside niri/cosmic does any work
  # 2. only when something actually changed. each theme gets a fingerprint of what is
  # in it right now (symlink target of every file across the system/user/flatpak
  # copies) so a new app dropping an icon into hicolor, a theme package update or a
  # new flatpak all change it. same fingerprint as the stamp from the last index = skip
  home.activation.iconThemeCacheUser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SYS="/run/current-system/sw/share/icons"
    USR="/etc/profiles/per-user/${config.home.username}/share/icons"
    FLATPAK="${config.home.homeDirectory}/.local/share/flatpak/exports/share/icons"
    LOCAL="${config.home.homeDirectory}/.local/share/icons"

    # content fingerprint of one theme across system/user/flatpak. the profile dirs
    # (hicolor especially) are real dirs full of per file symlinks into the store, so
    # listing the symlink targets is what actually changes when an app is added or
    # updated. readlink on the dir alone would stay the same forever
    theme_fingerprint() {
      name="$1"
      for dir in "$SYS/$name" "$USR/$name" "$FLATPAK/$name"; do
        [ -e "$dir" ] || continue
        echo "== $dir"
        # a theme dir that is itself one symlink (single provider, e.g. Papirus) points
        # into an immutable store path so the path alone identifies its content, no
        # need to crawl 88k files. real dirs get the symlink target listing instead
        if [ -L "$dir" ]; then
          echo "root $(readlink -f "$dir")"
        else
          ${pkgs.findutils}/bin/find -H "$dir" -printf '%P -> %l\n' 2>/dev/null | LC_ALL=C ${pkgs.coreutils}/bin/sort || true
        fi
      done | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1
    }

    SEEN=""
    rebuild_theme() {
      name="$1"
      fingerprint="$(theme_fingerprint "$name" || true)"
      stamp="$LOCAL/.stamp-$name"
      if [ -d "$LOCAL/$name" ] && [ -f "$stamp" ] && [ "$(cat "$stamp" 2>/dev/null)" = "$fingerprint" ]; then
        return
      fi
      $DRY_RUN_CMD chmod -R u+w "$LOCAL/$name" 2>/dev/null || true
      $DRY_RUN_CMD rm -rf "$LOCAL/$name"
      $DRY_RUN_CMD mkdir -p "$LOCAL/$name"
      [ -d "$SYS/$name" ] && { $DRY_RUN_CMD cp -rL --no-preserve=mode "$SYS/$name/." "$LOCAL/$name/" 2>/dev/null || true; }
      [ -d "$USR/$name" ] && { $DRY_RUN_CMD cp -rL --no-preserve=mode "$USR/$name/." "$LOCAL/$name/" 2>/dev/null || true; }
      [ -d "$FLATPAK/$name" ] && { $DRY_RUN_CMD cp -rL --no-preserve=mode "$FLATPAK/$name/." "$LOCAL/$name/" 2>/dev/null || true; }
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

    # gate 1: bail unless a graphical session is up. systemctl --user needs
    # XDG_RUNTIME_DIR here because the system level hm service doesnt set it, and at
    # boot /run/user/<uid> doesnt exist yet so this just fails = skip
    if XDG_RUNTIME_DIR="/run/user/$(${pkgs.coreutils}/bin/id -u)" ${pkgs.systemd}/bin/systemctl --user is-active --quiet graphical-session.target 2>/dev/null; then
      $DRY_RUN_CMD mkdir -p "$LOCAL"
      # gate 2 lives inside rebuild_theme (fingerprint vs stamp)
      for theme in hicolor Papirus Papirus-Dark; do
        rebuild_theme "$theme"
      done
    else
      echo "No graphical session, skipping icon theme indexing"
    fi

    # leftover from the old boot_id skip hack, not used anymore
    $DRY_RUN_CMD rm -f "$LOCAL/.last-boot-id"
  '';
  
  # Editor configuration link
  home.file.".vscode/argv.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/.config/.vscode/argv.json";
}