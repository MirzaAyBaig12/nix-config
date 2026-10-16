# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ 
  config, 
  pkgs, 
  inputs, 
  ... 
}:

{
  # Hardware and system modules
  imports = [
    # Hardware-specific generated settings
    ./hardware-configuration.nix

    # System, desktop, programs, and services
    ./modules/system.nix
    ./modules/desktop.nix
    ./modules/programs.nix
    ./modules/services.nix
    ./modules/stylix.nix
    ./modules/flatpak.nix
    ./modules/niri.nix
    ./modules/home-manager.nix
  ];

  # Nix implementation and package policy
  # Lix comes from the lix-module flake input (see flake.nix); don't set nix.package
  # here or it overrides the module.

  nix.settings = {
    experimental-features = [ 
      "nix-command" 
      "flakes" 
    ];
    trusted-users = [
      "root"
      "ayaan_mirza"
    ];
    accept-flake-config = true;
    extra-substituters = [ "https://cache.lix.systems" ];
    extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
  };

  # Locale and system version
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "26.05";
}
