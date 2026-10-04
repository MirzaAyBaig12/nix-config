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

    # Upstream's mauve variant only recolors the named accent colors; the
    # suggested-action buttons (Install, Select, ...) still hardcode Catppuccin
    # blue. Recolor those (base, hover and focus shades) to mauve.
    find "$out/share/themes" -type f -name '*.css' -exec sed -i \
      -e 's/#89b4fa/#cba6f7/g' \
      -e 's/rgba(137, 180, 250,/rgba(203, 166, 247,/g' \
      -e 's/rgba(110, 143, 199, 0.961)/rgba(162, 133, 198, 0.961)/g' {} +

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
