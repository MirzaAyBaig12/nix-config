{ pkgs, ... }:

{
  gtk = {
    enable = true;

    # Stock Adwaita for GTK2/3 — libadwaita (GTK4) ignores this and
    # renders its own built-in style regardless, so no GTK4 theme
    # package is needed here at all.
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Material-Slate";
      package = pkgs.bibata-cursors;
      size = 20;
    };

    font = {
      name = "Noto Sans";
      size = 10;
    };
  };

  # GTK2 extra configuration
  gtk.gtk2.extraConfig = ''
    gtk-theme-name="Adwaita-dark"
    gtk-icon-theme-name="Adwaita"
    gtk-cursor-theme-name="Bibata-Material-Slate"
    gtk-cursor-theme-size=20
    gtk-font-name="Noto Sans 10"
  '';

  # GTK3 configuration
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  # GTK4 / libadwaita configuration — dark mode only. Accent color for
  # libadwaita apps is NOT a dconf/gtk setting; it's fed through the
  # portal from COSMIC's own accent-color setting (Settings ->
  # Appearance in COSMIC), so set purple there once
  # xdg-desktop-portal-cosmic is confirmed running.
  gtk.gtk4.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = "Adwaita-dark";
    icon-theme = "Adwaita";
    cursor-theme = "Bibata-Material-Slate";
    cursor-size = 20;
    color-scheme = "prefer-dark";
    accent-color = "purple";
  };
}
