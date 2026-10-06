{ config, ... }:

{
  xdg.desktopEntries."github" = {
    type = "Application";
    name = "GitHub";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://www.github.com\" --class=chrome-www.github.com__-Default --name=chrome-www.github.com__-Default";

    icon = "${../../.config/misc/icons/Github.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Network" ];

    settings = {
      StartupWMClass = "chrome-www.github.com__-Default";
    };
  };

  xdg.desktopEntries."movy" = {
    type = "Application";
    name = "Movy";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://movy.sx\" --class=chrome-movy.sx__-Default --name=chrome-movy.sx__-Default";

    icon = "${../../.config/misc/icons/movy.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Network" ];

    settings = {
      StartupWMClass = "chrome-movy.sx__-Default";
    };
  };

  xdg.desktopEntries."cineby" = {
    type = "Application";
    name = "Cineby";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://cineby.rocks\" --class=chrome-cineby.rocks__-Default --name=chrome-cineby.rocks__-Default";

    icon = "${../../.config/misc/icons/cineby.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "AudioVideo" "Video" ];

    settings = {
      StartupWMClass = "chrome-cineby.rocks__-Default";
    };
  };

  xdg.desktopEntries."duolingo" = {
    type = "Application";
    name = "Duolingo";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://www.duolingo.com\" --class=chrome-www.duolingo.com__-Default --name=chrome-www.duolingo.com__-Default";

    icon = "${../../.config/misc/icons/duolingo.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Education" ];

    settings = {
      StartupWMClass = "chrome-www.duolingo.com__-Default";
    };
  };

  xdg.desktopEntries."gemini" = {
    type = "Application";
    name = "Google Gemini";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://gemini.google.com\" --class=chrome-gemini.google.com__-Default --name=chrome-gemini.google.com__-Default";

    icon = "${../../.config/misc/icons/gemini.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Network" ];

    settings = {
      StartupWMClass = "chrome-gemini.google.com__-Default";
    };
  };

  xdg.desktopEntries."ixl" = {
    type = "Application";
    name = "IXL";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://www.ixl.com\" --class=chrome-www.ixl.com__-Default --name=chrome-www.ixl.com__-Default";

    icon = "${../../.config/misc/icons/ixl.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Network" ];

    settings = {
      StartupWMClass = "chrome-www.ixl.com__-Default";
    };
  };

  xdg.desktopEntries."nixpkgs-search" = {
    type = "Application";
    name = "Nixpkgs Search";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://search.nixos.org\" --class=chrome-search.nixos.org__-Default --name=chrome-search.nixos.org__-Default";

    icon = "${../../.config/misc/icons/nixpkgs-search.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Utility" ];

    settings = {
      StartupWMClass = "chrome-search.nixos.org__-Default";
    };
  };

  xdg.desktopEntries."reddit" = {
    type = "Application";
    name = "Reddit";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://www.reddit.com\" --class=chrome-www.reddit.com__-Default --name=chrome-www.reddit.com__-Default";

    icon = "${../../.config/misc/icons/reddit.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "Network" ];

    settings = {
      StartupWMClass = "chrome-www.reddit.com__-Default";
    };
  };

  xdg.desktopEntries."youtube" = {
    type = "Application";
    name = "Youtube";

    exec = "flatpak run io.github.ungoogled_software.ungoogled_chromium --no-first-run --app=\"https://youtube.com\" --class=chrome-youtube.com__-Default --name=chrome-youtube.com__-Default";

    icon = "${../../.config/misc/icons/youtube.png}";

    terminal = false;
    noDisplay = false;
    startupNotify = false;
    categories = [ "AudioVideo" "Video" ];

    settings = {
      StartupWMClass = "chrome-youtube.com__-Default";
    };
  };
}