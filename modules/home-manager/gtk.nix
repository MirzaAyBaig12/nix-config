{ pkgs, ... }:

let
  bibata-material-cursor = pkgs.callPackage ../../packages/bibata-material-cursor.nix { };
in
{
  # Bibata-Material-Slate here is Ayaan's own fork, packaged from the pinned
  # GitHub release tarball at ../../packages/bibata-material-cursor.nix —
  # NOT the nixpkgs `bibata-cursors` package (that's upstream ful1e5's repo
  # and has no Material/Slate variant).
  #
  # home.pointerCursor now owns and symlinks the theme itself (replaces the
  # old manual ~/.icons/Bibata-Material-Slate + ~/.icons/default install),
  # AND sets Xcursor.theme/size via Xresources — the mechanism X11/XWayland
  # Xlib-based toolkits (Java AWT/Swing included) read via XGetDefault,
  # independent of GTK/dconf.
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Material-Slate";
    package = bibata-material-cursor;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;

    # Stock Adwaita for GTK2/3 — libadwaita (GTK4) ignores this and
    # renders its own built-in style regardless, so no GTK4 theme
    # package is needed here at all.
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # iconTheme intentionally NOT set here — now managed by Stylix
    # (modules/stylix.nix, stylix.icons.*) to avoid double-declaring
    # gtk.iconTheme from two places.

    cursorTheme = {
      name = "Bibata-Material-Slate";
      package = bibata-material-cursor;
      size = 24;
    };

    font = {
      name = "Noto Sans";
      size = 10;
    };
  };

  # GTK2 extra configuration
  gtk.gtk2.extraConfig = ''
    gtk-theme-name="Adwaita-dark"
    gtk-icon-theme-name="Adwaita"
    gtk-cursor-theme-name="Bibata-Material-Slate"
    gtk-cursor-theme-size=24
    gtk-font-name="Noto Sans 10"
  '';

  # GTK3 configuration
  gtk.gtk3.extraConfig = {
    gtk-application-prefer-dark-theme = true;
  };

}
