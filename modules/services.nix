{ config, pkgs, ... }:

{
  # Snap & Flatpak
  services.snap.enable = false;
  services.flatpak.enable = true;


  # Security & Privileges (Doas & Sudo)
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "ayaan_mirza" ];
    keepEnv = true;
    persist = true;
  }];

  security.sudo.enable = true;

  security.apparmor.enable = true; #Enable AppArmor for Snap confinement

  # User Account
  users.users."ayaan_mirza" = {
    isNormalUser = true;
    description = "Ayaan Mirza";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  #Enable USBMUXD for iOS device management
  services.usbmuxd.enable = true;
 
  # 1. Repo -> Boot (Pushes your git changes to the EFI partition on every nixos-rebuild)
  system.activationScripts.syncRefindToBoot = ''
    if [ -d /boot/EFI/refind ] && [ -d /home/ayaan_mirza/nix-config/dotfiles/refind ]; then
      cp -rf /home/ayaan_mirza/nix-config/dotfiles/refind/* /boot/EFI/refind/
    fi
  '';

  # 2. Boot -> Repo (Pushes live changes made in EFI to your git repo on startup)
  systemd.services.syncRefindToRepo = {
    description = "Sync manual rEFInd changes back to dotfiles repo";
    wantedBy = [ "multi-user.target" ];
    script = ''
      REFIND_ESP="/boot/EFI/refind"
      REFIND_REPO="/home/ayaan_mirza/nix-config/.config/refind/"

      if [ -d "$REFIND_ESP" ] && [ -d "$REFIND_REPO" ]; then
        # Copy newer files from ESP back to the repo
        cp -ru "$REFIND_ESP"/* "$REFIND_REPO"/
        chown -R ayaan_mirza:users "$REFIND_REPO"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # Graphical background daemons & watchdogs
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.fcc-server = {
    description = "FCC Server Background Daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "%h/.local/bin/fcc-server";
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.user.services.cosmic-osd-watcher = {
    description = "Watchdog for cosmic-osd";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "watch-cosmic-osd" ''
        while true; do
            if ! pgrep -x "cosmic-osd" > /dev/null; then
                pkill cosmic-osd || true
            fi
            sleep 1
        done
      '';
      Restart = "always";
      RestartSec = "1s";
    };
  };

  "nix.enableLanguageServer": true,
  "nix.serverPath": "nil", // or "nixd", or ["executable", "argument1", ...]
  // LSP config can be passed via the ``nix.serverSettings.{lsp}`` as shown below.
  "nix.serverSettings": {
    // check https://github.com/oxalica/nil/blob/main/docs/configuration.md for all options available
    "nil": {
      // "diagnostics": {
      //  "ignored": ["unused_binding", "unused_with"],
      // },
      "formatting": {
        "command": ["nixfmt"],
      },
    },
    // check https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md for all nixd config
    "nixd": {
      "formatting": {
        "command": ["nixfmt"],
      },
      "options": {
        // By default, this entry will be read from `import <nixpkgs> { }`.
        // You can write arbitrary Nix expressions here, to produce valid "options" declaration result.
        // Tip: for flake-based configuration, utilize `builtins.getFlake`
        "nixos": {
          "expr": "(builtins.getFlake \"/absolute/path/to/flake\").nixosConfigurations.<name>.options",
        },
        "home-manager": {
          "expr": "(builtins.getFlake \"/absolute/path/to/flake\").homeConfigurations.<name>.options",
        },
        // Tip: use ${workspaceFolder} variable to define path
        "nix-darwin": {
          "expr": "(builtins.getFlake \"${workspaceFolder}/path/to/flake\").darwinConfigurations.<name>.options",
        },
      },
    }
}