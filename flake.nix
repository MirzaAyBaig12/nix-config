
{
  description = "Комиссар Блятников's Nix Flake";

  nixConfig = {
    extra-substituters = [ 
      "https://look.cachix.org"
      "https://cache.lix.systems"
    ];
    extra-trusted-public-keys = [
      "look.cachix.org-1:8elPCeSVBzlDZXqIRKBK9GyLIK/Hoe1xiWZF0ir7uX4="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
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
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    # Lix source the module builds. Without this the module uses its own stale pin (2.94-pre).
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix?ref=refs/tags/2.96.0";
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

    # Pinned Catppuccin GTK theme source.
    catppuccinGtkTheme = {
      url = "github:Fausto-Korpsvart/Catppuccin-GTK-Theme/a0f69cc33299dc97267c3507fe8a001aecc46b0f";
      flake = false;
    };

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
    helium.url = "github:amaanq/helium-flake";

    # VS Code Insiders (installed alongside stable vscode).
    code-insiders.url = "github:iosmanthus/code-insiders-flake";

    # Free Download Manager.
    fdm-nix.url = "github:QaisAlsaid/fdm-nix";

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
                "electron-41.10.7"
              ];
            }
          ];
        };
      };
    };
}
