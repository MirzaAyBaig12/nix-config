{
  description = "Комиссар Блятников's Nix Flake";

  nixConfig = {
    extra-substituters = [ 
      "https://nix-community.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://cache.lix.systems"
      "https://catppuccin.cachix.org"
      "https://noel.cachix.org"
      "https://cache.numtide.com"
      "https://hydra.iohk.io"

    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noel.cachix.org-1:pQHbMJOB5h5VqYi3RV0Vv0EaeHfxARxgOhE9j013XwQ="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    extra-deprecated-features = [ "or-as-identifier" ];
  };

  inputs = {
    # NixOS packages used to build the system and install applications.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Lix NixOS module (main branch tracks current Lix; release tags lag behind nixpkgs).
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    # Lix source the module builds. Without this the module uses its own stale pin (2.94-pre).
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/refs/tags/2.96.0.tar.gz";
      flake = false;
    };

    # Secure Boot support.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Flatpak management.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # Theming module for NixOS and Home Manager.
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Catppuccin theme modules.
    catppuccin.url = "github:catppuccin/nix";

    # DankMaterialShell.
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # DankGreeter.
    dank-greeter.url = "github:AvengeMedia/dank-greeter";
    dank-greeter.inputs.nixpkgs.follows = "nixpkgs";

    # DankSearch.
    danksearch.url = "github:AvengeMedia/danksearch";
    danksearch.inputs.nixpkgs.follows = "nixpkgs";

    # Blip desktop shell module.
    blip.url = "github:blip-net/nix";

    # Plymouth boot splash theme.
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code extensions.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Discord client configuration.
    nixcord.url = "github:4evy/nixcord";

    # External AppImages.
    nix-ext-packages.url = "github:MirzaAyBaig12/nix-ext-packages";

    # CLI coding agents.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # WinPodX: launches Windows applications as desktop entries.
    winpodx.url = "github:kernalix7/winpodx";
    winpodx.inputs.nixpkgs.follows = "nixpkgs";

    # Containerpak module.
    cpak.url = "github:Containerpak/cpak/v2";

    # Claude Desktop client.
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";

    # ChatGPT Desktop package.
    chatgpt-desktop.url = "github:alioguzhan/chatgpt-desktop-flake";

    # Helium browser package.
    helium = {
      url = "github:amaanq/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code Insiders via overlay (fixed package)
    vscode-insiders = {
      url = "github:auguwu/vscode-insiders-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Free Download Manager.
    fdm-nix.url = "github:QaisAlsaid/fdm-nix";

    # Strata file manager (flake by deepwatrcreatur, fork of lgse/strata).
    strata = {
      url = "github:deepwatrcreatur/nix-strata-filemanager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      claude-desktop,
      mac-style-plymouth,
      ...
    }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      nixosConfigurations = {
        Axiom = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };

          modules = [
            # Main configuration.
            ./configuration.nix

            {
              nixpkgs = {
                hostPlatform = "x86_64-linux";
                config.allowUnfree = true;
              };
            }

            # Declarative Flatpak.
            nix-flatpak.nixosModules.nix-flatpak

            # Stylix.
            inputs.stylix.nixosModules.stylix

            # Lanzaboote.
            inputs.lanzaboote.nixosModules.lanzaboote

            # DankGreeter.
            inputs.dank-greeter.nixosModules.default

            # DankMaterialShell.
            inputs.dms.nixosModules.dank-material-shell

            # Home Manager integration.
            inputs.home-manager.nixosModules.default

            # Lix.
            inputs.lix-module.nixosModules.default

            # Package overlays.
            {
              nixpkgs.overlays = [

                # Round the Catppuccin theme while preserving its upstream
                # theme name, files, palette, and module selection.
                (
                  final: prev: {
                    catppuccin-kvantum =
                      prev.catppuccin-kvantum.overrideAttrs (old: {
                        postInstall = (old.postInstall or "") + ''
                          for config in "$out"/share/Kvantum/catppuccin-*/*.kvconfig; do
                            sed -i '/^\[PanelButtonCommand\]$/a frame.expansion=16' "$config"
                            sed -i '/^\[Menu\]$/a frame.expansion=16' "$config"
                          done
                        '';
                      });
                  }
                )

                # Chiaki-NG fixes.
                (
                  final: prev: {

                    # Chiaki-NG: unset the global Kvantum style override
                    # for this executable only.
                    chiaki-ng =
                      prev.chiaki-ng.overrideAttrs (old: {
                        nativeBuildInputs =
                          (old.nativeBuildInputs or [ ])
                          ++ [ final.makeWrapper ];

                        postFixup = (old.postFixup or "") + ''
                          wrapProgram "$out/bin/chiaki" \
                            --unset QT_STYLE_OVERRIDE
                        '';
                      });
                  }
                )

                (import inputs.vscode-insiders)
                # Show up as plain "Visual Studio Code" in launchers.
                (final: prev: {
                  vscode-insiders = prev.vscode-insiders.overrideAttrs (old: {
                    postFixup = (old.postFixup or "") + ''
                      sed -i 's/Visual Studio Code - Insiders/Visual Studio Code/g' \
                        $out/share/applications/*.desktop
                    '';
                  });
                })
                mac-style-plymouth.overlays.default
                claude-desktop.overlays.default
              ];
            }

            # Generation revision.
            {
              system.configurationRevision =
                self.rev or self.dirtyRev or "dirty";
            }

            # Insecure packages.
            {
              nixpkgs.config.permittedInsecurePackages = [
                "ventoy-gtk3-1.1.18"
                "electron-41.10.7"
                "electron-39.8.10"
              ];
            }
          ];
        };
      };
    };
}