{ inputs, lib, ... }:

# fx-autoconfig's profile half (utils/, CSS/, resources/) for one LibreWolf profile.
# (the config.js half lives in modules/programs.nix via extraPrefsFiles)
# Update: nix flake update fx-autoconfig -> rebuild
let
  # LibreWolf profile to install into (relative to $HOME)
  chrome = ".config/librewolf/librewolf/f4jwAmgv.Profile 1/chrome";

  fx = "${inputs.fx-autoconfig}/profile/chrome";

  # fx-autoconfig's utils/, minus chrome.manifest (see below)
  utilsFiles = [
    "boot.sys.mjs"
    "fs.sys.mjs"
    "module_loader.mjs"
    "uc_api.sys.mjs"
    "utils.sys.mjs"
  ];
in
{
  home.file = {
    "${chrome}/CSS".source = "${fx}/CSS";
    "${chrome}/resources".source = "${fx}/resources";

    # Natsumi Append's chrome.manifest (from the Natsumi README). The natsumi/ paths
    # simply don't resolve until you put Natsumi's natsumi/ folder into chrome/.
    "${chrome}/utils/chrome.manifest".text = ''
      content userchromejs ./
      content userscripts ../natsumi/scripts/
      skin userstyles classic/1.0 ../CSS/
      content userchrome ../resources/
      content natsumi ../natsumi/
      content natsumi-icons ../natsumi/icons/
    '';
  }
  // lib.genAttrs (map (n: "${chrome}/utils/${n}") utilsFiles) (
    path: { source = "${fx}/utils/${baseNameOf path}"; }
  );
}
