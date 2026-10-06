{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:

let
  catppuccinGtkTheme = import ../gtk.nix {
    inherit pkgs;
    src = inputs.catppuccinGtkTheme;
  };

  qtColors = ''
    [ColorScheme]
    active_colors=#ffcdd6f4, #ff45475a, #ff585b70, #ff313244, #ff11111b, #ff181825, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff11111b, #ffcba6f7, #ff11111b, #ff89b4fa, #ffb4befe, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ffcba6f7
    inactive_colors=#ff7f849c, #ff1e1e2e, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff7f849c, #ffcdd6f4, #ff7f849c, #ff1e1e2e, #ff181825, #ff11111b, #ff313244, #ff7f849c, #ff7f849c, #ff7f849c, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff313244
    disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff6c7086, #ffcdd6f4, #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff181825, #ff6c7086, #ffa9bcdb, #ffc7cceb, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff181825
  '';

in
{

   # Catppuccin ports for every program HM knows about. Mocha + Mauve everywhere.
  # Stylix autoEnable is off (see stylix.nix), so catppuccin is what themes stuff.
  # GTK/Qt toolkit styling stays explicit in stylix.nix + gtk.nix.
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    accent = "mauve";

    gtk.icon.enable = false;
    chromium.enable = false;
    qt5ct.enable = false;
    kvantum = {
      enable = true;
      flavor = "mocha";
      accent = "mauve";
    };
  };
  
  stylix = {
    enable = true;
    autoEnable = false;

    targets.vesktop.enable = false;
    targets.vencord.enable = false;
    # This auto-enabled Linux target writes color-scheme='default' to dconf,
    # which conflicts with the system-locked prefer-dark value in modules/niri.nix.
    targets.gnome.enable = false;

    cursor = {
      package = osConfig.custom.bibataMaterialCursor;
      name = "Bibata-Material-Lilac";
      size = 30;
    }; 

    fonts = {
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "Sans";
      };
      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    base16Scheme = {
      base00 = "1e1e2e";
      base01 = "181825";
      base02 = "313244";
      base03 = "45475a";
      base04 = "585b70";
      base05 = "cdd6f4";
      base06 = "f5e0dc";
      base07 = "b4befe";
      base08 = "f38ba8";
      base09 = "fab387";
      base0A = "f9e2af";
      base0B = "a6e3a1";
      base0C = "94e2d5";
      base0D = "89b4fa";
      base0E = "cba6f7";
      base0F = "f2cdcd";
    };

    # Use the packaged Catppuccin GTK theme and explicit qtct palettes below;
    # Stylix must not replace either toolkit's theme or colors.
    targets.gtk.enable = false;
    targets.qt.enable = false;
  };

  # DMS has "syncModeWithPortal": true, so it doesnt remember a dark/light choice at
  # all, it just mirrors this dconf key on every sync. thats why colors.kdl kept
  # reverting no matter what i patched after the fact. pinning the actual source to
  # dark
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "appmenu";

  dconf.settings."org/gnome/desktop/interface" = {
    # color-scheme is set and locked in the system dconf profile (modules/niri.nix).
    icon-theme = lib.mkForce "Papirus-Dark";
    accent-color = lib.mkForce "purple";
  };

  gtk = {
    enable = true;
    theme = lib.mkForce {
      package = catppuccinGtkTheme;
      name = "Catppuccin-Mauve-Dark";
    };
    gtk4 = {
      theme = lib.mkForce {
        package = catppuccinGtkTheme;
        name = "Catppuccin-Mauve-Dark";
      };
      extraConfig.gtk-decoration-layout = ":";
      extraCss = ''
        @define-color theme_selected_bg_color #cba6f7;
        @define-color theme_selected_fg_color #1e1e2e;
        @define-color accent_color #cba6f7;
        @define-color accent_bg_color #cba6f7;
        @define-color accent_fg_color #1e1e2e;
        @define-color window_bg_color #1e1e2e;
        @define-color window_fg_color #cdd6f4;
        @define-color view_bg_color #1e1e2e;
        @define-color view_fg_color #cdd6f4;

        window {
          --window-bg-color: #1e1e2e;
          --window-fg-color: #cdd6f4;
          --view-bg-color: #1e1e2e;
          --view-fg-color: #cdd6f4;
          --headerbar-bg-color: #181825;
          --headerbar-fg-color: #cdd6f4;
          --headerbar-border-color: #11111b;
          --sidebar-bg-color: #181825;
          --sidebar-fg-color: #cdd6f4;
          --card-bg-color: #181825;
          --card-fg-color: #cdd6f4;
          --popover-bg-color: #181825;
          --popover-fg-color: #cdd6f4;
          --accent-bg-color: #cba6f7;
          --accent-fg-color: #1e1e2e;
        --accent-color: #cba6f7;
        --accent-standalone-color: #cba6f7;
        --blue-1: #cba6f7;
        --blue-2: #ae90d6;
        --blue-3: #9279b4;
        --blue-4: #7d689c;
        --blue-5: #675883;
        }

        selection,
        text > selection,
        text selection,
        entry > text > selection,
        entry.search > text > selection,
        entry text selection,
        textview text selection,
        label > selection,
        spinbutton > text > selection,
        .view selection {
          background-color: #cba6f7;
          color: #1e1e2e;
        }

        text > selection:focus-within,
        text:focus-within > selection,
        entry:focus-within > text > selection,
        textview:focus-within text selection {
          background-color: #cba6f7;
          color: #1e1e2e;
        }

        entry:focus-within,
        entry.search:focus-within {
          outline: 2px solid #cba6f7;
          outline-offset: -2px;
        }

        /* tab/toggle switchers: soft tint + mauve text, same as selected sidebar rows */
        toggle-group toggle:checked,
        toggle-group > toggle:checked,
        toggle-group button.toggle:checked,
        .toggle-group button:checked,
        viewswitcher button:checked,
        viewswitcher > button:checked {
          background-color: alpha(@accent_bg_color, 0.16);
          color: @accent_color;
          font-weight: 500;
        }

        toggle-group toggle:checked:hover,
        toggle-group > toggle:checked:hover,
        toggle-group button.toggle:checked:hover,
        .toggle-group button:checked:hover,
        viewswitcher button:checked:hover,
        viewswitcher > button:checked:hover {
          background-color: alpha(@accent_bg_color, 0.22);
          color: @accent_color;
        }

        /* unfocused (backdrop) windows: text falls back to the light default, which
           disappears on solid mauve fills. keep the dark on-accent text there too. */
        button:checked:backdrop,
        button:checked:backdrop *,
        button.suggested-action:backdrop,
        button.suggested-action:backdrop *,
        button.opaque:backdrop,
        button.opaque:backdrop *,
        viewswitcher button.toggle:checked:backdrop,
        viewswitcher button.toggle:checked:backdrop *,
        stackswitcher button:checked:backdrop,
        stackswitcher button:checked:backdrop * {
          color: #1e1e2e;
        }

        /* soft-tint toggles keep mauve text when unfocused */
        toggle-group toggle:checked:backdrop,
        toggle-group toggle:checked:backdrop *,
        toggle-group > toggle:checked:backdrop,
        toggle-group > toggle:checked:backdrop * {
          color: @accent_color;
        }

        /* Bazaar tiles + featured banner: keep rounded corners at every window width */
        button.card.app-tile,
        button.card.category-tile,
        .card.app-tile,
        .card.category-tile,
        .card.featured-carousel,
        .featured-carousel {
          border-radius: 12px;
        }

        /* dialog scrim: the theme defines shade_color as light (white 12%), so libadwaita's
           dialog dimming lightens the window behind a dialog instead of darkening it and
           the sheet shadow disappears. restore libadwaita's dark shade for dialogs. */
        dialog-host > dialog {
          --shade-color: rgb(0 0 6 / 25%);
        }

        floating-sheet > dimming,
        bottom-sheet > dimming {
          background-color: rgb(0 0 6 / 50%);
        }
      '';
    };
    gtk3.extraConfig.gtk-decoration-layout = ":";

    iconTheme = {
      name = lib.mkForce "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Material-Lilac";
      size = 30;
    };
    gtk2.extraConfig = ''
      gtk-cursor-theme-name="Bibata-Material-Lilac"
      gtk-cursor-theme-size=30
      gtk-font-name="Sans 11"
      gtk-application-prefer-dark-theme=1
      gtk-decoration-layout=":"
      gtk-enable-animations=1
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-cursor-blink=1
      gtk-cursor-blink-time=1000
      gtk-primary-button-warps-slider=1
      style "modern-rounded" {
        GtkWidget::corner-radius = 6
      }
      widget_class "*" style "modern-rounded"
    '';
  };

  # These qtct schemes preserve the supplied Qt active/inactive/disabled
  # palettes exactly and are shared by Qt 5 and Qt 6.
  xdg.configFile = {
    "qt5ct/colors/Catppuccin-Mauve-Dark.conf" = {
      text = qtColors;
      force = true;
    };
    "qt6ct/colors/Catppuccin-Mauve-Dark.conf" = {
      text = qtColors;
      force = true;
    };
    "qt5ct/qt5ct.conf" = {
      text = ''
        [Appearance]
        color_scheme_path=${config.xdg.configHome}/qt5ct/colors/Catppuccin-Mauve-Dark.conf
        custom_palette=true
        icon_theme=Papirus-Dark
        standard_dialogs=default
        style=kvantum
        font="DejaVu Sans,11,-1,5,50,0,0,0,0,0"
      '';
      force = true;
    };
    "qt6ct/qt6ct.conf" = {
      text = ''
        [Appearance]
        color_scheme_path=${config.xdg.configHome}/qt6ct/colors/Catppuccin-Mauve-Dark.conf
        custom_palette=true
        icon_theme=Papirus-Dark
        standard_dialogs=default
        style=kvantum
        font="DejaVu Sans,11,-1,5,50,0,0,0,0,0"
      '';
      force = true;
    };
  };

  # VSCode's look (theme, extensions, everything) is fully managed in
  # vscode.nix instead — Stylix's own vscode target sets
  # workbench.colorTheme = "Stylix" and conflicts with whatever theme
  # is set there (e.g. Dracula).
  stylix.targets.vscode.enable = false;
}
