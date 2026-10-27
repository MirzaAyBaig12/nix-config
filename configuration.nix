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

  users.users.ayaan_mirza.extraGroups = [
    "docker"
    "podman"
    "kvm"
    "video"
    "render"
  ];
  
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

    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://lanzaboote.cachix.org"
      "https://cache.lix.systems"
      "https://noel.cachix.org"
      "https://cache.numtide.com"
      "https://cache.iog.io"
      "https://niri-epireyn.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lanzaboote.cachix.org-1:Nt9//zGmqkg1k5iu+B3bkj3OmHKjSw9pvf3faffLLNk="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "noel.cachix.org-1:pQHbMJOB5h5VqYi3RV0Vv0EaeHfxARxgOhE9j013XwQ="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="
    ];
  };

  # Locale and system version
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "26.05";
}
