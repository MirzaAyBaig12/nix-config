{
  description = "My NixOS Configuration Flake";

  inputs = {
    # 1. Core NixOS package repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 2. Third-party Snap support for NixOS
    nix-snapd.url = "github:nix-community/nix-snapd";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
    
    #nix software center
    nix-software-center.url = "github:snowfallorg/nix-software-center";
    nix-software-center.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-snapd, nix-software-center, ... }@inputs: {
    nixosConfigurations = {
      # ⚠️ Replace "nixos" with your actual system hostname if it's different!
      Axiom = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit inputs; };
        
        modules = [
          # Links your local configuration.nix file
          ./configuration.nix 

          # Pulls in the Snap module from the nix-snapd repository
          nix-snapd.nixosModules.default 
          
          # Enables the snap service inline
          {
            services.snap.enable = true;
          }
        ];
      };
    };
  };
}

