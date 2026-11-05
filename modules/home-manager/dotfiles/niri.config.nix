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
    DROPIN="${config.home.homeDirectory}/.config/systemd/user/dms.service.d/icon-theme-race-fix.conf"
    OLD_TARGET="$(readlink -f "$LINK" 2>/dev/null || true)"
    OLD_DROPIN="$(cat "$DROPIN" 2>/dev/null || true)"

    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user"
    $DRY_RUN_CMD ln -sfn "$DMS_UNIT" "$LINK"
    $DRY_RUN_CMD mkdir -p "${config.home.homeDirectory}/.config/systemd/user/dms.service.d"
    $DRY_RUN_CMD cat > "$DROPIN" << EOF_SERVICE
    [Service]
    Environment=QT_QPA_PLATFORMTHEME=qt6ct
    Environment=QS_ICON_THEME=Papirus-Dark
    Environment=XDG_DATA_DIRS=${lib.concatStringsSep ":" [
      "/run/current-system/sw/share"
      "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
      "/var/lib/flatpak/exports/share"
      "${config.home.profileDirectory}/share"
      "/nix/profile/share"
      "/etc/profiles/per-user/${config.home.username}/share"
      "/nix/var/nix/profiles/default/share"
    ]}
    EOF_SERVICE

    NEW_DROPIN="$(cat "$DROPIN" 2>/dev/null || true)"
    if [ "$OLD_TARGET" != "$(readlink -f "$LINK" 2>/dev/null || true)" ] || [ "$OLD_DROPIN" != "$NEW_DROPIN" ]; then
      $DRY_RUN_CMD${pkgs.systemd}/bin/systemctl --user daemon-reload || true
      $DRY_RUN_CMD${pkgs.systemd}/bin/systemctl --user try-restart dms.service || true
    fi
  '';
}
