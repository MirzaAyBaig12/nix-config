{ config, pkgs, lib, ... }:

{
  # Empty placeholder fragments DMS writes its generated colors/layout/
  # binds into (via `dms setup`, run once after first login to niri).
  # niri's config.kdl fails to build if an `include` target doesn't
  # exist yet, so these need to be real files from the start.
  home.file = {
    ".config/niri/dms/colors.kdl".text = lib.mkDefault "";
    ".config/niri/dms/layout.kdl".text = lib.mkDefault "";
    ".config/niri/dms/alttab.kdl".text = lib.mkDefault "";
    ".config/niri/dms/binds.kdl".text = lib.mkDefault "";
  };

  # Raw KDL rather than programs.niri.settings, since DMS's `include`
  # directives aren't expressible through the Nix-native settings schema.
  programs.niri.config = ''
    spawn-at-startup "dms" "run"
    // Clipboard history
    spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"

    environment {
      XDG_CURRENT_DESKTOP "niri"
      QT_QPA_PLATFORM "wayland"
      ELECTRON_OZONE_PLATFORM_HINT "auto"
      QT_QPA_PLATFORMTHEME "gtk3"
      QT_QPA_PLATFORMTHEME_QT6 "gtk3"
    }

    layout {
      gaps 5
      background-color "transparent"
    }

    layer-rule {
      match namespace="^quickshell$"
      place-within-backdrop true
    }

    window-rule {
      match app-id=r#"^org\.gnome\."#
      draw-border-with-background false
      geometry-corner-radius 12
      clip-to-geometry true
    }

    window-rule {
      match app-id=r#"^org\.wezfurlong\.wezterm$"#
      match app-id="Alacritty"
      match app-id="com.mitchellh.ghostty"
      match app-id="kitty"
      draw-border-with-background false
    }

    window-rule {
      match is-active=false
      opacity 0.9
    }

    window-rule {
      geometry-corner-radius 12
      clip-to-geometry true
    }

    binds {
      Mod+Space hotkey-overlay-title="Application Launcher" {
        spawn "dms" "ipc" "call" "spotlight" "toggle";
      }
      Mod+V hotkey-overlay-title="Clipboard Manager" {
        spawn "dms" "ipc" "call" "clipboard" "toggle";
      }
      Mod+M hotkey-overlay-title="Task Manager" {
        spawn "dms" "ipc" "call" "processlist" "focusOrToggle";
      }
      Mod+Comma hotkey-overlay-title="Settings" {
        spawn "dms" "ipc" "call" "settings" "focusOrToggle";
      }
      Mod+N hotkey-overlay-title="Notification Center" {
        spawn "dms" "ipc" "call" "notifications" "toggle";
      }
      Mod+Y hotkey-overlay-title="Browse Wallpapers" {
        spawn "dms" "ipc" "call" "dankdash" "wallpaper";
      }
      Mod+Alt+L hotkey-overlay-title="Lock Screen" {
        spawn "dms" "ipc" "call" "lock" "lock";
      }
      XF86AudioRaiseVolume allow-when-locked=true {
        spawn "dms" "ipc" "call" "audio" "increment" "3";
      }
      XF86AudioLowerVolume allow-when-locked=true {
        spawn "dms" "ipc" "call" "audio" "decrement" "3";
      }
      XF86AudioMute allow-when-locked=true {
        spawn "dms" "ipc" "call" "audio" "mute";
      }
      XF86MonBrightnessUp allow-when-locked=true {
        spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
      }
      XF86MonBrightnessDown allow-when-locked=true {
        spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
      }

      // Core window/workspace management — niri ships with none of this
      // bound by default when using raw programs.niri.config.
      Mod+Q { close-window; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+Left  { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Down  { focus-workspace-down; }
      Mod+Up    { focus-workspace-up; }
      Mod+Shift+Left  { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Down  { move-window-to-workspace-down; }
      Mod+Shift+Up    { move-window-to-workspace-up; }
      Mod+Return { spawn "ghostty"; }
      Mod+Shift+E { quit; }
    }

    include "dms/colors.kdl"
    include "dms/layout.kdl"
    include "dms/alttab.kdl"
    include "dms/binds.kdl"
  '';
}
