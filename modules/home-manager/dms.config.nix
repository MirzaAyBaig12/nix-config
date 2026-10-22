{
  config,
  lib,
  osConfig,
  ...
}:

let
  repo = "${config.home.homeDirectory}/nix-config/.config/dms";
  link = name: { source = config.lib.file.mkOutOfStoreSymlink "${repo}/${name}"; };

  # Per-plugin settings, keyed by registry id. Plugins with no settings
  # (activateLinux, quranWidget, dankGifSearch, emojiPicker, modernClock)
  # aren't listed here and just get `enabled = true`.
  #
  # Don't put runtime state in here (webSearch ddgBangs/lastSync, emojiLauncher
  # recentEmojis): plugin_settings.json is a read-only store symlink, plugins
  # can't write it.
  pluginSettings = {
    caffeineRedesigned = {
      selectedDuration = "infinity";
    };
    nixPackageRunner = {
      runSourceMode = "latest_unstable";
      terminal = "ghostty";
    };
    prayerTimes = {
      method = "Auto (based on location)";
      school = "1";
      use12H = false;
      iconOnly = false;
    };
    vscodeLauncher = {
      editorMode = "VSCode - Insiders";
      trigger = "code";
      noTrigger = false;
    };
    webSearch = {
      searchEngines = [ ];
      disabledEngines = [
        "duckduckgo"
        "bing"
        "kagi"
        "stackoverflow"
        "amazon"
        "ebay"
        "maps"
        "images"
        "twitter"
        "linkedin"
        "imdb"
        "translate"
        "npmjs"
        "crates"
        "google"
        "nixopts"
        "nixpkgs"
        "youtube"
        "github"
        "archlinux"
        "aur"
        "pypi"
        "mdn"
      ];
    };
    dankPomodoroTimer = {
      autoStartBreaks = true;
      autoStartPomodoros = true;
      longBreakFrequency = 4;
    };
    emojiLauncher = {
      trigger = "!";
      pasteOnSelect = true;
    };
    batteryOSD = {
      osdDuration = 2700;
      lowThreshold = 20;
      chargingWaveSpeed = 2190;
    };
    calculator = {
      trigger = "calc";
      noTrigger = false;
    };
  };

  # Which plugins are enabled is decided once, in the nixos module
  # (programs.dank-material-shell.plugins in modules/niri.nix).
  enabledPlugins = lib.filterAttrs (_: p: p.enable) osConfig.programs.dank-material-shell.plugins;
in
{
  # Declarative-ish DMS config, home-manager side. Only the HM *file* handling is
  # used here: the home-manager shell module is intentionally NOT imported.
  #
  # 1) Config DMS rewrites constantly from its own settings UI (settings.json,
  #    monitors.json, clsettings.json, custom themes): out-of-store symlinks into
  #    this repo (nix-config/.config/dms), so the UI keeps working and the files
  #    stay tracked in git. Same idea as ~/.config/niri.
  #
  # 2) plugin_settings.json: generated from nix (pluginSettings above). Hybrid
  #    plugin setup: the nixos module installs the plugins to
  #    /etc/xdg/quickshell/dms-plugins, which DMS recognises as system plugins (no
  #    bogus "repository does not exist" update-check errors). It ignores
  #    `settings`, so this file is written here instead, with `enabled = true` for
  #    every plugin enabled in the nixos block.
  #
  # Deliberately NOT managed:
  #  - firefox.css, .changelog-*, .firstlaunch, *.bak, plugins.lock.json: generated
  #    or state, not config
  #  - profiles/: empty legacy dir (display profiles live in monitors.json now)
  #
  # If a linked file ever turns into a regular file instead of a symlink (a save
  # replaced the link), the next rebuild moves it to *.bak and re-links, so check
  # the .bak for anything newer than the repo copy.
  xdg.configFile = {
    "dms/settings.json" = link "settings.json";
    "dms/clsettings.json" = link "clsettings.json";
    "dms/monitors.json" = link "monitors.json";
    "dms/themes" = link "themes";

    "dms/plugin_settings.json".text = builtins.toJSON (
      lib.mapAttrs (name: _: { enabled = true; } // (pluginSettings.${name} or { })) enabledPlugins
    );
  };
}
