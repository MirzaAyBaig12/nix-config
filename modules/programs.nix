{ config, pkgs, inputs, ... }:

{
  # Shell aliases & zsh
  environment.shellAliases = {
    nix-rebuild = "for bn in $(doas efibootmgr | grep -oP '(?<=Boot)[0-9A-Fa-f]{4}(?=\\*? rEFInd)'); do doas efibootmgr -b $bn -B; done; doas nixos-rebuild switch --flake ~/nix-config#Axiom";
    nix-push = "cd ~/nix-config && git add . && git commit -m \"update $(date +%Y-%m-%d_%H:%M)\" && git push";
    nix-clean = "doas nix-env --delete-generations +3 -p /nix/var/nix/profiles/system && doas nix-collect-garbage -d";
    nix-generations = "nix-env -p /nix/var/nix/profiles/system --list-generations";
    sudo-temp = "/run/wrappers/bin/sudo";
    waydroid = "/usr/bin/python3 /usr/bin/waydroid";
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    zsh-autoenv.enable = true;
    syntaxHighlighting.enable = true;s
    interactiveShellInit = ''
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="/var/lib/snapd/snap/bin:$PATH"
      fastfetch -c ~/nix-config/dotfiles/fastfetch/compact-config.jsonc
    '';
    ohMyZsh = {
      enable = true;
      theme = "xiong-chiamiov-plus";
      plugins = [ "git" "npm" "history" "node" "rust" "deno" "snap" ];
    };
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Firefox / Librewolf
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;
    nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
  };

  # AppImage & Nix-LD
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc zlib openssl curl glib libGL fuse3
  ];

  # Codex Desktop
  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # Session Variables
  environment.sessionVariables = {
    PATH = [ "/var/lib/snapd/snap/bin" ];
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git 
    gdb 
    python3 
    firefoxpwa 
    google-chrome 
    fastfetch
    inputs.nix-software-center.packages.${stdenv.hostPlatform.system}.default
    baobab gnome-disk-utility kdePackages.partitionmanager curl
    (pkgs.callPackage ../packages/cosmic-ext-control-center.nix {})
    efibootmgr sbctl claude-desktop-fhs
    (inputs.winpodx.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      doCheck = false;
      checkPhase = "echo skipping winpodx tests";
      installCheckPhase = "echo skipping winpodx tests";
    }))
    kdePackages.kdenlive 
    firefox 
    libsForQt5.qtstyleplugin-kvantum
    inputs.nixos-conf-editor.packages.${pkgs.stdenv.hostPlatform.system}.nixos-conf-editor
    kdePackages.kate 
    gtk4 
    ghostty 
    ferdium 
    parted 
    polkit_gnome 
    nodejs 
    sassc 
    seahorse 
    gnome-keyring 
    just 
    refind 
    wl-clipboard
    inputs.efiboots.packages.${pkgs.system}.default
  ];
}