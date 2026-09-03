{ config, pkgs, lib, ... }:

{

  # User Account
  users.users."ayaan_mirza" = {
    isNormalUser = true;
    description = "Ayaan Mirza";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Snap & Flatpak (declarative — see flatpak.nix)
  services.snap.enable = false;
  services.flatpak.enable = true;


  # Security & Privileges (Doas & Sudo)
  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "ayaan_mirza" ];
    keepEnv = true;
    persist = true;
  }];

  security.sudo.enable = true;

  security.apparmor.enable = true; #Enable AppArmor for Snap confinement

  # Re-install rEFInd and re-sign it after every rebuild (chainloads
  # Lanzaboote's signed UKIs + Windows). Activation scripts already run
  # as root, so no doas here — doas caused emergency-mode boot failures
  # on gens 133/134 (PAM helper wasn't reachable this early in boot).
  # PATH is extended because activation scripts run with a stripped PATH
  # that doesn't include sed/coreutils, which refind-install needs internally.
  system.activationScripts.refind-sign = {
    text = ''
      export PATH="${lib.makeBinPath [ pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.gnugrep pkgs.util-linux ]}:$PATH"
      ${pkgs.refind}/bin/refind-install --yes
      ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/refind/refind_x64.efi
    '';
    deps = [ ];
  };

  system.activationScripts.systemd-boot-sign = {
    text = ''
      export PATH="${lib.makeBinPath [ pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.gnugrep pkgs.util-linux ]}:$PATH"
      ${pkgs.sbctl}/bin/sbctl sign /boot/EFI/systemd/systemd-bootx64.efi
    '';
    deps = [ ];
  };

  #Enable USBMUXD for iOS device management
  services.usbmuxd.enable = true;

  # CUPS printing — using hplip drivers only (hp-* GUI utilities are
  # broken on python3.14, see hplip URLopener issue; CUPS web UI at
  # localhost:631 doesn't depend on those scripts, drivers still work)
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enables scanning support (also uses hplip's sane backend)
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];

  # Printer/scanner discovery on the local network
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Watches for Flatpaks installed outside of Nix (e.g. via Bazaar) and
  # appends them into flatpak.nix, correctly formatted for flathub vs cosmic.
  # Script itself is defined in flatpak.nix (options.custom.flatpakSyncScript).
  # Systemd user service to execute the sync script
  systemd.user.services.flatpak-app-sync = {
    description = "Periodic sync for unmanaged Flatpaks into flatpak.nix";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.custom.flatpakSyncScript}/bin/sync-flatpak-apps";
    };
  };


  systemd.user.timers.flatpak-app-sync = {
    description = "Timer to run Flatpak sync every 5 seconds";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "15s";
      # You can safely delete the 'Unit =' line since it matches the timer name, 
      # or change it to: Unit = "flatpak-app-sync.service";
     };
  };

}
