{ 
  lib, 
  ... 
}:

# Declarative extensions for Helium (Chromium-based, profile dir: ~/.config/net.imput.helium).
# Uses Chromium's "External Extensions" mechanism: one <id>.json per extension, pointing at the
# update URL. Helium installs them on next launch. Users can still remove them from the UI.
let
  updateUrl = "https://clients2.google.com/service/update2/crx";

  extensions = {
    stylus = "clngdbkpkpeebahjckkjfobafhncgmne";
    proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
    modern-wikipedia = "emdkdnnopdnajipoapepbeeiemahbjcn";
  };
in
{
  xdg.configFile = lib.mapAttrs' (
    _name: id:
    lib.nameValuePair "net.imput.helium/External Extensions/${id}.json" {
      text = builtins.toJSON { external_update_url = updateUrl; };
    }
  ) extensions;
}
