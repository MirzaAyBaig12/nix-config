{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

  let
    # my material design 3 fork of bibata cursors (nixpkgs' bibata-cursors doesnt have
    # material variants)
    # packaged from the prebuilt release tarball. on a new release: nix-prefetch-url
    # --type sha256 <url>, then nix hash convert --hash-algo sha256 <hash>, and bump
    # version + hash below
    # lives here instead of its own packages/*.nix cuz this is the only module that
    # needs it. exposed as custom.bibataMaterialCursor so programs.nix and
    # home-manager use the same build instead of each declaring it again
    bibataMaterialCursor = pkgs.stdenv.mkDerivation (finalAttrs: {
      pname = "bibata-material-cursor";
     version = "1.2.1";

     src = pkgs.fetchurl {
        url = "https://github.com/SakibShahariar/material-bibata-cursor/releases/download/v${finalAttrs.version}/bibata-material-v${finalAttrs.version}.tar.gz";
        hash = "sha256-/B/l+F3CVmJkwPJv/meabvkVpZbXa8Tt7O2MyANheXk=";
      };

     dontBuild = true;
      installPhase = ''
       mkdir -p $out/share/icons
        cp -r Bibata-Material-* $out/share/icons/
     '';

     meta = with lib; {
       description = "28 Bibata cursor themes using Material Design 3's tonal system (Ayaan's fork)";
       homepage = "https://github.com/SakibShahariar/material-bibata-cursor";
       license = licenses.gpl3Only;
       platforms = platforms.all;
     };
   });
  in
  
{
  options.custom.bibataMaterialCursor = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    default = bibataMaterialCursor;
    description = "Ayaan's Material Design 3 Bibata cursor fork, built inline in desktop.nix.";
  };

  config = {
  # Display Managers & Desktop Environments
  services.displayManager.defaultSession = pkgs.lib.mkForce "niri";
  services.displayManager.cosmic-greeter.enable = false;
  services.desktopManager.cosmic.enable = true;

  # Bibata-Material-Lilac (see greetd niri_overrides.kdl +
  # systemd.services.greetd.environment below) needs to resolve to a real cursor theme
  # in the SYSTEM profile. greetd runs as its own systemd service with XDG_DATA_DIRS
  # pointing at /run/current-system/sw/share, not my home-manager profile
  environment.systemPackages = [ bibataMaterialCursor ];

  # dank-greeter's module only wires its package into greetd's own ExecStart, it never
  # puts `dms-greeter` on PATH for my shell (like to run `dms-greeter --command niri`
  # manually or check --version). so adding it explicitly

  # DankGreeter, greetd login screen that matches the DMS theme. compositor has to be
  # "niri" here cuz niri is what's actually installed through the nixos config (see
  # note above the module option), not home-manager. configHome points at my DMS
  # settings.json so the greeter picks up the same theme/accent instead of its own
  # default. back on the flake's own module instead of nixpkgs' vendored one, see
  # flake.nix input #21 for why
  programs.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
      # explicit cursor for the greeter's own niri instance. doesnt depend on
      # theme-sync/ACLs working so it always applies

    };
    configHome = "/home/ayaan_mirza";
  };

  #Create a Niri Override for greetd
  environment.etc."greetd/niri_overrides.kdl" = {
    text = ''
      hotkey-overlay {
          skip-at-startup
      }

      cursor {
          xcursor-theme "Bibata-Material-Lilac"
          xcursor-size 30
      }
    '';
    mode = "0644";
  };

  # greetd runs as a bare systemd service (user "cosmic-greeter"), not a login shell
  # session, so it never sees environment.variables from system.nix (thats PAM/session
  # only). greetd.toml only substitutes ${XCURSOR_THEME:-Pop} explicitly, so without
  # this it quietly falls back to the stock Pop cursor no matter what i set for
  # ayaan_mirza. XCURSOR_SIZE isnt used in that fallback at all but still gets passed
  # through, cuz `env` only overrides the one var it gets and inherits the rest of the
  # service environment as is
  systemd.services.greetd.environment = {
    XCURSOR_THEME = "Bibata-Material-Lilac";
    XCURSOR_SIZE = "30";
    XDG_DATA_DIRS = "/run/current-system/sw/share";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
  };

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing & Audio
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fonts
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
  };
}
