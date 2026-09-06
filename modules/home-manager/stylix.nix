{ config, pkgs, lib, ... }:

{
  stylix = {
    enable = true;
    
    cursor = {
      package = pkgs.callPackage ../../packages/bibata-material-cursor.nix {};
      name = "Bibata-Material-Lilac";
      size = 24;
    };

    fonts = {
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "Sans";
      };
      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    base16Scheme = {
      base00 = "2B2E34";
      base01 = "333842";
      base02 = "3F4451";
      base03 = "5c6370";
      base04 = "abb2bf";
      base05 = "FFFFFF";
      base06 = "e5c07b";
      base07 = "ffffff";
      base08 = "e06c75";
      base09 = "d19a66";
      base0A = "e5c07b";
      base0B = "98c379";
      base0C = "56b6c2";
      base0D = "61afef";
      base0E = "E79CFE";
      base0F = "be5046";
    };

    targets.gtk = {
      enable = true;
      extraCss = ''
        @define-color theme_selected_bg_color #E79CFE;
        @define-color theme_selected_fg_color #000000;
        @define-color accent_color #E79CFE;
        @define-color accent_bg_color #E79CFE;
        @define-color accent_fg_color #000000;
        @define-color window_bg_color #2B2E34;
        @define-color window_fg_color #FFFFFF;

        * {
          border-radius: 8px;
        }
        button, entry, combobox, menu, window, .csd window {
          border-radius: 8px;
        }
      '';
    };

    targets.qt = {
      enable = true;
      platform = "qtct";
    };
  };

  # DMS has "syncModeWithPortal": true, meaning it doesn't remember a
  # dark/light choice at all — it just mirrors this dconf key on every
  # sync, which is why colors.kdl kept reverting no matter what got
  # patched after the fact. Pin the actual source to dark.
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = lib.mkForce "prefer-dark";
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = lib.mkForce "Adwaita";
    };
    cursorTheme = {
      name = "Bibata-Material-Lilac";
      size = 24;
    };
    gtk2.extraConfig = ''
      gtk-cursor-theme-name="Bibata-Material-Lilac"
      gtk-cursor-theme-size=24
      gtk-font-name="Sans 11"
      gtk-application-prefer-dark-theme=1
      gtk-decoration-layout="menu:minimize,maximize,close"
      gtk-enable-animations=1
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-cursor-blink=1
      gtk-cursor-blink-time=1000
      gtk-primary-button-warps-slider=1
      style "modern-rounded" {
        GtkWidget::corner-radius = 6
      }
      widget_class "*" style "modern-rounded"
    '';
  };

  # Stylix's gtk target writes these declaratively — force overwrite
  # instead of erroring/needing .bak cleanup on every rebuild
  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
}