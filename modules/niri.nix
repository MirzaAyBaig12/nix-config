{ config, pkgs, lib, ... }:

{
  # niri — scrollable-tiling Wayland compositor, run as an alt session
  # alongside COSMIC (pick either at the greeter). Module comes from the
  # niri flake input, imported in flake.nix.
  programs.niri.enable = true;

  # XWayland support — niri has no built-in Xwayland, it relies on the
  # separate xwayland-satellite process. Native module doesn't spawn it
  # automatically; needs the package installed + started at niri login.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

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
  # file picker, settings, notifications) with GNOME's as fallback —
  # needed because xdg-desktop-portal-cosmic's screencast backend relies
  # on cosmic-comp-specific protocols niri doesn't implement, while
  # GNOME's screencast backend works with any wlr-screencopy compositor.
  # COSMIC itself stays untouched on its own portal only.
  xdg.portal.config = {
    cosmic.default = [ "cosmic" ];
    niri.default = lib.mkForce [ "cosmic" "gnome" ];
  };
}
