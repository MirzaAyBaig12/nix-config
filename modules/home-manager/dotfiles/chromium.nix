{ 
  lib, 
  ... 
}:

# Declarative extensions for Chromium-based browsers using the
# "External Extensions" mechanism: one <id>.json per extension.
let
  updateUrl = "https://clients2.google.com/service/update2/crx";

  extensions = {
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";
    proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
    modern-wikipedia = "emdkdnnopdnajipoapepbeeiemahbjcn";
  };

  # Helper function to generate the config entries for a given browser directory
  mkExtensionFiles = browserDir: lib.mapAttrs' (
    _name: id:
    lib.nameValuePair "${browserDir}/External Extensions/${id}.json" {
      text = builtins.toJSON { external_update_url = updateUrl; };
    }
  ) extensions;
in
{
  xdg.configFile = (mkExtensionFiles "net.imput.helium") // (mkExtensionFiles "chromium");
}