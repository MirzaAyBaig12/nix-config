{ 
  inputs, 
  pkgs,
  ... 
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # Existing files that collide with HM-managed ones get moved to `<file>.bak`;
    # overwriteBackup lets a new backup replace a stale .bak instead of erroring.
    backupFileExtension = "bak";
    overwriteBackup = true;

    users.ayaan_mirza = {
      imports = [
        # Repository modules
        ./home-manager/programs.hm.nix
        ./home-manager/stylix.hm.nix
        ./home-manager/services.hm.nix
        ./home-manager/dms.config.nix
        ./home-manager/dotfiles/chromium.nix
        ./home-manager/dotfiles/fastfetch.nix
        ./home-manager/dotfiles/ghostty.nix
        ./home-manager/dotfiles/git.nix
        ./home-manager/dotfiles/niri.config.nix
        ./home-manager/dotfiles/nixcord.nix
        ./home-manager/dotfiles/nixd.nix
        ./home-manager/dotfiles/starship.nix
        ./home-manager/dotfiles/superfile.nix
        ./home-manager/dotfiles/vscode.nix
        ./home-manager/dotfiles/web-apps.nix
        ./home-manager/dotfiles/zsh.nix
      ];

      # Qt 5 and Qt 6 use qtct for palette/font settings and Kvantum for
      # rounded widget rendering.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      # Home profile identity and compatibility version
      home = {
        stateVersion = "26.05";
        username = "ayaan_mirza";
        homeDirectory = "/home/ayaan_mirza";
      };
    };
  };
}
