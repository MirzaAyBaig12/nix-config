{ inputs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };

    users.ayaan_mirza = {
      imports = [
        #imports from home-manager modules
        ./home-manager/fastfetch.nix
        ./home-manager/zsh.nix
      ];

      home.stateVersion = "26.05";
      home.username = "ayaan_mirza";
      home.homeDirectory = "/home/ayaan_mirza";
    };
  };
}
