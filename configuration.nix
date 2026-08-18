# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix #import hardware configuration 

    #modules 
      ./modules/system.nix #import system configuration module
      ./modules/desktop.nix #import desktop configuration module
      ./modules/programs.nix #import programs configuration module
      ./modules/services.nix #import services configuration module
      ./modules/flatpak.nix #import flatpak configuration module
      
    #import home-manager module
      inputs.home-manager.nixosModules.default
      ./modules/home-manager.nix #import home-manager configuration module

  ];

  # Lix — swaps in Lix from nixpkgs' own lixPackageSets, which always
  # tracks the exact Lix version matching this pinned nixpkgs, so there's
  # never a version-mismatch warning like with the external lix-module flake
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable) nixpkgs-review nix-eval-jobs nix-fast-build colmena;
    })
  ];
  nix.package = pkgs.lixPackageSets.stable.lix;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "ayaan_mirza" ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "26.05";
} 