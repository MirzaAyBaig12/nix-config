{ config, pkgs, lib, ... }:

{
  stylix = {
    enable = true;
    
    cursor = {
      name = "Bibata-Material-Slate";
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
        button, entry, combobox, menu, .csd window {
          border-radius: 8px;
        }
      '';
    };

    targets.qt = {
      enable = true;
      platform = "qtct";
    };
  };
}