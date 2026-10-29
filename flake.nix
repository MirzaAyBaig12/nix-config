{
  description = "Комиссар Блятников's Nix Flake";

  nixConfig = {
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
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Catppuccin theme modules.
    catppuccin.url = "github:catppuccin/nix";

    # Dux Shell (formerly DankMaterialShell), stable branch.
    dux-shell = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dux Greeter (formerly DankGreeter), stable 2.0 branch.
    dux-greeter = {
      url = "github:duxlabs-dev/dux-greeter/stable-2.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dux Search (formerly DankSearch).
    dux-search = {
      url = "github:duxlabs-dev/dux-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dux GOP (formerly dgop), system resources API & CLI.
    dux-gop = {
      url = "github:duxlabs-dev/dux-gop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dux plugin registry (formerly dms-plugin-registry), declarative DMS extensions source
    dux-plugin-registry = {
      url = "github:duxlabs-dev/dux-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    # WinPodX: Windows Pod Subsystem
    winpodx = {
      url = "github:kernalix7/winpodx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Containerpak module.
    cpak.url = "github:Containerpak/cpak/v2";

    # niri via epireyn's niri-flake fork (sodiboo's stopped updating its niri pin in Aug 2026,
    # this one is kept up to date): niri-unstable tracks niri-wm/niri main, cache is
    # niri-epireyn.cachix.org.
    # nixos module is imported below, overlay adds pkgs.niri-unstable.
    niri-flake = {
      url = "github:epireyn/niri-flake";
    };

    # Claude Desktop client.
    claude-desktop = {
      url = "github:nmcbride/claude-desktop-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    lumine-capture.url = "github:Netflate/LumineCapture";

    ghostty-flake.url = "github:ghostty-org/ghostty";

  };

  outputs =
    {
      self,
      nixpkgs,
      lix-module,
      lanzaboote,
      nix-flatpak,
      claude-desktop,
      mac-style-plymouth,
      stylix,
      catppuccin,
      dux-shell,
      dux-greeter,
      dux-search,
      dux-plugin-registry,
      home-manager,
      nixcord,
      blip,
      nix-ext-packages,
      cpak,
      niri-flake,
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
            
            #Import nixosModules

              #Lix Module & Overlay
              lix-module.nixosModules.default

              #Declarative Flatpak Management
              nix-flatpak.nixosModules.nix-flatpak

              #Claude Desktop (+ Cowork FHS paths / kvm)
              claude-desktop.nixosModules.default

              #System Theme Management
              stylix.nixosModules.stylix
              catppuccin.nixosModules.catppuccin

              #Bootloader
              lanzaboote.nixosModules.lanzaboote

              #Dux Suite
              dux-shell.nixosModules.dank-material-shell
              dux-greeter.nixosModules.default
              dux-plugin-registry.nixosModules.default

              #Blip (File Transfer)
              blip.nixosModules.default

              #nix-ext-packages (Custom Packages on my repo)
              nix-ext-packages.nixosModules.natsumi

              #containerpak
              cpak.nixosModules.default

              #niri (niri-flake: niri-unstable + binary cache)
              niri-flake.nixosModules.niri
            
            #Import Home-Manager
            home-manager.nixosModules.default
            {
            home-manager.sharedModules = [
              # Home Manager Module Imports
              dux-search.homeModules.dsearch
              nixcord.homeModules.nixcord
              catppuccin.homeModules.catppuccin
              nix-ext-packages.homeManagerModules.browser-extensions
              ];
            }

            # Package overlays.
            ({ config, ... }: {
              nixpkgs.overlays = [

                # Round the Catppuccin theme while preserving its upstream
                # theme name, files, palette, and module selection.
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
                (final: prev: {
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
                })

                # khal (pulled in by DMS calendar events): the man output
                # is never built (sphinx-hook only runs the html builder),
                # so the derivation fails. Drop the man output until
                # nixpkgs fixes it. "dist" must stay: the python hooks
                # expect it, and omitting it breaks pythonOutputDistPhase.
                (final: prev: {
                  khal = prev.khal.overrideAttrs (old: {
                    outputs = [ "out" "dist" "doc" ];
                    sphinxBuilders = [ "html" ];
                  });
                })

                # hplip: drivers only (no Qt GUI), keeps the build small and avoids the wrapper breakage.
                # Also drop the hplip.desktop launcher, since it points at the removed GUI.
                (final: prev: {
                  hplip = (prev.hplip.override { withQt5 = false; }).overrideAttrs (old: {
                    postInstall = (old.postInstall or "") + ''
                      rm -f $out/share/applications/hplip.desktop
                    '';
                  });
                })

                # udiskie: its keyutils test needs the kernel keyring, which the
                # build sandbox doesn't provide, so the test suite fails. Skip tests.
                (final: prev: {
                  udiskie = prev.udiskie.overrideAttrs (old: {
                    doCheck = false;
                    doInstallCheck = false;
                  });
                })

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
                niri-flake.overlays.niri
                # pkgs.browser-ext-sync (declarative Web Store extensions).
                inputs.nix-ext-packages.overlays.default

                # Material Design 3 bibata cursors (SakibShahariar/material-bibata-cursor).
                (final: prev: {
                  bibata-material-cursor =
                    inputs.nix-ext-packages.packages.${final.stdenv.hostPlatform.system}.bibata-material-cursor;
                  ungoogled-chromium = 
                    config.home-manager.users.ayaan_mirza.programs.ungoogled-chromium.extensions.wrapped;
                  helium = 
                    inputs.helium.packages.${prev.stdenv.hostPlatform.system}.default;
                  ghostty = 
                    inputs.ghostty-flake.packages.${prev.stdenv.hostPlatform.system}.default;                  
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
          ];
        };
      };
    };
}