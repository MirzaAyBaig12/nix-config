{ 
  inputs, 
  ... 
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "bak";

    users.ayaan_mirza = {
      imports = [
        # Repository modules
        ./home-manager/programs.hm.nix
        ./home-manager/stylix.hm.nix
        ./home-manager/gtk.hm.nix
        ./home-manager/services.hm.nix
        ./home-manager/niri.config.nix
        ./home-manager/dotfiles/fastfetch.nix
        ./home-manager/dotfiles/nixcord.nix
        ./home-manager/dotfiles/nixd.nix
        ./home-manager/dotfiles/vscode.nix
        ./home-manager/dotfiles/web-apps.nix
        ./home-manager/dotfiles/zsh.nix

        # Upstream Home Manager modules
        inputs.danksearch.homeModules.dsearch
        inputs.nix-monitor.homeManagerModules.default
        inputs.nixcord.homeModules.nixcord
        inputs.catppuccin.homeModules.catppuccin
      ];

      # Qt 5 and Qt 6 use qtct for palette/font settings and Kvantum for
      # rounded widget rendering.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      # Home profile identity and compatibility version
      home.stateVersion = "26.05";
      home.username = "ayaan_mirza";
      home.homeDirectory = "/home/ayaan_mirza";
    };
  };
}
