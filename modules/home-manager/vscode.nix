{ config, lib, pkgs, inputs, ... }:

let
  exts = (pkgs.extend inputs.nix-vscode-extensions.overlays.default).nix-vscode-extensions;
  marketplace = exts.vscode-marketplace;
  openvsx = exts.open-vsx;
in
{
  programs.vscode = {
    enable = true;

    # home-manager owns the actual vscode binary now too, not just my
    # config. used to be `null` + a systemPackages entry but that meant
    # extensions.json never auto-regenerated when I changed my list. pulled
    # vscode out of programs.nix's systemPackages so there's no dupe install.
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      # marketplace-only stuff — not on Open VSX, I actually checked against
      # the nix-vscode-extensions data instead of guessing.
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
        # everything else here is on Open VSX too, so it lives here instead
        # of me duplicating a marketplace entry for no reason.
        ++ (with openvsx; [
          anthropic.claude-code
          atomicspirit.nix-embedded-highlighter
          b9software.vsx-auto-close-tab
          christian-kohler.path-intellisense
          danklinux.dms-theme
          dracula-theme.theme-dracula
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

      userSettings = {
        # ============================================================
        # AI / CLAUDE — keeping all my AI stuff grouped here together
        # ============================================================

        # my Claude Code extension. docked in the panel, running through my
        # fcc-claude wrapper (free-claude-code/NIM setup) instead of a raw
        # claude binary, and skipping the login prompt since the wrapper
        # already handles auth for me.
        "claudeCode" = {
          "preferredLocation" = "panel";
          "claudeProcessWrapper" = "fcc-claude";
          "disableLoginPrompt" = true;
        };

        # gitcharm's ai commit messages — different extension but still
        # claude-powered under the hood, so it belongs up here with the rest
        # of my ai stuff. same fcc-claude wrapper, routed through vscode-lm.
        "gitcharm".ai = {
          "provider" = "claude-cli";
          "claudePath" = "fcc-claude";
        };

        # everything that ISN'T claude code — vscode's built-in chat, ghost
        # text suggestions, copilot — all off. I don't want ai shoved in my
        # face by default, claude code is the one ai tool I actually chose
        # to have, everything else here I'm opting out of on purpose.
        "chat" = {
          "disableAIFeatures" = true;
          "agent".enabled = false;
          "commandCenter".enabled = false;
          "mcp".access = "none";
        };
        "editor".inlineSuggest.enabled = false;
        "github".copilot = {
          "enable"."*" = false;
          "editor".enableAutoCompletions = false;
        };

        # ============================================================
        # THEME / LOOK
        # ============================================================

        # dracula theme. the actual registered label is "Dracula Theme" not
        # just "Dracula" — I had to go check the extension's own package.json
        # to figure that out, since setting it wrong just silently falls
        # back to whatever theme vscode had cached instead of erroring lol.
        # icons from a-file-icon-vscode for both files and the product icons.
        # stylix is deliberately OFF for vscode (see stylix.nix), this block
        # is the only thing controlling how vscode actually looks.
        "workbench" = {
          "iconTheme" = "a-file-icon-vscode";
          "productIconTheme" = "a-file-icon-vscode-product-icon-theme";
          "experimental".modernUI = true;
          "browser".showInTitleBar = true;
        };
        # colorTheme lives as its own flat key (not nested in the block
        # above) because catppuccin's module writes "workbench.colorTheme"
        # the same flat way — matching the exact attribute path lets
        # mkDefault actually do its job instead of leaving two different-
        # shaped definitions of the same setting sitting in the JSON.
        # mkDefault means catppuccin (normal priority, see below) wins while
        # it's enabled, and dracula becomes the fallback if I ever turn
        # catppuccin back off — not deleting it, just stepping back.
        #"workbench.colorTheme" = lib.mkDefault "Dracula Theme";

        # apc's css injection to hide my min/max/close window buttons.
        # leaves the rest of the titlebar alone, that's all I wanted gone.
        "apc".stylesheet = {
          ".window-controls-container" = "display: none !important;";
        };

        # my purple accent, same purple as my gtk/cosmic theme everywhere
        # else on this machinq. layered on top of dracula for the specific
        # bits dracula itself doesn't touch (buttons, badges, activity bar).
        /* "workbench".colorCustomizations = {
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
          # the zoom-level button in the status bar counts as "prominent"
          "statusBarItem.prominentBackground" = "#c8bfff";
          "statusBarItem.prominentForeground" = "#30285f";
          "statusBarItem.prominentHoverBackground" = "#d8d2ff";
          "list.activeSelectionBackground" = "#473f77";
          "list.activeSelectionForeground" = "#e5deff";
        }; */
        
        "window.controlsStyle" = "hidden";
        "editor.semanticHighlighting.enabled" = "true";
        "window.titleBarStyle" = "custom";

        # catppuccin.accentColor and workbench.colorTheme are NOT set here
        # anymore — the module below writes those two exact keys itself
        # (accent = "lavender", flavor = "mocha", matching what I had typed
        # here by hand). Keeping both would be a straight-up conflicting-
        # definition error, same deal as the stylix colorTheme fight earlier.
        "catppuccin.showUpdateNotification" = false;
        "catppuccin.silent" = true;
        "workbench.colorTheme" = "Catppuccin Mocha";
        "catppuccin.accentColor" = "lavender";

        # ============================================================
        # GIT
        # ============================================================
        "git" = {
          "autofetch" = true;
          "confirmSync" = false;
          "enableSmartCommit" = true;
        };

        # ============================================================
        # SYNC / BACKUP — two different extensions doing basically the same
        # job, backing my settings up, just to different spots.
        # syncSettings tags this machine as "Void" (old hostname, still
        # using it as the id since I never bothered changing it).
        # local-sync mirrors everything into my nix-config repo and
        # auto-restores from there whenever I launch vscode.
        # ============================================================
        "syncSettings" = {
          "hostname" = "Void";
          "hooks".postDownload = "";
        };

        # ============================================================
        # EDITOR BEHAVIOR — explorer prompts, diff view, trust, tab limits
        # ============================================================
        "editor".minimap.enabled = false;
        "explorer" = {
          "confirmDelete" = false;
          "confirmPasteNative" = false;
        };
        "diffEditor".ignoreTrimWhitespace = false;
        "security".workspace.trust.untrustedFiles = "open";
        "B9AutoCloseTab".maxTabs = 9;

        # ============================================================
        # TELEMETRY — off, everywhere, including vscode's own a/b
        # experiments thing (workbench.enableExperiments)
        # ============================================================
        "telemetry" = {
          "telemetryLevel" = "off";
          "feedback".enabled = false;
        };
        "workbench".enableExperiments = false;
      };
    };
  };

  catppuccin.vscode.profiles.default = {
    enable = true;
    # matches what I'd already typed by hand into userSettings before
    # wiring this up properly: "Catppuccin Mocha" + accentColor "lavender".
    flavor = "mocha";
    accent = "lavender";
    settings = {
      boldKeywords = true;
      italicComments = true;
      italicKeywords = true;
      colorOverrides = {};
      customUIColors = {};
      workbenchMode = "default";
      bracketMode = "rainbow";
      extraBordersEnabled = false;
    };
    # a-file-icon-vscode (set above, nested in the workbench block) is what
    # I actually want for file icons — this module's own icon pack defaults
    # to on, which would fight it, so explicitly off.
    icons.enable = false;
  };
}