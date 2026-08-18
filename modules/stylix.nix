{ pkgs, ... }:

let
  bibata-material-cursor = pkgs.callPackage ../packages/bibata-material-cursor.nix { };
in
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    targets.plymouth.enable = false;

    # Updated Stylix syntax for icons
    icons = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      dark = "Adwaita";
      light = "Adwaita";
    };

    cursor = {
      # Ayaan's own fork (packages/bibata-material-cursor.nix), NOT the
      # nixpkgs `bibata-cursors` package — that's a different upstream
      # project with no Material/Slate variant.
      package = bibata-material-cursor;
      name = "Bibata-Material-Slate";
      size = 24;
    };
  };
}