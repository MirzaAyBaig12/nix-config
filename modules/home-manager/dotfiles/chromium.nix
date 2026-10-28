{ ... }:

# One extension list, fed to both browsers. The modules live in the
# nix-ext-packages flake (programs.{ungoogled-chromium,helium}.extensions).
let
  extensionsList = {
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";
    proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
    modern-wikipedia = "emdkdnnopdnajipoapepbeeiemahbjcn";
    free-download-manager = "ahmpjcflkgiildlgicmcieglgoilbfdp";
    save-image-as-type = "agddafeppiiohhalnjfhcfjemjjcgmcb";
    violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
  };
in
{
  programs.ungoogled-chromium.extensions = {
    enable = true;
    ids = extensionsList;
  };

  programs.helium.extensions = {
    enable = true;
    ids = extensionsList;
  };
}
