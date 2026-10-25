{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  repo = "${config.home.homeDirectory}/nix-config/.config/dms";
  link = name: { source = config.lib.file.mkOutOfStoreSymlink "${repo}/${name}"; };

  # Which plugins are enabled is decided once, in the nixos module
  # (programs.dank-material-shell.plugins in modules/niri.nix).
  enabledPlugins = lib.filterAttrs (_: p: p.enable) osConfig.programs.dank-material-shell.plugins;
  enabledNames = builtins.toJSON (lib.attrNames enabledPlugins);
in
{
  # Declarative-ish DMS config, home-manager side. Only the HM *file* handling is
  # used here: the home-manager shell module is intentionally NOT imported.
  #
  # 1) Config DMS rewrites constantly from its own settings UI (settings.json,
  #    plugin_settings.json, monitors.json, clsettings.json, custom themes):
  #    out-of-store symlinks into this repo (nix-config/.config/dms), so the UI
  #    keeps working (plugins can save their own settings/state) and the files
  #    stay tracked in git. Same idea as ~/.config/niri.
  #
  # 2) Plugins are installed by the nixos module to /etc/xdg/quickshell/dms-plugins,
  #    which DMS recognises as system plugins (no bogus "repository does not
  #    exist" update-check errors). That module ignores `settings`, so the
  #    activation script below makes sure every plugin enabled in the nixos block
  #    has `enabled = true` in plugin_settings.json. It only ever sets that one
  #    key, and only rewrites the file if something is missing, so every other
  #    value (edited in the DMS UI or by hand) is left alone.
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
    "dms/plugin_settings.json" = link "plugin_settings.json";
    "dms/clsettings.json" = link "clsettings.json";
    "dms/monitors.json" = link "monitors.json";
    "dms/themes" = link "themes";
  };

  home.activation.dmsEnablePlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="${repo}/plugin_settings.json"
    names='${enabledNames}'
    jq=${pkgs.jq}/bin/jq

    if [ -z "''${DRY_RUN:-}" ]; then
      [ -e "$f" ] || echo '{}' > "$f"

      # Rewrite only if some enabled plugin is missing or not enabled = true.
      if ! "$jq" -e --argjson n "$names" '. as $s | all($n[]; $s[.].enabled == true)' "$f" >/dev/null; then
        tmp="$(mktemp)"
        "$jq" --argjson n "$names" 'reduce $n[] as $p (.; .[$p].enabled = true)' "$f" > "$tmp" \
          && cat "$tmp" > "$f"
        rm -f "$tmp"
      fi
    fi
  '';
}
