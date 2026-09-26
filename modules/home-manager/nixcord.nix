{ inputs, ... }:
{
  programs.nixcord = {
    enable = true;

    # Enable Vesktop correctly as a top-level attribute
    vesktop.enable = true;

    config = {
      useQuickCss = true; # Required for themeLinks to work
      themeLinks = [
        "https://capnkitten.github.io/Material-Discord/Material-Discord.theme.css"
      ];
      
      plugins = {
        addAttachments.enable = true;
        betterFolders = {
          enable = true;
          sidebar = false;
        };
        clearUrls.enable = true;
        concatenatedComponentExtractor.enable = true;
        crashHandler.enable = true;
        disableDeepLinks.enable = true;
        fixYoutubeEmbeds.enable = true;
        noTrack.enable = true;
        settings.enable = true;
        supportHelper.enable = true;
        tenorGifSearch.enable = true;
        translate.enable = true;
        webContextMenus.enable = true;
        webKeybinds = {
          enable = true;
          overrideCommonKeybinds = true;
        };
        webScreenShareFixes.enable = true;
      };
    };
  };
}