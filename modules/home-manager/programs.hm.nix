{ 
  pkgs, 
  ... 
}:

{
  home.packages = with pkgs; [
    #vscode
    gtk2
    nixd
    nixfmt
    qt6Packages.qt6ct
    libsForQt5.qt5ct
  ];

  # DankSearch, file search plugin that powers the DMS launcher results
  programs.dsearch.enable = true;

  # nix-monitor, tracks rebuild status/history. using the home-manager module not the
  # nixos one, the nixos module tries to symlink a plugin config into
  # /etc/xdg/quickshell/dms-plugins/ which collides with DMS's own plugin dir symlink
  # there (permission denied at build)
  programs.nix-monitor = {
    enable = true;
    rebuildCommand = [
      "bash"
      "-c"
      "doas nixos-rebuild switch --flake ~/nix-config#Axiom 2>&1"
    ];
  };
}
