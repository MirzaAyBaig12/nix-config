{ config, pkgs, lib, ... }:

{
  stylix = {
    enable = true;
    
    cursor = {
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
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    base16Scheme = {
      base00 = "141318";
      base01 = "201f25";
      base02 = "2b292f";
      base03 = "9b99a5";
      base04 = "c9c5d0";
      base05 = "e5e1e9";
      base06 = "e6e2ff";
      base07 = "f9f8ff";
      base08 = "ff7292";
      base09 = "d19a66";
      base0A = "ffd972";
      base0B = "7fff98";
      base0C = "56b6c2";
      base0D = "b3a9f2";
      base0E = "c8bfff";
      base0F = "be5046";
    };

    targets.gtk = {
      enable = true;
      extraCss = ''
        @define-color theme_selected_bg_color #c8bfff;
        @define-color theme_selected_fg_color #30285f;
        @define-color accent_color #c8bfff;
        @define-color accent_bg_color #c8bfff;
        @define-color accent_fg_color #30285f;
        @define-color window_bg_color #141318;
        @define-color window_fg_color #e5e1e9;

        * {
          border-radius: 8px;
        }
        button, entry, combobox, menu, .csd window {
          border-radius: 8px;
        }
      '';
    };

    targets.qt = {
      enable = true;
      platform = "qtct";
    };

    # These two targets set nixpkgs.overlays internally, which throws the
    # "nixpkgs.config/overlays set while useGlobalPkgs" warning. nixos-icons
    # is redundant anyway since gtk.iconTheme is force-set to Adwaita in
    # home-manager/stylix.nix; gtksourceview isn't something we're relying
    # on stylix for.
    targets.nixos-icons.enable = false;
    targets.gtksourceview.enable = false;
  };
}