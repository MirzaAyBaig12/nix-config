{ pkgs, ... }:
{
  gtk = {
    enable = true;

    theme = {
      name = "Orchis-Purple-Dark";
      package = pkgs.orchis-theme.override {
        tweaks = [ "primary" ];
      };
    };

    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };

    cursorTheme = {
      name = "Bibata-Material-Slate";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Noto Sans";
      size = 10;
    };

    gtk2.extraConfig = ''
      gtk-theme-name="Orchis-Purple-Dark"
      gtk-icon-theme-name="breeze-dark"
      gtk-cursor-theme-name="Bibata-Material-Slate"
      gtk-cursor-theme-size=24
      gtk-font-name="Noto Sans, 10"
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # libadwaita apps (GTK4-only, ignore the GTK theme name entirely) read
  # their theme from ~/.config/gtk-4.0/gtk.css — linking Orchis's own
  # gtk-4.0 output there is what its install.sh's `-l/--libadwaita` flag
  # does manually; this is the Home Manager equivalent.
  xdg.configFile."gtk-4.0/gtk.css" = {
    source = "${pkgs.orchis-theme.override { tweaks = [ "primary" ]; }}/share/themes/Orchis-Purple-Dark/gtk-4.0/gtk.css";
    force = true;
  };
  xdg.configFile."gtk-4.0/gtk-dark.css" = {
    source = "${pkgs.orchis-theme.override { tweaks = [ "primary" ]; }}/share/themes/Orchis-Purple-Dark/gtk-4.0/gtk-dark.css";
    force = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = "Orchis-Purple-Dark";
    icon-theme = "breeze-dark";
    cursor-theme = "Bibata-Material-Slate";
    color-scheme = "prefer-dark";
  };
}
