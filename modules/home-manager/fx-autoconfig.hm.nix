{ 
  inputs,
  lib,
  ... 
}:

# profile half of fx-autoconfig (utils/, CSS/, resources/) for one librewolf profile.
# the config.js half lives in modules/programs.nix via extraPrefsFiles
# to update: nix flake update fx-autoconfig, then rebuild
let
  # librewolf profile to install into (relative to $HOME)
  chrome = ".config/librewolf/librewolf/f4jwAmgv.Profile 1/chrome";

  fx = "${inputs.fx-autoconfig}/profile/chrome";

  # utils/ from fx-autoconfig without chrome.manifest (see below)
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

    # chrome.manifest for natsumi append (from the natsumi readme). the natsumi/ paths
    # wont resolve until natsumi's natsumi/ folder is in chrome/
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
