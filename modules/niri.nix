{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # niri — scrollable-tiling Wayland compositor, run as an alt session
  # alongside COSMIC (pick either at the greeter). Module comes from the
  # niri flake input, imported in flake.nix.
  programs.niri.enable = true;

  # XWayland support — niri has no built-in Xwayland, it relies on the
  # separate xwayland-satellite process. Native module doesn't spawn it
  # automatically; needs the package installed + started at niri login.
  # Pinned to 0.8.1 via an older nixpkgs rev — current nixos-unstable's
  # version has a bug breaking Xwayland apps (found via a Reddit thread,
  # not upstream-fixed yet). See flake.nix input #24.
  environment.systemPackages = [
    (import inputs.nixpkgs-xwayland-satellite-0-8-1 { system = pkgs.stdenv.hostPlatform.system; })
    .xwayland-satellite
    pkgs.xdg-desktop-portal-wlr # Added for wlroots screencopy/screenshots
  ];

  # DankMaterialShell — the actual shell (panel, dock, launcher, lock
  # screen, notifications) for niri, since niri ships bare with none of
  # that. Comes from nixpkgs directly (vendored built-in module, same
  # option schema as the standalone flake) — no separate flake input.
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Scope portals by session. niri gets COSMIC's portal first (native
  # file picker, notifications) with xdg-desktop-portal-wlr as the
  # fallback for screenshots/screencast — EXCEPT Settings (color-scheme,
  # accent-color, icon-theme), forced to gtk specifically: COSMIC's own
  # portal keeps its own separate theme state, not the GNOME-schema dconf
  # keys set in home-manager/stylix.nix, so apps querying Settings via
  # COSMIC's portal were getting inconsistent light/dark + wrong accent.
  # gtk reads dconf/gsettings directly, matching what's actually set.
  # This also reaches Flatpak apps automatically — they talk to the same
  # system-wide portal service, no separate flatpak-side config needed.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      cosmic.default = [ "cosmic" ];
      niri = {
        default = lib.mkForce [
          "cosmic"
          "wlr"
        ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
      };
      common = {
        default = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
      };
    };
  };
}
