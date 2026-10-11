
{
  description = "Комиссар Блятников's Nix Flake";

  nixConfig = {
    extra-substituters = [ "https://look.cachix.org" ];
    extra-trusted-public-keys = [
      "look.cachix.org-1:8elPCeSVBzlDZXqIRKBK9GyLIK/Hoe1xiWZF0ir7uX4="
    ];
    extra-deprecated-features = [ "or-as-identifier" ];
  };

  inputs = {
    # 1. NixOS packages used to build the system and install applications.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 2. Declarative Flatpak management.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # 3. Theming module for NixOS and Home Manager.
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # 4. Claude Desktop client.
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";

    # 5. Plymouth boot splash theme.
    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 6. WinPodX: launches Windows applications as desktop entries.
    winpodx.url = "github:kernalix7/winpodx";
    winpodx.inputs.nixpkgs.follows = "nixpkgs";

    # 7. Home Manager.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 8. Secure Boot support.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 9. CLI coding agents.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # 10. DankSearch.
    danksearch.url = "github:AvengeMedia/danksearch";
    danksearch.inputs.nixpkgs.follows = "nixpkgs";

    # 11. DankGreeter.
    dank-greeter.url = "github:AvengeMedia/dank-greeter";
    dank-greeter.inputs.nixpkgs.follows = "nixpkgs";

    # 12. DankMaterialShell.
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 13. dgop system monitoring utility.
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 14. Home Manager module for monitoring Nix builds and system activity.
    nix-monitor.url = "github:antonjah/nix-monitor";

    # 15. Free Download Manager.
    fdm-nix.url = "github:QaisAlsaid/fdm-nix";

    # 16. Browser config.js files used by Natsumi and LibreWolf.
    fx-autoconfig = {
      url = "github:MrOtherGuy/fx-autoconfig";
      flake = false;
    };

    # 17. Local Natsumi browser-theme module.
    natsumi = {
      url = "github:MirzaAyBaig12/natsumi-browser?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 18. VS Code extensions.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 19. Catppuccin theme modules.
    catppuccin.url = "github:catppuccin/nix";

    # 20. Pinned Catppuccin GTK theme source.
    catppuccinGtkTheme = {
      url = "github:Fausto-Korpsvart/Catppuccin-GTK-Theme/a0f69cc33299dc97267c3507fe8a001aecc46b0f";
      flake = false;
    };

    # 21. Discord client configuration.
    nixcord.url = "github:4evy/nixcord";

    # 22. Blip desktop shell module.
    blip.url = "github:blip-net/nix";

    # 23. Containerpak module.
    cpak.url = "github:Containerpak/cpak/v2";

    # 24. ChatGPT Desktop package.
    chatgpt-desktop.url = "github:alioguzhan/chatgpt-desktop-flake";

    # 25. Helium browser package.
    helium.url = "github:amaanq/helium-flake";

    # 26. Brave Origin flake.
    brave-origin.url = "github:tekq/brave-origin-flake";

    # 27. External AppImages.
    nix-ext-packages.url = "github:MirzaAyBaig12/nix-ext-packages";

    # Linux Files.
    LinuxFiles.url = "github:MemerGamer/LinuxFiles";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-flatpak,
      claude-desktop,
      mac-style-plymouth,
      winpodx,
      home-manager,
      llm-agents,
      cpak,
      catppuccin,
      helium,
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

            # Package overlays.
            {
              nixpkgs.overlays = [
                # Use the stable Lix package set for these tools.
                (
                  final: prev: {
                    inherit (prev.lixPackageSets.stable)
                      nixpkgs-review
                      nix-eval-jobs
                      nix-fast-build
                      colmena;
                  }
                )

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

                # WinPodX and Chiaki-NG fixes.
                (
                  final: prev: {
                    # WinPodX: retain the upstream flake package as the base,
                    # then apply the certificate and test overrides.
                    winpodx =
                      inputs.winpodx.packages.${final.stdenv.hostPlatform.system}.default
                        .overrideAttrs (old: {
                          nativeBuildInputs =
                            (old.nativeBuildInputs or [ ])
                            ++ [ final.cacert ];

                          env = (old.env or { }) // {
                            SSL_CERT_FILE =
                              "${final.cacert}/etc/ssl/certs/ca-bundle.crt";
                          };

                          doCheck = false;
                          checkPhase = "echo skipping winpodx tests";
                          installCheckPhase = "echo skipping winpodx tests";
                        });

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
                "ventoy-gtk3-1.1.17"
              ];
            }
          ];
        };
      };
    };
}
