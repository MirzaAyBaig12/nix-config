{ 
  lib, 
  ... 
}:
# One extension list, fed to both browsers. The modules live in the
# nix-ext-packages flake (programs.{ungoogled-chromium,helium}.extensions).
let
  extensionsList = {
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";
    proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
    modern-wikipedia = "emdkdnnopdnajipoapepbeeiemahbjcn";
    free-download-manager = "ahmpjcflkgiildlgicmcieglgoilbfdp";
    save-as-type = "kapklhhpcnelfhlendhjfhddcddfabaps";
    violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
    helium-shimmer-tab = "acgnlhjcipkagocfggidelbghodlddmm";
  };

  pinnedExtensions = [
    "ublock-origin"
    "proton-pass"
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
    # uBlock Origin is ungoogled-chromium only; Helium ships its own built-in uBO,
    # raw id below, so pin it explicitly (pinned is authoritative now).
    pinned = pinnedExtensions;
  };
}
