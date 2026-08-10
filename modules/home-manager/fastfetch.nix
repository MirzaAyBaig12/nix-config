{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".source = ../../.config/fastfetch/config.jsonc;
  xdg.configFile."fastfetch/compact-config.jsonc".source = ../../.config/fastfetch/compact-config.jsonc;
}
