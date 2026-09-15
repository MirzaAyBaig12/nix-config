{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

{
  # ~/.config/niri is a symlink into this repo (nix-config/.config/niri),
  # so `dms setup` can freely read/write config.kdl and dms/*.kdl as
  # normal files (not nix-store symlinks — HM's usual xdg.configFile is
  # read-only and breaks dms's in-place rewrites), while the content still
  # lives in git for backup/version history. Content itself is untracked
  # by Nix on purpose; edit ~/nix-config/.config/niri/ directly or re-run
  # `dms setup` and commit the result.
  home.file.".config/niri".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/.config/niri";

  # dms/colors.kdl keeps getting regenerated back to light mode (DMS
  # re-derives it from the system light/dark preference on its own,
  # independent of Nix). Force it back to dark on every activation.
  home.activation.dmsColorsDark = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD sed -i \
      -e 's/5f5791/c8bfff/g' \
      -e 's/79767f/938f99/g' \
      -e 's/ba1a1a/ffb4ab/g' \
      "${config.home.homeDirectory}/nix-config/.config/niri/dms/colors.kdl"
  '';

  # dms.service's own systemd unit file gets symlinked into
  # ~/.config/systemd/user/dms.service ONCE, imperatively, and never
  # re-linked on later switches — so a DMS version bump silently leaves
  # the OLD build running until this gets manually re-pointed. Do that
  # here on every activation instead: always re-link to whatever package
  # `programs.dank-material-shell` currently resolves to, and only
  # daemon-reload + restart the service if the target actually changed
  # (skip the restart on every no-op switch).
  #
  # QS_ICON_THEME env var — v1.6.1 switched from writing desktop theme
  # settings via gsettings to writing directly via dconf (changelog:
  # "theme: write desktop settings through dconf instead of gsettings"),
  # which broke DMS's own icon-theme resolution (confirmed real
  # regression, v1.6.0 works / v1.6.1 doesn't, with git staging ruled out
  # as a red herring). QS_ICON_THEME is DMS's own documented override
  # (danklinux.com/docs/dankmaterialshell/icon-theming) that takes
  # precedence over whatever the broken probe does, sidestepping it
  # entirely — lets us track "stable" HEAD again instead of pinning an
  # old commit. Confirmed working Sep 13 2026 (no ExecStartPre delay
  # needed once this was in place — that was working around the dconf
  # probe specifically, which QS_ICON_THEME bypasses altogether).
  home.activation.dmsServiceRelink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        DMS_UNIT="${osConfig.programs.dms-shell.package}/share/systemd/user/dms.service"
        LINK="${config.home.homeDirectory}/.config/systemd/user/dms.service"
        OLD_TARGET="$(readlink -f "$LINK" 2>/dev/null || true)"

        $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user"
        $DRY_RUN_CMD ln -sfn "$DMS_UNIT" "$LINK"

        $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user/dms.service.d"
        $DRY_RUN_CMD cat > "${config.home.homeDirectory}/.config/systemd/user/dms.service.d/icon-theme-race-fix.conf" << EOF
    [Service]
    Environment=QT_QPA_PLATFORMTHEME=gtk3
    Environment=QS_ICON_THEME=Papirus-Dark
    Environment=XDG_DATA_DIRS=/nix/store/smn5bv5gqz8sfyg6c2rga82g8s6bd1m5-ghostty-1.3.1/share:/nix/store/jkmzkh3rjak10ccsrkgwybxngqqswgm4-gsettings-desktop-schemas-50.1/share/gsettings-schemas/gsettings-desktop-schemas-50.1:/nix/store/6d3v90p73c3qx6axdlqnm5xfd4w93w20-gtk4-4.22.4/share/gsettings-schemas/gtk4-4.22.4:/nix/store/gvgrz4bh8hryjzrvkqjiwyh4acpn27aj-quickshell-0.3.1/share:/run/current-system/sw/share:/nix/store/id7wgv26ga466m5n2cmn2hv3g5y45861-desktops/share:/home/ayaan_mirza/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/ayaan_mirza/.nix-profile/share:/nix/profile/share:/home/ayaan_mirza/.local/state/nix/profile/share:/etc/profiles/per-user/ayaan_mirza/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share
    EOF

        if [ "$OLD_TARGET" != "$(readlink -f "$LINK" 2>/dev/null || true)" ]; then
          $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user daemon-reload || true
          $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user try-restart dms.service || true
        fi
  '';

}
