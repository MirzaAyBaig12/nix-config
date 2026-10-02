{ inputs, ... }:

{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  # Catppuccin ports for every program HM knows about. Mocha + Mauve everywhere.
  # Stylix autoEnable is off (see stylix.nix), so catppuccin is what themes stuff.
  # GTK/Qt toolkit styling stays explicit in stylix.nix + gtk.nix.
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    gtk.icon.enable = false;
    chromium.enable = false;
    qt5ct.enable = false;
    kvantum = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
    };
  };
}
