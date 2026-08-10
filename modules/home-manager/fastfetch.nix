{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".source = ~/nix-config/.config/fastfetch/config.jsonc;
  xdg.configFile."fastfetch/compact-config.jsonc".source = ~/nix-config/.config/fastfetch/compact-config.jsonc;
}
