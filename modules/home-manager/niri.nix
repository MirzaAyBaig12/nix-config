{ config, pkgs, lib, ... }:

{
  # ~/.config/niri is a symlink into this repo (nix-config/.config/niri),
  # so `dms setup` can freely read/write config.kdl and dms/*.kdl as
  # normal files (not nix-store symlinks — HM's usual xdg.configFile is
  # read-only and breaks dms's in-place rewrites), while the content still
  # lives in git for backup/version history. Content itself is untracked
  # by Nix on purpose; edit ~/nix-config/.config/niri/ directly or re-run
  # `dms setup` and commit the result.
  home.file.".config/niri".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/.config/niri";

  # dms/colors.kdl keeps getting regenerated back to light mode (DMS
  # re-derives it from the system light/dark preference on its own,
  # independent of Nix). Force it back to dark on every activation.
  home.activation.dmsColorsDark = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD sed -i \
      -e 's/5f5791/c8bfff/g' \
      -e 's/79767f/938f99/g' \
      -e 's/ba1a1a/ffb4ab/g' \
      "${config.home.homeDirectory}/nix-config/.config/niri/dms/colors.kdl"
  '';

  # Old raw-KDL block kept below for reference — the goodies here
  # (keyring spawn, custom binds, window rules) still need to get
  # hand-copied into the real ~/nix-config/.config/niri/config.kdl:
  /*
  xdg.configFile."niri/config.kdl".text = ''
    spawn-at-startup "dms" "run"
    // Clipboard history
    spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
    // GNOME Keyring — niri doesn't spawn this or wire up its env vars
    // like a full DE session does, so both are needed explicitly.
    spawn-at-startup "gnome-keyring-daemon" "--start" "--components=pkcs11,secrets,ssh"
    spawn-at-startup "dbus-update-activation-environment" "--systemd" "--all"

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
  */
}
