{ ... }:
{
  programs.niri.settings = {
    layout = {
      background-color = "transparent";
      gaps = 8;
      center-focused-column = "never";
      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];
      default-column-width = { proportion = 0.5; };
      border = {
        enable = false;
        width = 2;
        active = { color = "#cba6f7"; };
        inactive = { color = "#6c7086"; };
        urgent = { color = "#f38ba8"; };
      };
      focus-ring = {
        enable = true;
        width = 2;
        active = { color = "#cba6f7"; };
        inactive = { color = "#6c7086"; };
        urgent = { color = "#f38ba8"; };
      };
      shadow = {
        enable = true;
        softness = 30;
        spread = 5;
        offset = { x = 0; y = 5; };
        color = "#00000070";
      };
      tab-indicator = {
        active = { color = "#cba6f7"; };
        inactive = { color = "#6c7086"; };
        urgent = { color = "#f38ba8"; };
      };
      insert-hint.display = { color = "#cba6f780"; };
    };
    blur = { passes = 3; offset = 2.5; };
  };
}
