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

  # nix-monitor — tracks rebuild status/history. Home-manager module,
  # not the NixOS one — the NixOS module tries to symlink a plugin
  # config into /etc/xdg/quickshell/dms-plugins/, which collides with
  # DMS's own plugin-dir symlink there (permission denied at build).
  programs.nix-monitor = {
    enable = true;
    rebuildCommand = [
      "bash" "-c"
      "doas nixos-rebuild switch --flake ~/nix-config#Void 2>&1"
    ];
  };
}