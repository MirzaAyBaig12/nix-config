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

    # 14. Lanzaboote — Secure Boot for NixOS (floats on default branch,
    # updates with `nix flake update` instead of a pinned tag)
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 15. Custom Packages Flake (thorium, fladder, seanime, etc.)
    custom-packages.url = "github:Rishabh5321/custom-packages-flake";

    # 16. Stylix — theming framework. autoEnable is set to false in
    # modules/stylix.nix so it only handles icon theming (via
    # stylix.icons.*); everything else (GTK colors, cursor, dconf) stays
    # manually configured in modules/home-manager/gtk.nix and system.nix.
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, nix-snapd, nix-software-center, nix-flatpak, codex-desktop-linux, claude-desktop, mac-style-plymouth, winpodx, home-manager, ... }@inputs: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

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

          # Declarative Flatpak module
          nix-flatpak.nixosModules.nix-flatpak

          # Lanzaboote — Secure Boot module (replaces systemd-boot;
          # actual boot.lanzaboote settings live in configuration.nix / modules)
          inputs.lanzaboote.nixosModules.lanzaboote

          # Stylix — theming framework (icon theming only, see modules/stylix.nix)
          inputs.stylix.nixosModules.stylix

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

          # Explicitly permits the insecure ventoy-full package
          {
            nixpkgs.config.permittedInsecurePackages = [
              "ventoy-qt-1.1.17"
            ];
          }
        ];
      };
    };
  };
}