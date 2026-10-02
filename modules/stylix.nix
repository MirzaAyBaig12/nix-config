{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  catppuccinGtkTheme = import ./gtk.nix {
    inherit pkgs;
    src = inputs.catppuccinGtkTheme;
  };
in
{
  # Install outside the per-user profile too so system GTK apps can resolve the
  # theme from the system XDG data directories.
  environment.systemPackages = [ catppuccinGtkTheme ];

  stylix = {
    enable = true;

    # Don't let stylix auto-theme every target (chromium etc). Catppuccin handles
    # that now (see catppuccin.nix), stylix only does what's explicitly enabled.
    autoEnable = false;

    # Cursor theme
    cursor = {
      package = config.custom.bibataMaterialCursor;
      name = "Bibata-Material-Lilac";
      size = 30;
    };

    # Font families
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

    # Base16 color palette
    base16Scheme = {
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    };

    # GTK and Qt are themed directly with Catppuccin, not Stylix targets.
    targets.gtk.enable = false;
    targets.qt.enable = false;
    targets.chromium.enable = false;

    # these two targets set nixpkgs.overlays internally which throws the
    # "nixpkgs.config/overlays set while useGlobalPkgs" warning. nixos-icons is
    # redundant anyway cuz gtk.iconTheme is force set to Adwaita in
    # home-manager/stylix.nix, and im not relying on stylix for gtksourceview
    targets.nixos-icons.enable = false;
    targets.gtksourceview.enable = false;
  };
}
