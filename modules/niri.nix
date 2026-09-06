{ config, pkgs, lib, ... }:

{
  # niri — scrollable-tiling Wayland compositor, run as an alt session
  # alongside COSMIC (pick either at the greeter). Module comes from the
  # niri flake input, imported in flake.nix.
  programs.niri.enable = true;

  # XWayland support — niri has no built-in Xwayland, it relies on the
  # separate xwayland-satellite process. Native module doesn't spawn it
  # automatically; needs the package installed + started at niri login.
  environment.systemPackages = [ 
    pkgs.xwayland-satellite 
    pkgs.xdg-desktop-portal-wlr # Added for wlroots screencopy/screenshots
  ];

  # DankMaterialShell — the actual shell (panel, dock, launcher, lock
  # screen, notifications) for niri, since niri ships bare with none of
  # that. Native nixpkgs module — needs nixos-unstable, which this flake
  # already tracks.
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Scope portals by session. niri gets COSMIC's portal first (native
  # file picker, settings, notifications) with xdg-desktop-portal-wlr 
  # as the fallback for screenshots/screencast.
  xdg.portal = { 
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      cosmic.default = [ "cosmic" ];
      niri.default = lib.mkForce [ "cosmic" "wlr" ];
      common = {
        default = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
      };
    };
  };
}