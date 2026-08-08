{ config, pkgs, ... }:

{
  # Snap & Flatpak
  services.snap.enable = true;
  services.flatpak.enable = true;

  # Security & Doas
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "ayaan_mirza" ];
    keepEnv = true;
    persist = true;
  }];

  # User Account
  users.users."ayaan_mirza" = {
    isNormalUser = true;
    description = "Ayaan Mirza";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Fastfetch dotfile sync
  environment.etc."xdg/fastfetch/config.jsonc".source = ../dotfiles/fastfetch/config.jsonc;

  system.activationScripts.fastfetchSymlink = ''
    mkdir -p /home/ayaan_mirza/.config/fastfetch
    ln -sf /home/ayaan_mirza/nix-config/dotfiles/fastfetch/config.jsonc /home/ayaan_mirza/.config/fastfetch/config.jsonc
    chown -h ayaan_mirza:users /home/ayaan_mirza/.config/fastfetch/config.jsonc
  '';
}