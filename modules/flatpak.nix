{ ... }:

{
  services.flatpak = {
    packages = [
      "com.github.tchx84.Flatseal"
      "com.spotify.Client"
      "com.usebottles.bottles"
      "com.vysp3r.ProtonPlus"
      "fr.arnaudmichel.launcherstudio"
      "io.github.cosmic_utils.camera"
      "io.github.flattool.Warehouse"
      "io.github.kolunmi.Bazaar"
      "io.github.peazip.PeaZip"
      "io.github.screwys.Rufin"
      "io.github.seadve.Kooha"
      "io.github.shiftey.Desktop"
      "io.github.ungoogled_software.ungoogled_chromium"
      "io.gitlab.adhami3310.Impression"
      "io.missioncenter.MissionCenter"
      "io.podman_desktop.PodmanDesktop"
      "it.mijorus.gearlever"
      "org.gnome.Loupe"
      "org.gnome.Maps"
      "org.kde.isoimagewriter"
      "org.mozilla.thunderbird_esr"
      "org.pvermeer.WebAppHub"
      "org.soundconverter.SoundConverter"
      "org.vinegarhq.Sober"
      "page.codeberg.grinka.Transition"
      "space.bigrat.mocktail"
      "uk.co.cappsy.Tesseract"
    ];

    overrides = {
      writeMode = "replace";
      settings = {
        global = {
          Context.filesystems = [
            "xdg-data/themes:ro"
            "xdg-data/icons:ro"
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
            # Kvantum & Qt configuration access (no KDE globals)
            "xdg-config/Kvantum:ro"
            "xdg-config/qt5ct:ro"
            "xdg-config/qt6ct:ro"
          ];

          # Force dark mode, Papirus-Dark icons, and Kvantum styling for Qt apps
          Environment = {
            ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
            ICON_THEME = "Papirus-Dark";
            QT_QPA_PLATFORMTHEME = "qt5ct";
            QT_STYLE_OVERRIDE = "kvantum";
          };
        };

        "com.kolumni.bazaar" = {
          Context.filesystems = [
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
          ];
        };
      };
    };

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };  
    uninstallUnmanaged = true;
  };
}
