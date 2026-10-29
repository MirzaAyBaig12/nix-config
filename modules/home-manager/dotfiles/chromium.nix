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
    save-as-type = "kapklhhpcnelfhlendhjfhddcddfabap";
    violentmonkey = "jinjaccalgkegednnccohejagnlnfdag";
    helium-shimmer-tab = "acgnlhjcipkagocfggidelbghodlddmm";
  };

  # Toolbar-pinned: names from extensionsList, or raw ids. uBlock Origin is
  # pinned automatically (ungoogled-chromium via the module, Helium itself),
  # no need to list it.
  pinnedExtensions = [
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
    pinned = pinnedExtensions;
  };
}
