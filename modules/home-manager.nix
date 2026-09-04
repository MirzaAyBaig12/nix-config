{ inputs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "bak";

    users.ayaan_mirza = {
      imports = [
        #imports from home-manager modules
        ./home-manager/programs.hm.nix
        ./home-manager/fastfetch.nix
        ./home-manager/zsh.nix
        ./home-manager/stylix.nix
        ./home-manager/nixd.nix
        ./home-manager/services.hm.nix

        inputs.cosmic-manager.homeManagerModules.cosmic-manager
        inputs.stylix.homeModules.stylix
      ];

      home.stateVersion = "26.05";
      home.username = "ayaan_mirza";
      home.homeDirectory = "/home/ayaan_mirza";
    };
  };
}
