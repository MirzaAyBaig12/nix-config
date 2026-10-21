{ pkgs, ... }:

let
  applications = [
    "com.github.tchx84.Flatseal"
    "com.logseq.Logseq"
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
in
{
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = applications;

    overrides = {
      writeMode = "replace";
      settings = {
        global = {
          Context.filesystems = [
            "xdg-data/themes:ro"
            "xdg-data/icons:ro"
            "xdg-config/gtk-3.0:ro"
            "xdg-config/gtk-4.0:ro"
            "xdg-config/Kvantum:ro"
            "xdg-config/qt5ct:ro"
            "xdg-config/qt6ct:ro"
          ];

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

  # Automatically install all Kvantum runtime branches non-interactively on switch
  system.activationScripts.installKvantumBranches = {
    text = ''
      ${pkgs.flatpak}/bin/flatpak install --system --noninteractive flathub \
        org.kde.KStyle.Kvantum//6.10 \
        org.kde.KStyle.Kvantum//6.9 \
        org.kde.KStyle.Kvantum//6.6 \
        org.kde.KStyle.Kvantum//6.5 \
        org.kde.KStyle.Kvantum//5.15-25.08 \
        org.kde.KStyle.Kvantum//5.15-24.08 \
        org.kde.KStyle.Kvantum//5.15-23.08 \
        org.kde.KStyle.Kvantum//5.15-22.08 \
        org.kde.KStyle.Kvantum//5.15-21.08 \
        org.kde.KStyle.Kvantum//5.15 || true
    '';
  };
}