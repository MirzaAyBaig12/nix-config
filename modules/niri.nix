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
  # (pick either at the greeter).
  programs.niri.enable = true;

  # Xwayland compatibility. Niri relies on the separate xwayland-satellite
  # process, so keep its package installed for Xwayland applications.
  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.xdg-desktop-portal-gnome # screencast/screenshot backend for niri (org.gnome.Mutter.ScreenCast)
  ];

  # Desktop shell
  # DankMaterialShell, the actual shell for niri (panel, dock, launcher, lock screen,
  # notifications) since niri ships bare with none of that. uses the flake's own
  # module instead of nixpkgs' vendored one.
  programs.dank-material-shell = {
    enable = true;

    plugins = {
      caffeineRedesigned.enable = true;
      nixPackageRunner.enable = true;
      prayerTimes.enable = true;
      quranWidget.enable = true;
      vscodeLauncher.enable = true;
      webSearch.enable = true;
      dankPomodoroTimer.enable = true;
      emojiLauncher.enable = true;
      activateLinux.enable = true;
      batteryOSD.enable = true;
      calculator.enable = true;
      dankGifSearch.enable = true;
      emojiPicker.enable = true;
      modernClock.enable = true;
      quickCapture.enable = true;
    };

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

  programs.dux-files = {
    enable = true;
    systemd.enable = true;
    portal.enable = true;
  };

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
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      niri = {
        default = lib.mkForce [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
        #use dux-files as file picker
        "org.freedesktop.impl.portal.FileChooser" = [ "dfiles" ];
        # pin screen capture to gnome (niri implements org.gnome.Mutter.ScreenCast, this
        # also gives per-window capture). note the capital C in ScreenCast, interface
        # names are case sensitive. wlr was tried and never got routed/worked
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      };
    };
  };
}
