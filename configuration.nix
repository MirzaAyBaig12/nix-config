# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  nixpkgs.overlays = [ inputs.claude-desktop.overlays.default ];

  imports = [
    ./hardware-configuration.nix #import hardware configuration 
    #modules 
      ./modules/system.nix #import system configuration module
      ./modules/desktop.nix #import desktop configuration module
      ./modules/programs.nix #import programs configuration module
      ./modules/services.nix #import services configuration module
    #import home-manager module
      inputs.home-manager.nixosModules.default
      ./modules/home-manager.nix #import home-manager configuration module
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "26.05";
}