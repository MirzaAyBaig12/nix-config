{ 
  pkgs,
  inputs, 
  ... 
}:

{
  home.packages = with pkgs; [
    # Nix language server and formatter
    nixd
    nixfmt

    # GTK and Qt theme configuration
    gtk2
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    
    # Gaming
    inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.hydra-launcher
    inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.sklauncher
    inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.modrinth
    inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.ventoy
  ];

  # DankSearch, file search plugin that powers the DMS launcher results
  programs.dsearch.enable = true;
}
