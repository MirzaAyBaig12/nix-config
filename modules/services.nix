{ config, pkgs, ... }:

{
  # Snap & Flatpak
  services.snap.enable = true;
  services.flatpak.enable = true;

  # Security & Privileges (Doas & Sudo)
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "ayaan_mirza" ];
    keepEnv = true;
    persist = true;
  }];

  security.sudo.enable = true;

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

  # 1. Repo -> Boot (Pushes your git changes to the EFI partition on every nixos-rebuild)
  system.activationScripts.syncRefindToBoot = ''
    if [ -d /boot/EFI/refind ] && [ -d /home/ayaan_mirza/nix-config/dotfiles/refind ]; then
      cp -rf /home/ayaan_mirza/nix-config/dotfiles/refind/* /boot/EFI/refind/
    fi
  '';

  # 2. Boot -> Repo (Pushes live changes made in EFI to your git repo on startup)
  systemd.services.syncRefindToRepo = {
    description = "Sync manual rEFInd changes back to dotfiles repo";
    wantedBy = [ "multi-user.target" ];
    script = ''
      REFIND_ESP="/boot/EFI/refind"
      REFIND_REPO="/home/ayaan_mirza/nix-config/dotfiles/refind"

      if [ -d "$REFIND_ESP" ] && [ -d "$REFIND_REPO" ]; then
        # Copy newer files from ESP back to the repo
        cp -ru "$REFIND_ESP"/* "$REFIND_REPO"/
        chown -R ayaan_mirza:users "$REFIND_REPO"
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}