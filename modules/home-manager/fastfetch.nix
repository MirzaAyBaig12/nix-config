{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];

  # symlinks your actual jsonc configs into ~/.config/fastfetch/
  # keeps comments + formatting intact (no lossy programs.fastfetch.settings conversion)
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
  xdg.configFile."fastfetch/compact-config.jsonc".source = ./fastfetch/compact-config.jsonc;
}
