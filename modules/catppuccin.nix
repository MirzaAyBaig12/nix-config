{ inputs, ... }:

{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  # System-wide Catppuccin ports (tty, console, bootloader, etc). Mocha + Mauve everywhere.
  # Stylix autoEnable is off now (see stylix.nix), so catppuccin is what themes stuff.
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    # Boot splash is the mac-style plymouth theme (see system.nix), not catppuccin's.
    plymouth.enable = false;
  };
}
