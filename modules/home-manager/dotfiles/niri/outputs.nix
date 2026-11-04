{ ... }:
{
  programs.niri.settings.outputs = {
    "eDP-1" = {
      mode = { width = 1920; height = 1080; refresh = 60.038; };
      scale = 1;
      position = { x = 0; y = 0; };
      variable-refresh-rate = "on-demand";
    };
    "DP-1" = {
      mode = { width = 1920; height = 1080; refresh = 60.000; };
      scale = 1;
      position = { x = 1920; y = 0; };
    };
  };
  programs.niri.settings.gestures.hot-corners = {
    top-left = false;
    top-right = false;
    bottom-left = false;
    bottom-right = false;
  };
  programs.niri.settings.cursor = {
    theme = "Bibata-Material-Lilac";
    size = 30;
    hide-after-inactive-ms = 2500;
  };
}
