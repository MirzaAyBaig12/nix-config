{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:

let
  # ============================================================================
  # 1. THEME VARIABLES & SCRIPTS (Including Flatpak GTK Overrides)
  # ============================================================================
  themeName = "Catppuccin-GTK-Mauve-Dark";
  
  catppuccinGtkTheme = pkgs.magnetic-catppuccin-gtk.override {
    accent = [ "mauve" ];
    shade = "dark";
    size = "standard";
  };

  themeSrc = "${catppuccinGtkTheme}/share/themes/${themeName}";

  # Python script to handle blue-to-mauve color rotation for Flatpak theme compatibility[cite: 1, 2]
  rotateBlueScript = pkgs.writers.writePython3 "rotate-blue.py" { } ''
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

  gtk4Css = pkgs.writeText "gtk4.css" ''
    /* real file, not a store symlink, so flatpak sandboxes can read it[cite: 1, 2] */
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

  qtColors = ''
    [ColorScheme]
    active_colors=#ffcdd6f4, #ff45475a, #ff585b70, #ff313244, #ff11111b, #ff181825, #ffcdd6f4, #ffcdd6f4, #ffcdd6f4, #ff1e1e2e, #ff181825, #ff11111b, #ffcba6f7, #ff11111b, #ff89b4fa, #ffb4befe, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ffcba6f7
    inactive_colors=#ff7f849c, #ff1e1e2e, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff7f849c, #ffcdd6f4, #ff7f849c, #ff1e1e2e, #ff181825, #ff11111b, #ff313244, #ff7f849c, #ff7f849c, #ff7f849c, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff313244
    disabled_colors=#ff6c7086, #ff313244, #ff45475a, #ff313244, #ff11111b, #ff181825, #ff6c7086, #ffcdd6f4, #ff6c7086, #ff1e1e2e, #ff181825, #ff11111b, #ff181825, #ff6c7086, #ffa9bcdb, #ffc7cceb, #ff181825, #ffffffff, #ff1e1e2e, #ffcdd6f4, #806c7086, #ff181825
  '';

in
{
  # ============================================================================
  # 2. CATPPUCCIN HOME MANAGER INTEGRATION
  # ============================================================================
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

  # ============================================================================
  # 3. STYLIX CORE CONFIGURATION
  # ============================================================================
  stylix = {
    enable = true;
    autoEnable = false;

    targets.vesktop.enable = false;
    targets.vencord.enable = false;
    targets.gnome.enable = false;     # Prevents writing color-scheme='default' conflicting with Niri
    targets.vscode.enable = false;    # Handled separately in vscode.nix
    targets.gtk.enable = false;       # Handled manually via gtk section below
    targets.qt.enable = false;        # Handled manually via qt5ct/qt6ct configurations

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
  };

  # ============================================================================
  # 4. DCONF & DESKTOP ENVIRONMENT SETTINGS
  # ============================================================================
  dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "appmenu";

  dconf.settings."org/gnome/desktop/interface" = {
    icon-theme = lib.mkForce "Papirus-Dark";
    accent-color = lib.mkForce "purple";
  };

  # ============================================================================
  # 5. GTK TOOLKIT & FLATPAK REAL-FILE ACTIVATION OVERRIDES
  # ============================================================================
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

      rm -rf "$cfg/gtk-4.0/catppuccin"
      mkdir -p "$cfg/gtk-4.0/catppuccin"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-4.0/. "$cfg/gtk-4.0/catppuccin/"

      rm -rf "$theme"
      mkdir -p "$theme"
      cp -rL --no-preserve=mode,ownership ${themeSrc}/gtk-3.0 ${themeSrc}/gtk-4.0 ${themeSrc}/index.theme "$theme/"

      chmod -R u+w "$cfg/gtk-4.0/catppuccin" "$theme"

      find "$cfg/gtk-4.0/catppuccin" "$theme" -type f -name "*.css" -exec ${rotateBlueScript} {} +
    fi
  '';

  gtk = {
    enable = true;
    theme = lib.mkForce {
      package = catppuccinGtkTheme;
      name = "Catppuccin-GTK-Mauve-Dark";
    };
    gtk4 = {
      theme = lib.mkForce {
        package = catppuccinGtkTheme;
        name = "Catppuccin-GTK-Mauve-Dark";
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

        /* tab/toggle switchers: soft tint + mauve text */
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

        /* unfocused (backdrop) windows */
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

        toggle-group toggle:checked:backdrop,
        toggle-group toggle:checked:backdrop *,
        toggle-group > toggle:checked:backdrop,
        toggle-group > toggle:checked:backdrop * {
          color: @accent_color;
        }

        /* Bazaar tiles + featured banner */
        button.card.app-tile,
        button.card.category-tile,
        .card.app-tile,
        .card.category-tile,
        .card.featured-carousel,
        .featured-carousel {
          border-radius: 12px;
        }

        /* dialog scrim */
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

  # ============================================================================
  # 6. QT5 / QT6 CONFIGURATION & COLOR SCHEMES
  # ============================================================================
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
}