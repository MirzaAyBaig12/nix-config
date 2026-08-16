{ config, pkgs, ... }:

{
  # Ensure the systemd user daemon is enabled in Home Manager
  systemd.user.services = {
    polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        WantedBy = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    fcc-server = {
      Unit = {
        Description = "FCC Server Background Daemon";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "%h/.local/bin/fcc-server";
        Restart = "always";
        RestartSec = 5;
      };
    };

    cosmic-osd-watcher = {
      Unit = {
        Description = "Watchdog for cosmic-osd";
        PartOf = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = toString (pkgs.writeShellScript "watch-cosmic-osd" ''
          while true; do
              if ! pgrep -x "cosmic-osd" > /dev/null; then
                  pkill cosmic-osd || true
              fi
              sleep 1
          done
        '');
        Restart = "always";
        RestartSec = "1s";
      };
    };
  };
}