{
  description = "Комиссар Блятников's Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.lix.follows = "lix";
    };

    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/refs/heads/release-2.96.tar.gz";
      flake = false;
    };

    iets.url = "github:numtide/iets";

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    dux-shell = {
      url = "github:duxlabs-dev/dux-shell/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dux-qt-base.follows = "dux-qt-base";
    };

    dux-greeter = {
      url = "github:duxlabs-dev/dux-greeter/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dux-qt-base.follows = "dux-qt-base";
    };

    dux-search = {
      url = "github:duxlabs-dev/dux-search/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-gop = {
      url = "github:duxlabs-dev/dux-gop/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dux-files = {
      url = "github:duxlabs-dev/dux-files/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dux-qt-base.follows = "dux-qt-base";
    };

    dux-qt-base.url = "github:duxlabs-dev/dux-qt-base";

    blip.url = "github:blip-net/nix";

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord.url = "github:4evy/nixcord";

    nix-ext-packages.url = "github:MirzaAyBaig12/nix-ext-packages";

    llm-agents.url = "github:numtide/llm-agents.nix";

    fcc-nix = {
      url = "github:MirzaAyBaig12/fcc-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winpodx = {
      url = "github:kernalix7/winpodx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cpak.url = "github:Containerpak/cpak/v2";

    nix-secrets = {
      url = "git+ssh://git@github.com/MirzaAyBaig12/nix-secrets";
      flake = false;
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:epireyn/niri-flake";
    };

    chatgpt-desktop.url = "github:alioguzhan/chatgpt-desktop-flake";

    helium = {
      url = "github:amaanq/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-insiders = {
      url = "github:iosmanthus/code-insiders-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lumine-capture.url = "github:Netflate/LumineCapture";
  };

  outputs =
    {
      self,
      nixpkgs,
      lix-module,
      iets,
      lanzaboote,
      nix-flatpak,
      mac-style-plymouth,
      stylix,
      catppuccin,
      dux-shell,
      dux-greeter,
      dux-search,
      dux-files,
      dux-plugin-registry,
      home-manager,
      nixcord,
      blip,
      nix-ext-packages,
      cpak,
      niri-flake,
      agenix,
      ...
    }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      nixosConfigurations = {
        Axiom = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # Patched flake inputs.
            inputs = inputs // {

              # dux-gop: skip broken Go tests.
              dux-gop = inputs.dux-gop // {
                packages = inputs.dux-gop.packages // {
                  x86_64-linux = inputs.dux-gop.packages.x86_64-linux // {
                    default =
                      inputs.dux-gop.packages.x86_64-linux.default.overrideAttrs
                        (old: {
                          doCheck = false;
                        });
                  };
                };
              };
            };
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

            # Import NixOS modules.

            # Lix Module & Overlay.
            lix-module.nixosModules.default

            # iets.
            iets.nixosModules.default

            # Declarative Flatpak Management.
            nix-flatpak.nixosModules.nix-flatpak

            # System Theme Management.
            stylix.nixosModules.stylix
            catppuccin.nixosModules.catppuccin

            # Bootloader.
            lanzaboote.nixosModules.lanzaboote

            # Dux Suite.
            dux-shell.nixosModules.dank-material-shell
            dux-greeter.nixosModules.default
            dux-plugin-registry.nixosModules.default
            dux-files.nixosModules.dux-files

            # Use the flake's Dux Files module instead of nixpkgs' module.
            { disabledModules = [ "programs/dux-files.nix" ]; }

            # Blip.
            blip.nixosModules.default

            # nix-ext-packages.
            nix-ext-packages.nixosModules.natsumi

            # Free Claude Code launchers and server service.
            inputs.fcc-nix.nixosModules.default

            # Containerpak.
            cpak.nixosModules.default

            # Niri.
            niri-flake.nixosModules.niri

            # Agenix.
            agenix.nixosModules.default

            # Home Manager.
            home-manager.nixosModules.default

            {
              home-manager.sharedModules = [
                dux-search.homeModules.dsearch
                nixcord.homeModules.nixcord
                catppuccin.homeModules.catppuccin
                nix-ext-packages.homeManagerModules.browser-extensions
              ];
            }

            # nix-ext-packages overrides.
            ({ lib, ... }: {
              nixpkgs.overlays = lib.mkBefore [
                inputs.nix-ext-packages.overlays.default

                (final: prev: {
                  bibata-material-cursor =
                    inputs.nix-ext-packages.packages.${final.stdenv.hostPlatform.system}.bibata-material-cursor;

                  drivedeck =
                    inputs.nix-ext-packages.packages.${final.stdenv.hostPlatform.system}.drivedeck;

                  euro-office =
                    inputs.nix-ext-packages.packages.${final.stdenv.hostPlatform.system}.euro-office;

                  iloader =
                    inputs.nix-ext-packages.packages.${final.stdenv.hostPlatform.system}.iloader;
                })
              ];
            })

            # Package overlays.
            ({ config, ... }: {
              nixpkgs.overlays = [

                # Catppuccin Kvantum rounding.
                (final: prev: {
                  catppuccin-kvantum =
                    prev.catppuccin-kvantum.overrideAttrs (old: {
                      postInstall = (old.postInstall or "") + ''
                        for config in "$out"/share/Kvantum/catppuccin-*/*.kvconfig; do
                          sed -i '/^\[PanelButtonCommand\]$/a frame.expansion=16' "$config"
                          sed -i '/^\[Menu\]$/a frame.expansion=16' "$config"
                        done
                      '';
                    });
                })

                # Chiaki-NG fixes.
                (final: prev:
                  let
                    comodoDvIntermediate = final.fetchurl {
                      url = "http://crt.comodoca.com/COMODORSADomainValidationSecureServerCA.crt";
                      hash = "sha256-AqtX5OZ6DLSN0v80gw6KxA9EdvsIymvj9c2Eb2RoQPA=";
                    };

                    chiakiCaBundle =
                      final.runCommand "chiaki-ca-bundle.crt"
                        { nativeBuildInputs = [ final.openssl ]; }
                        ''
                          cat ${final.cacert}/etc/ssl/certs/ca-bundle.crt > $out
                          openssl x509 -inform DER -in ${comodoDvIntermediate} >> $out
                        '';
                  in
                  {
                    chiaki-ng =
                      prev.chiaki-ng.overrideAttrs (old: {
                        nativeBuildInputs =
                          (old.nativeBuildInputs or [ ])
                          ++ [ final.makeWrapper ];

                        postFixup = (old.postFixup or "") + ''
                          wrapProgram "$out/bin/chiaki" \
                            --unset QT_STYLE_OVERRIDE \
                            --set SSL_CERT_FILE ${chiakiCaBundle} \
                            --set CURL_CA_BUNDLE ${chiakiCaBundle}
                        '';
                      });
                  })

                # khal.
                (final: prev: {
                  khal = prev.khal.overrideAttrs (old: {
                    outputs = [ "out" "dist" "doc" ];
                    sphinxBuilders = [ "html" ];
                  });
                })

                # HPLIP: drivers only.
                (final: prev: {
                  hplip = (prev.hplip.override { withQt5 = false; }).overrideAttrs (old: {
                    postInstall = (old.postInstall or "") + ''
                      rm -f $out/share/applications/hplip.desktop
                    '';
                  });
                })

                # udiskie.
                (final: prev: {
                  udiskie = prev.udiskie.overrideAttrs (old: {
                    doCheck = false;
                    doInstallCheck = false;
                  });
                })

                inputs.vscode-insiders.overlays.default

                # VS Code Insiders launcher name.
                (final: prev: {
                  vscode-insiders = prev.vscode-insiders.overrideAttrs (old: {
                    postFixup = (old.postFixup or "") + ''
                      sed -i 's/Visual Studio Code - Insiders/Visual Studio Code/g' \
                        $out/share/applications/*.desktop
                    '';
                  });
                })

                mac-style-plymouth.overlays.default

                # Claude Desktop.
                (final: prev: {
                  claude-desktop =
                    inputs.llm-agents.packages.${final.stdenv.hostPlatform.system}.claude-desktop.override {
                      commandLineArgs = "--password-store=gnome-libsecret";
                    };
                })

                niri-flake.overlays.niri

                # Browser overrides.
                (final: prev: {
                  ungoogled-chromium =
                    config.home-manager.users.ayaan_mirza.programs.ungoogled-chromium.extensions.wrapped;

                  helium =
                    inputs.helium.packages.${prev.stdenv.hostPlatform.system}.default;
                })

                # Papirus folder color.
                (final: prev: {
                  papirus-icon-theme = prev.papirus-icon-theme.override {
                    color = "violet";
                  };
                })
              ];
            })

            # Generation revision.
            {
              system.configurationRevision =
                self.rev or self.dirtyRev or "dirty";
            }

            # Insecure packages.
            {
              nixpkgs.config.permittedInsecurePackages = [
                "electron-41.10.7"
                "electron-39.8.10"
              ];
            }

            # onlyoffice GTK2 warning.
            {
              nixpkgs.config.problems.handlers."gtk+".broken = "warn";
            }
          ];
        };
      };
    };
}