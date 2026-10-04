# Flatpak sandboxes can't follow /nix/store symlinks, so home-manager's
# symlinked ~/.config/gtk-{3,4}.0 files show up as dangling inside them and
# every flatpak falls back to stock Adwaita. These files are written as REAL
# files at activation instead, and the Catppuccin theme is copied next to them
# (also as real files) so nothing points back into the store.[cite: 1]
{ config, lib, pkgs, ... }:

let
  themeName = "Catppuccin-Mauve-Dark";
  themeSrc = "${config.gtk.theme.package}/share/themes/${themeName}";

  # Package the Python recoloring script cleanly into the Nix store
  rotateBlueScript = pkgs.writers.writePython3 "rotate-blue.py" { } ''
    import colorsys, re, sys

    MAUVE = (203, 166, 247)  # #cba6f7
    BASE = (30, 30, 46)      # #1e1e2e

    def rotate(r, g, b):
        h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        if not (200 <= h * 360 <= 262 and s >= 0.35 and 0.10 < l < 0.97):
            return None
        t = min(1.0, max(0.0, (l - 0.15) / (0.75 - 0.15)))
        return tuple(round(BASE[i] * (1 - t) + MAUVE[i] * t) for i in range(3))

    def hex_sub(m):
        v = m.group(1)
        out = rotate(*(int(v[i:i + 2], 16) for i in (0, 2, 4)))
        return m.group(0) if out is None else "#%02x%02x%02x" % out

    def rgb_sub(m):
        r, g, b = int(m.group(2)), int(m.group(3)), int(m.group(4))
        out = rotate(r, g, b)
        if out is None:
            return m.group(0)
        tail = m.group(5) or ""
        return "%s(%d, %d, %d%s)" % (m.group(1), *out, tail)

    EXACT = (
        ("#89b4fa", "#cba6f7"),
        ("rgba(137, 180, 250,", "rgba(203, 166, 247,"),
        ("rgba(110, 143, 199, 0.961)", "rgba(162, 133, 198, 0.961)"),
    )

    def process(text):
        for a, b in EXACT:
            text = re.sub(re.escape(a), b, text, flags=re.I)
        text = re.sub(r"#([0-9a-fA-F]{6})\b", hex_sub, text)
        text = re.sub(
            r"(rgba?)\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(,\s*[\d.]+\s*)?\)",
            rgb_sub, text)
        return text

    if __name__ == "__main__":
        for path in sys.argv[1:]:
            with open(path) as f:
                old = f.read()
            new = process(old)
            if new != old:
                with open(path, "w") as f:
                    f.write(new)
  '';

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
  # stop home-manager from symlinking these; the activation script owns them[cite: 1]
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

      # libadwaita: theme css imported relatively from gtk.css[cite: 1]
      rm -rf "$cfg/gtk-4.0/catppuccin"
      mkdir -p "$cfg/gtk-4.0/catppuccin"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-4.0/. "$cfg/gtk-4.0/catppuccin/"

      # GTK3 flatpaks: theme must live in xdg-data/themes (exposed by the flatpak override)[cite: 1]
      rm -rf "$theme"
      mkdir -p "$theme"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-3.0 ${themeSrc}/gtk-4.0 ${themeSrc}/index.theme "$theme/"

      chmod -R u+w "$cfg/gtk-4.0/catppuccin" "$theme"

      # Run the Python script to recolor blue accents to mauve in all copied CSS files
      find "$cfg/gtk-4.0/catppuccin" "$theme" -type f -name "*.css" -exec ${rotateBlueScript} {} +
    fi
  '';
}