{ pkgs, src }:

let
  # gtk-engine-murrine was removed from current nixpkgs because GTK 2 is
  # deprecated. Catppuccin's GTK 2 theme still uses it, so build the upstream
  # engine against nixpkgs' GTK 2 library for this theme's runtime profile.
  gtkEngineMurrine = pkgs.stdenv.mkDerivation {
    pname = "gtk-engine-murrine";
    version = "0.98.2";

    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/gtk-engine-murrine/0.98/gtk-engine-murrine-0.98.2.tar.xz";
      sha256 = "129cs5bqw23i76h3nmc29c9mqkm9460iwc8vkl7hs4xr07h8mip9";
    };

    nativeBuildInputs = [ pkgs.pkg-config pkgs.intltool ];
    buildInputs = [ pkgs.gtk2 ];

    patches = [ (pkgs.writeText "murrine-missing-prototypes.diff" ''
      diff --git a/src/murrine_rc_style.h b/src/murrine_rc_style.h
      --- a/src/murrine_rc_style.h
      +++ b/src/murrine_rc_style.h
      @@ -154,1 +154,2 @@
       GType murrine_rc_style_get_type (void);
      +void murrine_rc_style_register_types (GTypeModule *module);
      diff --git a/src/murrine_style.h b/src/murrine_style.h
      --- a/src/murrine_style.h
      +++ b/src/murrine_style.h
      @@ -102,5 +102,6 @@ struct _MurrineStyleClass
       };
      
       GType murrine_style_get_type (void);
      +void murrine_style_register_types (GTypeModule *module);
      
       #endif /* MURRINE_STYLE_H */
      diff --git a/src/support.h b/src/support.h
      --- a/src/support.h
      +++ b/src/support.h
      @@ -149,4 +149,6 @@ G_GNUC_INTERNAL void murrine_get_notebook_tab_position (GtkWidget *widget,
                                                               gboolean  *start,
                                                               gboolean  *end);
      
      +gboolean murrine_widget_is_ltr (GtkWidget *widget);
      +gboolean murrine_object_is_a (const GObject * object, const gchar * type_name);
       #endif /* SUPPORT_H */
    '') ];

    strictDeps = true;
    meta.platforms = pkgs.lib.platforms.linux;
  };

  # Recolors every blue-ish color in the theme css to Catppuccin mauve (see the
  # comment in installPhase). Linted by writePython3, so keep it flake8-clean.
  rotateBlue = pkgs.writers.writePython3 "rotate-blue" { } ''
    import colorsys
    import re
    import sys

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
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "catppuccin-mauve-dark-gtk";
  version = "0-unstable-2026-06-25";
  inherit src;

  nativeBuildInputs = [
    pkgs.jdupes
    pkgs.sassc
  ];

  propagatedUserEnvPkgs = [ gtkEngineMurrine ];

  postPatch = ''
    find -name "*.sh" -print0 | while IFS= read -r -d ''' file; do
      patchShebangs "$file"
    done

    substituteInPlace themes/lib/utils.sh \
      --replace-fail 'LOG_FILE="''${HOME}/.cache/catppuccin-install.log"' 'LOG_FILE=/dev/null'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/themes"
    BATCH_MODE=true ./themes/install.sh \
      --name Catppuccin \
      --theme mauve \
      --color dark \
      --size standard \
      --dest "$out/share/themes"

    # Upstream's mauve variant only recolors the named accent colors; plenty of
    # hardcoded blues remain (suggested-action buttons, libadwaita's blue_N
    # palette, app tiles, ...). Rotate every blue-ish color to mauve, keeping
    # lightness/saturation/alpha.
    find "$out/share/themes" -type f -name '*.css' -print0 \
      | xargs -0 ${rotateBlue}

    jdupes --quiet --link-soft --recurse "$out/share"

    runHook postInstall
  '';

  meta = {
    description = "Catppuccin Mauve Dark GTK theme";
    homepage = "https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme";
    license = pkgs.lib.licenses.gpl3Only;
    platforms = pkgs.lib.platforms.linux;
  };
}
