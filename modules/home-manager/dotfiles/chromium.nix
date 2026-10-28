{ lib, ... }:

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

  # Toolbar-pinned. Names from extensionsList (or "ublock-origin", chromium
  # only), or raw ids.
  pinnedExtensions = [
    "ublock-origin"
    "proton-pass"
    "stylus"
    "violentmonkey"
  ];
in
{
  programs.ungoogled-chromium.extensions = {
    enable = true;
    ids = extensionsList;
    pinned = pinnedExtensions;
    # uBlock Origin is installed automatically (uBlockOrigin = true by default).
  };

  programs.helium.extensions = {
    enable = true;
    ids = extensionsList;
    # uBlock Origin is ungoogled-chromium only.
    pinned = lib.remove "ublock-origin" pinnedExtensions;
  };

  # No browsers are installed here: Helium and the wrapped ungoogled-chromium
  # (programs.ungoogled-chromium.extensions.wrapped) are listed in programs.nix.
}
