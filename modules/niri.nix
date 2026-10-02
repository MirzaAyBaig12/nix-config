{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Niri compositor and session
  # niri, scrollable tiling wayland compositor. runs as an alt session next to COSMIC
  # (pick either at the greeter). module comes from the niri flake input imported in
  # flake.nix
  programs.niri.enable = true;

  # Xwayland compatibility. Niri relies on the separate xwayland-satellite
  # process, so keep its package installed for Xwayland applications.
  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.xdg-desktop-portal-wlr # Added for wlroots screencopy/screenshots
  ];

  # Desktop shell
  # DankMaterialShell, the actual shell for niri (panel, dock, launcher, lock screen,
  # notifications) since niri ships bare with none of that. back on the flake's own
  # module instead of nixpkgs' vendored one, see flake.nix input #21b
  programs.dank-material-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableVPN = true;
    enableDynamicTheming = false;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Keep the GTK Settings portal's org.freedesktop.appearance color-scheme fixed
  # to dark. xdg-desktop-portal-gtk derives that portal value from this GSettings
  # key; the system database lock prevents user settings from changing its report.
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      locks = [ "/org/gnome/desktop/interface/color-scheme" ];
    }
  ];

  # Session-specific portals
  # scope portals by session. niri gets COSMIC's portal first (native file picker,
  # notifications) with xdg-desktop-portal-wlr as the fallback for
  # screenshots/screencast
  # EXCEPT Settings (color-scheme, accent-color, icon-theme), that one is forced to
  # gtk. COSMIC's own portal keeps its own separate theme state and ignores the GNOME
  # schema dconf keys set in home-manager/gtk.nix, so apps asking it were getting
  # inconsistent light/dark and the wrong accent. gtk reads dconf/gsettings directly
  # so it matches whats actually set
  # this reaches flatpak apps automatically too, they talk to the same system wide
  # portal service so no separate flatpak side config needed
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
