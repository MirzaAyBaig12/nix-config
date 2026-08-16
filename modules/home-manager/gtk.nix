{ pkgs, ... }:

let
  orchis-theme-pkg = pkgs.orchis-theme.override {
    tweaks = [ "primary" ];
  };
in
{
  gtk = {
    enable = true;

    theme = {
      name = "Orchis-Purple-Dark";
      package = orchis-theme-pkg;
    };

    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
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
    gtk-theme-name="Orchis-Purple-Dark"
    gtk-icon-theme-name="breeze-dark"
    gtk-cursor-theme-name="Bibata-Material-Slate"
    gtk-cursor-theme-size=20
    gtk-font-name="Noto Sans 10"
  '';

  # GTK3 configuration
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  # GTK4 configuration
  gtk.gtk4.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

  # Correctly link individual GTK4 / Libadwaita stylesheets
  xdg.configFile."gtk-4.0/gtk.css" = {
    source = "${orchis-theme-pkg}/share/themes/Orchis-Purple-Dark/gtk-4.0/gtk.css";
    force = true;
  };
  xdg.configFile."gtk-4.0/gtk-dark.css" = {
    source = "${orchis-theme-pkg}/share/themes/Orchis-Purple-Dark/gtk-4.0/gtk-dark.css";
    force = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = "Orchis-Purple-Dark";
    icon-theme = "breeze-dark";
    cursor-theme = "Bibata-Material-Slate";
    cursor-size = 20;
    color-scheme = "prefer-dark";
  };
}