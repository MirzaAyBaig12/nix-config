{
  description = "My NixOS Configuration Flake";

  inputs = {
    # 1. Core NixOS package repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # 2. Third-party Snap support for NixOS
    nix-snapd.url = "github:nix-community/nix-snapd";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";
    
    # 3. Nix Software Center
    nix-software-center.url = "github:xinux-org/software-center";

    # 4. Declarative Flatpak support
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # 5. Codex Desktop (Linux) — ChatGPT Desktop, installed via its
    # NixOS module so the launcher gets wrapped with CODEX_CLI_PATH.
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    codex-desktop-linux.inputs.nixpkgs.follows = "nixpkgs";

    # 5b. Community Codex CLI (unofficial, not maintained by the
    # codex-desktop-linux project) — provides the actual `codex`
    # binary that ChatGPT Desktop needs at runtime.
    codex-cli-nix.url = "github:sadjow/codex-cli-nix/main";
    codex-cli-nix.inputs.nixpkgs.follows = "nixpkgs";

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

    # 10. GUI for efibootmgr
    efiboots.url = "github:elinvention/efiboots";

    # 11. iLoader for iOS Sideloading
    iloader.url = "github:nab138/iloader";

  };

  outputs = { self, nixpkgs, nix-snapd, nix-software-center, nix-flatpak, codex-desktop-linux, claude-desktop, mac-style-plymouth, winpodx, ... }@inputs: {
    nixosConfigurations = {
      Axiom = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit inputs; };
        
        modules = [
          # Links your local configuration.nix file
          ./configuration.nix 

          # Pulls in the Snap module from the nix-snapd repository
          nix-snapd.nixosModules.default 

          # Codex Desktop (ChatGPT Desktop) NixOS module
          codex-desktop-linux.nixosModules.default

          # Enables the snap service inline
          {
            services.snap.enable = false;
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
