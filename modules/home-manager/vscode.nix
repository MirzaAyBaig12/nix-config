{ config, lib, pkgs, inputs, ... }:

let
  exts = (pkgs.extend inputs.nix-vscode-extensions.overlays.default).nix-vscode-extensions;
  marketplace = exts.vscode-marketplace;
  openvsx = exts.open-vsx;
in
{
  programs.vscode = {
    enable = true;

    # VSCode is installed system-wide via environment.systemPackages (programs.nix).
    # null = this module only manages config/extensions/argv.json, no second copy.
    package = null;

    # NOTE: argv.json (password-store, etc.) is no longer managed here —
    # it's symlinked from ~/nix-config/.config/.vscode/argv.json instead,
    # see home.file.".vscode/argv.json" in services.hm.nix.

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # Marketplace-only: not available on Open VSX (checked against the
      # nix-vscode-extensions data directly).
      extensions =
        (with marketplace; [
          atommaterial.a-file-icon-vscode
          github.remotehub
          kconway.vscode-undo-buttons
          ms-python.vscode-pylance
          ms-vscode.azure-repos
          ms-vscode.remote-repositories
          ms-vscode.vscode-python-web-wasm
        ])
        # Everything else is on Open VSX too, so it lives here instead of
        # duplicating a marketplace entry.
        ++ (with openvsx; [
          anthropic.claude-code
          anweber.local-sync
          atomicspirit.nix-embedded-highlighter
          b9software.vsx-auto-close-tab
          christian-kohler.path-intellisense
          danklinux.dms-theme
          drcika.apc-extension
          jeff-hykin.better-nix-syntax
          jnoortheen.nix-ide
          mkhl.direnv
          ms-python.debugpy
          ms-python.python
          yusifaliyevpro.vscicons
          zokugun.cron-tasks
          rionoir.gitcharm
        ]);

      # Full backup of the live settings.json (nix.serverSettings/nixd lives
      # in nixd.nix and merges with this, so it's intentionally left out here).
      userSettings = {
        "claudeCode.preferredLocation" = "panel";
        "claudeCode.claudeProcessWrapper" = "fcc-claude";
        "claudeCode.disableLoginPrompt" = true;
        "workbench.iconTheme" = "a-file-icon-vscode";
        "workbench.experimental.modernUI" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "syncSettings.hostname" = "Void";
        "syncSettings.hooks.postDownload" = "";
        "local-sync.autorestore" = true;
        "local-sync.backupPath" = "/home/ayaan_mirza/nix-config/.config/.vscode";
        "local-sync.ignoreSettings" = [ ];
        "local-sync.ignoreExtensions" = [ ];
        "editor.minimap.enabled" = false;
        "B9AutoCloseTab.maxTabs" = 9;
        "security.workspace.trust.untrustedFiles" = "open";
        "diffEditor.ignoreTrimWhitespace" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmPasteNative" = false;

        # --- AI features off (built-in chat/Copilot stuff; the Claude Code extension is untouched) ---
        "chat.disableAIFeatures" = true;
        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;
        "chat.mcp.access" = "none";
        "editor.inlineSuggest.enabled" = false;
        "github.copilot.enable" = {
          "*" = false;
        };
        "github.copilot.editor.enableAutoCompletions" = false;

        # --- telemetry off ---
        "telemetry.telemetryLevel" = "off";
        "telemetry.feedback.enabled" = false;
        "workbench.enableExperiments" = false;

        "workbench.browser.showInTitleBar" = true;
        "workbench.productIconTheme" = "a-file-icon-vscode-product-icon-theme";

        "workbench.colorCustomizations" = {
          "activityBar.activeBorder" = "#c8bfff";
          "activityBarBadge.background" = "#c8bfff";
          "activityBarBadge.foreground" = "#30285f";
          "focusBorder" = "#c8bfff";
          "badge.background" = "#c8bfff";
          "badge.foreground" = "#30285f";
          "extensionButton.background" = "#c8bfff";
          "extensionButton.foreground" = "#30285f";
          "extensionButton.hoverBackground" = "#d8d2ff";
          "extensionButton.prominentBackground" = "#c8bfff";
          "extensionButton.prominentForeground" = "#30285f";
          "extensionButton.prominentHoverBackground" = "#d8d2ff";
          "button.background" = "#c8bfff";
          "button.foreground" = "#30285f";
          "button.hoverBackground" = "#d8d2ff";
          "list.hoverBackground" = "#d8d2ff22";
          "scrollbarSlider.hoverBackground" = "#c8bfffaa";
          "progressBar.background" = "#c8bfff";
          "scrollbarSlider.activeBackground" = "#c8bfff88";
          "tab.activeBorderTop" = "#c8bfff";
          # the zoom-level button in the status bar is a "prominent" item
          "statusBarItem.prominentBackground" = "#c8bfff";
          "statusBarItem.prominentForeground" = "#30285f";
          "statusBarItem.prominentHoverBackground" = "#d8d2ff";
          "list.activeSelectionBackground" = "#473f77";
          "list.activeSelectionForeground" = "#e5deff";
        };

        "apc.stylesheet" = {
          ".window-controls-container" = "display: none !important;";
        };
        "gitcharm.ai" = {
          ".provider"= "vscode-lm";
          ".claudePath"= "fcc-claude";
        };
      };
    };
  };

  # With `package = null` home-manager skips its "regenerate extensions.json" step, so
  # VSCode (installed system-wide) never notices the symlinked extensions. Redo that step
  # ourselves whenever the extension set changes. Close VSCode before switching.
  home.file.".vscode/extensions/.extensions-regen-stamp" = {
    text = lib.concatMapStringsSep "\n" toString config.programs.vscode.profiles.default.extensions;
    onChange = ''
      run rm $VERBOSE_ARG -f ${config.home.homeDirectory}/.vscode/extensions/{extensions.json,.init-default-profile-extensions}
      verboseEcho "Regenerating VSCode extensions.json"
      run ${lib.getExe pkgs.vscode} --list-extensions > /dev/null
    '';
  };
}