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
  # using lix from nixpkgs' own lixPackageSets so the version always matches my pinned
  # nixpkgs. no more version mismatch warning like the external lix-module flake gave
  # me
  nix.package = pkgs.lixPackageSets.stable.lix;
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "ayaan_mirza" ];

  # Locale and system version
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "26.05";
}
