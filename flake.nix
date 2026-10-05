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

    # 2. NixOS module for declaratively installing and managing Flatpak apps.
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # 3. Theming module for NixOS and Home Manager.
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # 4. Package and integration for the Claude Desktop client.
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

    # 7. NixOS configuration editor (declared here; no use found in the current config).
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";

    # 8. iLoader application package.
    iloader.url = "github:nab138/iloader";
    
    # 9. Home Manager modules for declarative user environment configuration.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 10. Secure Boot support and bootloader integration for NixOS.
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 11. CLI coding agents, including Codex, Claude Code, and OpenCode.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # 12. DankSearch Home Manager module for file search.
    danksearch.url = "github:AvengeMedia/danksearch";
    danksearch.inputs.nixpkgs.follows = "nixpkgs";

    # 13. DankGreeter login manager module. Use this flake's module rather than nixpkgs' vendored one:
    # cuz nixpkgs' version left /var/lib/dms-greeter owned by nobody:nogroup instead
    # of the dms-greeter user, which crash looped the greeter on "permission denied"
    # extracting the embedded UI. the flake's module doesnt have that problem
    dank-greeter.url = "github:AvengeMedia/dank-greeter";
    dank-greeter.inputs.nixpkgs.follows = "nixpkgs";

    # 14. DankMaterialShell desktop shell and NixOS module. Use this flake's module rather than nixpkgs'
    # vendored one, same reason as dank-greeter above
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 15. dgop system monitoring utility (declared here; no use found in the current config).
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 16. Home Manager module for monitoring Nix builds and system activity.
    nix-monitor.url = "github:antonjah/nix-monitor";

    # 17. Free Download Manager package.
    fdm-nix.url = "github:QaisAlsaid/fdm-nix";

    # 18. Browser config.js files used by Natsumi and LibreWolf; update with: nix flake update fx-autoconfig
    fx-autoconfig = {
      url = "github:MrOtherGuy/fx-autoconfig";
      flake = false;
    };

    # 19. Local Natsumi browser-theme module; combines fx-autoconfig with the theme for the selected browser.
    natsumi = {
      url = "path:./flakes/natsumi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 20. Larger VS Code extension collection from the Marketplace and Open VSX.
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 21. Catppuccin theme modules for NixOS and Home Manager.
    catppuccin.url = "github:catppuccin/nix";

    # 22. Pinned Catppuccin GTK theme source used to build the local GTK theme package; pin independently of the
    # machine-local clone and fetch it as a plain source tree (not a flake).
    catppuccinGtkTheme = {
      url = "github:Fausto-Korpsvart/Catppuccin-GTK-Theme/a0f69cc33299dc97267c3507fe8a001aecc46b0f";
      flake = false;
    };

    # 23. Home Manager module for configuring Vencord in Discord clients.
    nixcord.url = "github:4evy/nixcord";

    # 24. Blip desktop shell module.
    blip.url = "github:blip-net/nix";

    # 25. Containerpak NixOS module for managing containerized applications.
    cpak.url = "github:Containerpak/cpak/v2";

    # 26. ChatGPT Desktop package.
    chatgpt-desktop.url = "github:alioguzhan/chatgpt-desktop-flake";

    # 27. Helium browser package.
    helium.url = "github:amaanq/helium-flake";

    # 28. Brave Orgin Flake.
    brave-origin.url = "github:tekq/brave-origin-flake";

    # 29. My Personal flake of External AppImages
    nix-ext-packages.url = "github:MirzaAyBaig12/nix-ext-packages";
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
            # Main configuration
            ./configuration.nix

            {
              nixpkgs = {
                hostPlatform = "x86_64-linux";
                config.allowUnfree = true;
              };
            }

            # Declarative Flatpak
            nix-flatpak.nixosModules.nix-flatpak

            # Stylix
            inputs.stylix.nixosModules.stylix

            # Lanzaboote
            inputs.lanzaboote.nixosModules.lanzaboote

            # DankGreeter
            inputs.dank-greeter.nixosModules.default

            # DankMaterialShell
            inputs.dms.nixosModules.dank-material-shell

            # Home Manager integration
            inputs.home-manager.nixosModules.default

            # Plymouth overlay
            {
              nixpkgs.overlays = [
                (final: prev: {inherit (prev.lixPackageSets.stable)
                nixpkgs-review nix-eval-jobs nix-fast-build colmena;})
                (final: prev: {
                  # Round the Catppuccin theme in place while retaining its upstream
                  # theme name, files, palette, and Catppuccin module selection.
                  catppuccin-kvantum = prev.catppuccin-kvantum.overrideAttrs (old: {
                    postInstall = (old.postInstall or "") + ''
                      for config in "$out"/share/Kvantum/catppuccin-*/*.kvconfig; do
                        sed -i '/^\[PanelButtonCommand\]$/a frame.expansion=16' "$config"
                        sed -i '/^\[Menu\]$/a frame.expansion=16' "$config"
                      done
                    '';
                  });
                })
                mac-style-plymouth.overlays.default
                claude-desktop.overlays.default
              ];
            }

            # Generation revision
            {
              system.configurationRevision = self.rev or self.dirtyRev or "dirty";
            }

            # Insecure packages
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
