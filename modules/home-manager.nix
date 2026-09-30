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
        ./home-manager/fastfetch.nix
        ./home-manager/zsh.nix
        ./home-manager/stylix.nix
        ./home-manager/nixd.nix
        ./home-manager/vscode.nix
        ./home-manager/services.hm.nix
        ./home-manager/niri.config.nix
        ./home-manager/fx-autoconfig.hm.nix
        ./home-manager/nixcord.nix

        # Upstream Home Manager modules
        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.stylix.homeModules.stylix
        inputs.danksearch.homeModules.dsearch
        inputs.nix-monitor.homeManagerModules.default
        inputs.catppuccin.homeModules.catppuccin
        inputs.nixcord.homeModules.nixcord
      ];

      # Home profile identity and compatibility version
      home.stateVersion = "26.05";
      home.username = "ayaan_mirza";
      home.homeDirectory = "/home/ayaan_mirza";
    };
  };
}
