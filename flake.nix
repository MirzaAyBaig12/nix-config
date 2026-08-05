{
  description = "My NixOS Configuration Flake";

  inputs = {
    # 1. Core NixOS package repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 2. Third-party Snap support for NixOS
    nix-snapd.url = "github:nix-community/nix-snapd";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
    
    # 3. Nix Software Center
    nix-software-center.url = "github:snowfallorg/nix-software-center";
    nix-software-center.inputs.nixpkgs.follows = "nixpkgs";

    # 4. Declarative Flatpak support
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # 5. Codex Desktop (Linux)
    codex-desktop.url = "github:ilysenko/codex-desktop-linux";
    codex-desktop.inputs.nixpkgs.follows = "nixpkgs";

    # 6. Claude Desktop (unofficial Linux build)
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";

    # 7. Mac-style Plymouth boot theme
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 8. WinPodX
    winpodx.url = "github:kernalix7/winpodx";
    winpodx.inputs.nixpkgs.follows = "nixpkgs";
    
    # 9. NixOS Conf Editor
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
  };

  outputs = { self, nixpkgs, nix-snapd, nix-software-center, nix-flatpak, codex-desktop, claude-desktop, mac-style-plymouth, winpodx, ... }@inputs: {
    nixosConfigurations = {
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

          # Applies the mac-style plymouth theme overlay
          {
            nixpkgs.overlays = [ mac-style-plymouth.overlays.default ];
          }
        ];
      };
    };
  };
}
