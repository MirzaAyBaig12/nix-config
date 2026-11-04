{ ... }:
{
  programs.niri.settings = {
    layer-rules = [
      { matches = [ { namespace = "^quickshell$"; } ]; place-within-backdrop = true; }
    ];

    window-rules = [
      { matches = [ { app-id = "^org\\.wezfurlong\\.wezterm$"; } ]; default-column-width = { }; }
      { opacity = 0.90; background-effect = { blur = true; xray = true; }; }
      {
        matches = map (app-id: { inherit app-id; }) [
          "mpv" "vlc" "hydralauncher" "org.kde.kdenlive" "com.obsproject.Studio"
          "^steam_app_" "steam" "chiaki-ng" "firefox" "librewolf" "zen"
          "helium" "^chrome-.*__-Default$" "chromium-browser" "org.chromium.Chromium"
        ];
        opacity = 1.0;
        background-effect.blur = false;
      }
      {
        matches = [ { app-id = "^org\\.gnome\\."; } ];
        draw-border-with-background = false;
        geometry-corner-radius = 12.0;
        clip-to-geometry = true;
      }
      {
        matches = map (app-id: { inherit app-id; }) [ "^gnome-control-center$" "^pavucontrol$" "^nm-connection-editor$" ];
        default-column-width = { proportion = 0.5; };
        open-floating = false;
      }
      {
        matches = map (app-id: { inherit app-id; }) [ "^org\\.gnome\\.Calculator$" "^gnome-calculator$" "^galculator$" "^blueman-manager$" "^xdg-desktop-portal$" ];
        open-floating = true;
      }
      {
        matches = [ { app-id = "^steam$"; title = "^notificationtoasts_\\d+_desktop$"; } ];
        default-floating-position = { x = 10; y = 10; relative-to = "bottom-right"; };
        open-focused = false;
      }
      {
        matches = map (app-id: { inherit app-id; }) [ "^org\\.wezfurlong\\.wezterm$" "Alacritty" "zen" "com.mitchellh.ghostty" "kitty" ];
        draw-border-with-background = false;
      }
      { matches = [ { app-id = "firefox$"; title = "^Picture-in-Picture$"; } { app-id = "zoom"; } ]; open-floating = true; }

      # DMS-managed defaults, declared here with the rest of Niri's settings.
      { geometry-corner-radius = 16.0; clip-to-geometry = true; tiled-state = true; draw-border-with-background = false; }
      { matches = [ { app-id = "^openscreen$"; } ]; border.enable = false; focus-ring.enable = false; }
      { matches = [ { app-id = "^hydralauncher$"; } ]; open-maximized = true; }
      { matches = [ { app-id = "^chiaki-ng$"; } ]; open-maximized = true; }
      { matches = [ { app-id = "^(dev\\.duxlabs\\.shell|com\\.danklinux\\.dms)$"; } ]; opacity = 1.00; }
      { matches = [ { app-id = "^dev\\.duxlabs\\.files$"; title = "^(Open|Save|Select|Upload|Export|Import)"; } ]; open-floating = true; }
    ];
  };
}
