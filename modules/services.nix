{ config, pkgs, ... }:

{

  # Snap & Flatpak (declarative — see flatpak.nix)
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

  # CUPS printing — using hplip drivers only (hp-* GUI utilities are
  # broken on python3.14, see hplip URLopener issue; CUPS web UI at
  # localhost:631 doesn't depend on those scripts, drivers still work)
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enables scanning support (also uses hplip's sane backend)
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Printer/scanner discovery on the local network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
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

  # Watches for Flatpaks installed outside of Nix (e.g. via Bazaar) and
  # appends them into flatpak.nix, correctly formatted for flathub vs cosmic.
  # Script itself is defined in flatpak.nix (options.custom.flatpakSyncScript).
  # Systemd user service to execute the sync script
  systemd.user.services.flatpak-app-sync = {
    description = "Periodic sync for unmanaged Flatpaks into flatpak.nix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.custom.flatpakSyncScript}/bin/sync-flatpak-apps";
    };
  };

  systemd.user.timers.flatpak-app-sync = {
    description = "Timer to run Flatpak sync every 5 seconds";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "5min";
      # You can safely delete the 'Unit =' line since it matches the timer name, 
      # or change it to: Unit = "flatpak-app-sync.service";
    };
  };

}
