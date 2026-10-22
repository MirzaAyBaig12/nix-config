{ 
  pkgs, 
  ... 
}:

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

  # Install any missing Kvantum runtime branches non-interactively on switch,
  # but only when a Wayland session is running. Each branch is checked first,
  # so a normal rebuild does no network work when everything is installed.
  # No `exit` here: activation scripts are concatenated into one script.
  system.activationScripts.installKvantumBranches = {
    text = ''
      has_wayland=0
      for sock in /run/user/*/wayland-*; do
        if [ -S "$sock" ]; then
          has_wayland=1
          break
        fi
      done

      if [ "$has_wayland" = 1 ]; then
        flatpak=${pkgs.flatpak}/bin/flatpak
        missing=""

        for branch in 6.10 6.9 6.6 6.5 \
          5.15-25.08 5.15-24.08 5.15-23.08 5.15-22.08 5.15-21.08 5.15; do
          if ! $flatpak info --system "org.kde.KStyle.Kvantum//$branch" >/dev/null 2>&1; then
            missing="$missing org.kde.KStyle.Kvantum//$branch"
          fi
        done

        if [ -n "$missing" ]; then
          $flatpak install --system --noninteractive flathub $missing || true
        fi
      fi
    '';
  };
}