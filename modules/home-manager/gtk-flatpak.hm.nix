# Flatpak sandboxes can't follow /nix/store symlinks, so home-manager's
# symlinked ~/.config/gtk-{3,4}.0 files show up as dangling inside them and
# every flatpak falls back to stock Adwaita. These files are written as REAL
# files at activation instead, and the Catppuccin theme is copied next to them
# (also as real files) so nothing points back into the store.
{ config, lib, pkgs, ... }:

let
  themeName = "Catppuccin-Mauve-Dark";
  themeSrc = "${config.gtk.theme.package}/share/themes/${themeName}";

  gtk4Css = pkgs.writeText "gtk4.css" ''
    /* real file, not a store symlink, so flatpak sandboxes can read it */
    @import url("catppuccin/gtk.css");
    ${config.gtk.gtk4.extraCss}
  '';

  settingsIni = pkgs.writeText "settings.ini" ''
    [Settings]
    gtk-cursor-theme-name=${config.gtk.cursorTheme.name}
    gtk-cursor-theme-size=${toString config.gtk.cursorTheme.size}
    gtk-decoration-layout=:
    gtk-icon-theme-name=${config.gtk.iconTheme.name}
    gtk-theme-name=${themeName}
  '';
in
{
  # stop home-manager from symlinking these; the activation script owns them
  xdg.configFile."gtk-4.0/gtk.css".enable = lib.mkForce false;
  xdg.configFile."gtk-4.0/settings.ini".enable = lib.mkForce false;
  xdg.configFile."gtk-3.0/settings.ini".enable = lib.mkForce false;

  home.activation.flatpakGtkRealFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [[ ! -v DRY_RUN ]]; then
      cfg="$HOME/.config"
      theme="$HOME/.local/share/themes/${themeName}"
      mkdir -p "$cfg/gtk-3.0" "$cfg/gtk-4.0" "$HOME/.local/share/themes"

      rm -f "$cfg/gtk-4.0/gtk.css" "$cfg/gtk-4.0/settings.ini" "$cfg/gtk-3.0/settings.ini"
      install -m644 ${gtk4Css} "$cfg/gtk-4.0/gtk.css"
      install -m644 ${settingsIni} "$cfg/gtk-4.0/settings.ini"
      install -m644 ${settingsIni} "$cfg/gtk-3.0/settings.ini"

      # libadwaita: theme css imported relatively from gtk.css
      rm -rf "$cfg/gtk-4.0/catppuccin"
      mkdir -p "$cfg/gtk-4.0/catppuccin"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-4.0/. "$cfg/gtk-4.0/catppuccin/"

      # GTK3 flatpaks: theme must live in xdg-data/themes (exposed by the flatpak override)
      rm -rf "$theme"
      mkdir -p "$theme"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-3.0 ${themeSrc}/gtk-4.0 ${themeSrc}/index.theme "$theme/"

      chmod -R u+w "$cfg/gtk-4.0/catppuccin" "$theme"
    fi
  '';
}
