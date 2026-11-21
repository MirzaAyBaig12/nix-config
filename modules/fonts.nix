{ 
  config, 
  pkgs, 
  ... 
}:

# Flatpak looks for host fonts/icons in /usr/share/{fonts,icons} (exposed to apps as
# /run/host/*). NixOS has no /usr/share/fonts, so flatpak apps get zero fonts and render
# tofu boxes. Workaround from the NixOS wiki: read-only bindfs mounts of aggregated
# font/icon trees at those paths.
let
  mkRoSymBind = path: {
    device = path;
    fsType = "fuse.bindfs";
    options = [
      "ro"
      "resolve-symlinks"
      "x-gvfs-hide"
    ];
  };

  aggregatedIcons = pkgs.buildEnv {
    name = "system-icons";
    paths = with pkgs; [
      papirus-icon-theme
      adwaita-icon-theme
    ];
    pathsToLink = [ "/share/icons" ];
  };

  aggregatedFonts = pkgs.buildEnv {
    name = "system-fonts";
    paths = config.fonts.packages;
    pathsToLink = [ "/share/fonts" ];
  };
in
{
  system.fsPackages = [ pkgs.bindfs ];

  fileSystems = {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
  };
}
