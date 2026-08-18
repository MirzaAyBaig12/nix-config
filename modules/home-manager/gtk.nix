{ config, pkgs, ... }:

let
  bibata-material-cursor = pkgs.callPackage ../../packages/bibata-material-cursor.nix { };
in
{
  # Ensure your gtk settings are enabled
  gtk = {
    enable = true;

    # Theme configuration
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Icon theme
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    # Font settings
    font = {
      name = "Sans 11";
    };

    # Correct options for GTK 3 & 4 custom CSS overrides
    gtk3.extraCss = ''
      @define-color accent_color #a578f3;
      @define-color accent_bg_color #9141ac;
      @define-color accent_fg_color #ffffff;
      @define-color theme_selected_bg_color #9141ac;
      @define-color theme_selected_fg_color #ffffff;
    '';

    gtk4.extraCss = ''
      @define-color accent_color #a578f3;
      @define-color accent_bg_color #9141ac;
      @define-color accent_fg_color #ffffff;
      @define-color theme_selected_bg_color #9141ac;
      @define-color theme_selected_fg_color #ffffff;
    '';
  };

  # GTK 4 dark mode environment configuration
  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };

  # DConf settings to persist system-wide dark scheme and accent preferences
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "purple";
    };
  };

  # Custom pointer cursor configuration (Bibata-Material-Slate fork)
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Material-Slate";
    package = bibata-material-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}