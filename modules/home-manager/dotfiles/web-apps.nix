{
  config,
  lib,
  ...
}:
let
  run = "chromium --no-first-run";
  iconDir = ../../../.config/misc/icons;

  mkWebApp =
    {
      name,
      host,
      icon,
      categories ? [ "Network" ],
    }:
    let
      wmClass = "chrome-${host}__-Default";
    in
    {
      type = "Application";
      inherit name categories;

      exec = "${run} --app=https://${host} --class=${wmClass} --name=${wmClass}";
      icon = "${iconDir}/${icon}";

      terminal = false;
      noDisplay = false;
      startupNotify = false;

      settings.StartupWMClass = wmClass;
    };
in
{
  xdg.desktopEntries = {
    github = mkWebApp {
      name = "GitHub";
      host = "www.github.com";
      icon = "Github.png";
    };

    movy = mkWebApp {
      name = "Movy";
      host = "movy.sx";
      icon = "movy.png";
    };

    cineby = mkWebApp {
      name = "Cineby";
      host = "cineby.rocks";
      icon = "cineby.png";
      categories = [ "AudioVideo" "Video" ];
    };

    duolingo = mkWebApp {
      name = "Duolingo";
      host = "www.duolingo.com";
      icon = "duolingo.png";
      categories = [ "Education" ];
    };

    gemini = mkWebApp {
      name = "Google Gemini";
      host = "gemini.google.com";
      icon = "gemini.png";
    };

    ixl = mkWebApp {
      name = "IXL";
      host = "www.ixl.com";
      icon = "ixl.png";
    };

    nixpkgs-search = mkWebApp {
      name = "Nixpkgs Search";
      host = "search.nixos.org";
      icon = "nixpkgs-search.png";
      categories = [ "Utility" ];
    };

    reddit = mkWebApp {
      name = "Reddit";
      host = "www.reddit.com";
      icon = "reddit.png";
    };

    youtube = mkWebApp {
      name = "Youtube";
      host = "youtube.com";
      icon = "youtube.png";
      categories = [ "AudioVideo" "Video" ];
    };
  };
}
