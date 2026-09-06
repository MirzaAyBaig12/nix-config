{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #vscode
    gtk2
    nixd
    nixfmt
    qt6Packages.qt6ct
    libsForQt5.qt5ct
  ];

  services.flameshot = {
    # Also installs/enables flameshot
    enable = true;
  };

  # DankSearch — file search plugin powering DMS's launcher results
  programs.dsearch.enable = true;
}