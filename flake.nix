{
  description = "My NixOS Configuration Flake";

  nixConfig = {
      extra-substituters = [ "https://look.cachix.org" ];
      extra-trusted-public-keys = [ "look.cachix.org-1:8elPCeSVBzlDZXqIRKBK9GyLIK/Hoe1xiWZF0ir7uX4=" ];
      extra-deprecated-features = [ "or-as-identifier" ];
    };

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
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";

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

    # 12. Look Launcher (Cachix)
    look.url = "github:kunkka19xx/look?dir=apps/linows";

    # 13. Home-Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 14. Lanzaboote — Secure Boot for NixOS
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 15. Custom Packages Flake (thorium, fladder, seanime, etc.)
    custom-packages.url = "github:Rishabh5321/custom-packages-flake";

    # 16. Stylix — theming framework
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # 17. LLM Agents Flake (Claude Code, Codex, Pi, OpenCode CLI)
    llm-agents.url = "github:numtide/llm-agents.nix";

    # 18. niri — scrollable-tiling Wayland compositor
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 19. DankGreeter — greetd login screen for DankMaterialShell
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 20. DankSearch — file search backing DMS's launcher
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-snapd, nix-software-center, nix-flatpak, cosmic-manager, codex-desktop-linux, claude-desktop, mac-style-plymouth, winpodx, home-manager, llm-agents, ... }@inputs: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

    nixosConfigurations = {
      Void = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = { inherit inputs; };

        modules = [
          # Links your local configuration.nix file
          ./configuration.nix

          # Pulls in the Snap module from the nix-snapd repository
          nix-snapd.nixosModules.default

          # Codex Desktop (ChatGPT Desktop) NixOS module
          codex-desktop-linux.nixosModules.default

          # Declarative Flatpak module
          nix-flatpak.nixosModules.nix-flatpak

          # Lanzaboote — Secure Boot module
          inputs.lanzaboote.nixosModules.lanzaboote

          # Stylix — theming framework
          inputs.stylix.nixosModules.stylix

          # niri is provided by nixpkgs' native NixOS module. Do not import
          # niri-flake here: its legacy default package requires the removed
          # libdisplay-info_0_2 compatibility alias.

          # DankGreeter — greetd login screen (replaces cosmic-greeter)
          inputs.dank-greeter.nixosModules.default

          # Enables the snap service inline
          {
            services.snap.enable = false;
          }

          # Applies the mac-style plymouth theme overlay
          {
            nixpkgs.overlays = [ mac-style-plymouth.overlays.default ];
          }

          # Tags each generation with the git revision it was built from
          {
            system.configurationRevision = self.rev or self.dirtyRev or "dirty";
          }

          # Explicitly permits the insecure ventoy-gtk package
          {
            nixpkgs.config.permittedInsecurePackages = [
              "ventoy-gtk3-1.1.17"
            ];
          }
        ];
      };
    };
  };
}