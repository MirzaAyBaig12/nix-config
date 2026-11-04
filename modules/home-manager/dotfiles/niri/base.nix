{ ... }:
{
  programs.niri.settings = {
    config-notification.disable-failed = true;
    environment.XDG_CURRENT_DESKTOP = "niri";
    hotkey-overlay.skip-at-startup = true;
    prefer-no-csd = true;
    screenshot.path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
    debug.honor-xdg-activation-with-invalid-serial = [ ];

    animations = {
      workspace-switch.kind.spring = {
        damping-ratio = 0.80; stiffness = 523; epsilon = 0.0001;
      };
      window-open.kind.easing = { duration-ms = 150; curve = "ease-out-expo"; };
      window-close.kind.easing = { duration-ms = 150; curve = "ease-out-quad"; };
      horizontal-view-movement.kind.spring = {
        damping-ratio = 0.85; stiffness = 423; epsilon = 0.0001;
      };
      window-movement.kind.spring = {
        damping-ratio = 0.75; stiffness = 323; epsilon = 0.0001;
      };
      window-resize.kind.spring = {
        damping-ratio = 0.85; stiffness = 423; epsilon = 0.0001;
      };
      config-notification-open-close.kind.spring = {
        damping-ratio = 0.65; stiffness = 923; epsilon = 0.001;
      };
      screenshot-ui-open.kind.easing = { duration-ms = 200; curve = "ease-out-quad"; };
      overview-open-close.kind.spring = {
        damping-ratio = 0.85; stiffness = 800; epsilon = 0.0001;
      };
    };

    overview.workspace-shadow.enable = false;
    recent-windows = {
      binds = {
        "Alt+Tab".action.next-window = { scope = "output"; };
        "Alt+Shift+Tab".action.previous-window = { scope = "output"; };
        "Alt+grave".action.next-window = { filter = "app-id"; };
        "Alt+Shift+grave".action.previous-window = { filter = "app-id"; };
      };
      highlight = {
        corner-radius = 16;
        active-color = "#55307f";
        urgent-color = "#f38ba8";
      };
    };
  };
}
