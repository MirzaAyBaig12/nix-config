{ config, lib, osConfig, pkgs, ... }:

{
  imports = [
    ./niri/base.nix
    ./niri/input.nix
    ./niri/layout.nix
    ./niri/outputs.nix
    ./niri/rules.nix
    ./niri/bindings.nix
  ];

  # Keep DMS's service linked to the package selected by the system module.
  home.activation.dmsServiceRelink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DMS_UNIT="${osConfig.programs.dank-material-shell.package}/share/systemd/user/dms.service"
    LINK="${config.home.homeDirectory}/.config/systemd/user/dms.service"
    OLD_TARGET="$(readlink -f "$LINK" 2>/dev/null || true)"

    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user"
    $DRY_RUN_CMD ln -sfn "$DMS_UNIT" "$LINK"
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user/dms.service.d"
    $DRY_RUN_CMD cat > "${config.home.homeDirectory}/.config/systemd/user/dms.service.d/icon-theme-race-fix.conf" << EOF_SERVICE
    [Service]
    Environment=QT_QPA_PLATFORMTHEME=qt6ct
    Environment=QS_ICON_THEME=Papirus-Dark
    Environment=XDG_DATA_DIRS=/nix/store/smn5bv5gqz8sfyg6c2rga82g8s6bd1m5-ghostty-1.3.1/share:/nix/store/jkmzkh3rjak10ccsrkgwybxngqqswgm4-gsettings-desktop-schemas-50.1/share/gsettings-schemas/gsettings-desktop-schemas-50.1:/nix/store/6d3v90p73c3qx6axdlqnm5xfd4w93w20-gtk4-4.22.4/share/gsettings-schemas/gtk4-4.22.4:/nix/store/gvgrz4bh8hryjzrvkqjiwyh4acpn27aj-quickshell-0.3.1/share:/run/current/sw/share:/nix/store/id7wgv26ga466m5n2cmn2hv3g5y45861-desktops/share:/home/ayaan_mirza/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/ayaan_mirza/.nix-profile/share:/nix/profile/share:/home/ayaan_mirza/.local/state/nix/profile/share:/etc/profiles/per-user/ayaan_mirza/share:/nix/var/nix/profiles/default/share:/run/current/sw/share
    EOF_SERVICE

    if [ "$OLD_TARGET" != "$(readlink -f "$LINK" 2>/dev/null || true)" ]; then
      $DRY_RUN_CMD${pkgs.systemd}/bin/systemctl --user daemon-reload || true
      $DRY_RUN_CMD${pkgs.systemd}/bin/systemctl --user try-restart dms.service || true
    fi
  '';
}
