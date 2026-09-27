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
    # 1. Core NixOS package repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 2. Third-party Snap support for NixOS
    nix-snapd.url = "github:nix-community/nix-snapd";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

    # 4. Declarative Flatpak support
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # 5. Codex Desktop
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";

    # 6. Claude Desktop
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

    # 11. iLoader
    iloader.url = "github:nab138/iloader";

    # 12. Look Launcher
    look.url = "github:kunkka19xx/look?dir=apps/linows";

    # 13. Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 14. Lanzaboote
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 16. Stylix
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # 17. LLM Agents
    llm-agents.url = "github:numtide/llm-agents.nix";

    # 18. niri
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 20. DankSearch
    danksearch.url = "github:AvengeMedia/danksearch";
    danksearch.inputs.nixpkgs.follows = "nixpkgs";

    # 21. DankGreeter. back on the flake's own module instead of nixpkgs' vendored one
    # cuz nixpkgs' version left /var/lib/dms-greeter owned by nobody:nogroup instead
    # of the dms-greeter user, which crash looped the greeter on "permission denied"
    # extracting the embedded UI. the flake's module doesnt have that problem
    dank-greeter.url = "github:AvengeMedia/dank-greeter";
    dank-greeter.inputs.nixpkgs.follows = "nixpkgs";

    # 21b. DankMaterialShell. back on the flake's own module instead of nixpkgs'
    # vendored one, same reason as dank-greeter above
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 22. dgop
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 23. nix-monitor
    nix-monitor.url = "github:antonjah/nix-monitor";

    # 24. Pinned nixpkgs for xwayland-satellite 0.8.1
    nixpkgs-xwayland-satellite-0-8-1.url = "github:nixos/nixpkgs/edfd59b795cd752c36d2dae60870cffcd23d3fb1";

    # 25. Free Download Manager
    nix-fdm.url = "github:j-a-sunny/nix-FDM";

    # 26. fx-autoconfig (config.js for librewolf userChrome.js/natsumi), update with: nix flake update fx-autoconfig
    fx-autoconfig = {
      url = "github:MrOtherGuy/fx-autoconfig";
      flake = false;
    };

    # 27. natsumi (programs.natsumi module: fx-autoconfig + Natsumi theme
    # for a picked browser -- Floorp for now). Local for now, at
    # flakes/natsumi/; swap the url for a git remote once pushed.
    natsumi = {
      url = "path:./flakes/natsumi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dank-calendar = {
      url = "github:AvengeMedia/dankcalendar";
    };

    # 27. VS Code extensions from the Marketplace + Open VSX (nixpkgs only has a handful)
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #28. Catppuccin Flake for VS Code
    catppuccin.url = "github:catppuccin/nix";

    nixcord.url = "github:4evy/nixcord";

    xwayland-satellite.url = "github:Supreeeme/xwayland-satellite";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-snapd,
      nix-flatpak,
      cosmic-manager,
      codex-desktop-linux,
      claude-desktop,
      mac-style-plymouth,
      winpodx,
      home-manager,
      llm-agents,
      catppuccin,
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
              nixpkgs.hostPlatform = "x86_64-linux";
            }

            # Snap support
            nix-snapd.nixosModules.default

            # Codex Desktop
            codex-desktop-linux.nixosModules.default

            # Declarative Flatpak
            nix-flatpak.nixosModules.nix-flatpak

            # Lanzaboote
            inputs.lanzaboote.nixosModules.lanzaboote

            # Stylix
            inputs.stylix.nixosModules.stylix

            # DankGreeter
            inputs.dank-greeter.nixosModules.default

            # DankMaterialShell
            inputs.dms.nixosModules.dank-material-shell

            # Snap service
            {
              services.snap.enable = false;
            }

            # Plymouth overlay
            {
              nixpkgs.overlays = [
                mac-style-plymouth.overlays.default
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
