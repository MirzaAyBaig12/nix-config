{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/compact-config.jsonc".source = ./fastfetch/compact-config.jsonc;
}
