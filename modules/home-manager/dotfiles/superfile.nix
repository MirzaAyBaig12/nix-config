{ 
  pkgs, 
  lib, 
  inputs, 
  ... 
}:

{
  programs.superfile = {
    enable = true;
    firstUseCheck = false;

    # Custom hotkeys, written to ~/.config/superfile/hotkeys.toml.
    # Only overrides listed here; everything else keeps the defaults.
    hotkeys = {
      # Space = same as Enter: opens folders, toggles selection in select mode,
      # opens files with the default app (VS Code for text/code files).
      confirm = [
        "enter"
        "right"
        "l"
        "space"
      ];

      open_file_with_editor = [
        "e"
        "ctrl+alt+e"
      ];
    };

    settings = {
      # Editors
      editor = "nvim";
      dir_editor = "code --wait";

      # General
      auto_check_update = false;
      cd_on_quit = false;
      default_directory = ".";
      debug = false;
      ignore_missing_fields = true;
      shell_close_on_success = false;

      # File previews
      default_open_file_preview = true;
      show_image_preview = true;
      show_panel_footer_info = true;
      file_preview_width = 0;
      enable_file_preview_border = true;
      code_previewer = "";

      # Sorting and file sizes
      file_size_use_si = false;
      default_sort_type = 0;
      sort_order_reversed = false;
      case_sensitive_sort = false;
      page_scroll_size = 0;

      # File panel
      file_panel_extra_columns = 0;
      file_panel_name_percent = 50;

      # Sidebar
      sidebar_width = 20;
      sidebar_sections = [
        "home"
        "pinned"
        "disks"
      ];

      # Appearance
      theme = "catppuccin-mocha-mauve";
      nerdfont = true;
      show_select_icons = true;
      transparent_background = true;

      # Border characters
      border_top = "─";
      border_bottom = "─";
      border_left = "│";
      border_right = "│";
      border_top_left = "╭";
      border_top_right = "╮";
      border_bottom_left = "╰";
      border_bottom_right = "╯";
      border_middle_left = "├";
      border_middle_right = "┤";

      # Optional features
      metadata = false;
      enable_md5_checksum = false;
      zoxide_support = true;

      # File-opening rules
      open_with = {
        # Video -> VLC
        mkv = "vlc";
        mp4 = "vlc";
        m4v = "vlc";
        avi = "vlc";
        mov = "vlc";
        webm = "vlc";
        wmv = "vlc";
        flv = "vlc";
        mpg = "vlc";
        mpeg = "vlc";
        m2ts = "vlc";
        ts = "vlc";
        ogv = "vlc";
        "3gp" = "vlc";

        # PDFs -> LibreWolf
        pdf = "librewolf";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Catppuccin Mocha Mauve theme with blue accents changed to mauve.
  home.file.".config/superfile/theme/catppuccin-mocha-mauve.toml".text =
    let
      upstream = builtins.readFile (builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/superfile/refs/heads/main/themes/mocha/catppuccin-mocha-mauve.toml";
        sha256 = "sha256-zAX5DZbvCREWdInvcysmMU7P15zzzeMNs+RCD4keFVI=";
      });
    in
    builtins.replaceStrings
      [
        ''gradient_color = ["#89b4fa", "#cba6f7"]''
        ''file_panel_top_path = "#89b4fa"''
        ''sidebar_title = "#89dceb"''
      ]
      [
        ''gradient_color = ["#cba6f7", "#cba6f7"]''
        ''file_panel_top_path = "#cba6f7"''
        ''sidebar_title = "#cba6f7"''
      ]
      upstream;

  # Register Superfile as a terminal-based file manager.
  xdg.desktopEntries.superfile = {
    name = "Superfile";
    genericName = "Terminal File Manager";
    comment = "Browse files in Superfile";
    exec = "superfile %U";
    terminal = true;
    icon = "/home/ayaan_mirza/nix-config/.config/misc/icons/superfile.png";
    categories = [
      "System"
      "FileTools"
      "FileManager"
    ];
    mimeType = [
      "inode/directory"
    ];
  };
}