{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

  let
    # Ayaan's Material Design 3 fork of Bibata cursors (not nixpkgs'
    # bibata-cursors, which has no Material variants). Packaged from the
    # prebuilt release tarball — on a new release: nix-prefetch-url --type
    # sha256 <url>, then nix hash convert --hash-algo sha256 <hash>, bump
    # version+hash below. Lives here (rather than its own packages/*.nix)
    # since this is the only module that actually needs it, exposed below
    # via custom.bibataMaterialCursor so programs.nix and home-manager can
    # reference the same build instead of each re-declaring it.
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

  # Bibata-Material-Lilac (see below: greetd niri_overrides.kdl +
  # systemd.services.greetd.environment) has to actually resolve to a
  # real cursor theme in the SYSTEM profile — greetd runs as its own
  # systemd service with XDG_DATA_DIRS pointed at
  # /run/current-system/sw/share, not the user's home-manager profile.
  environment.systemPackages = [ bibataMaterialCursor ];

  # dank-greeter's module only wires its package into greetd's own
  # ExecStart — it never puts `dms-greeter` on PATH for your own shell
  # (e.g. to run `dms-greeter --command niri` manually, check --version,
  # etc). Add it explicitly.

  # DankGreeter — greetd login screen matching DMS's theme. Compositor
  # must be "niri" here since niri is what's actually installed via
  # NixOS config (see note above the module option), not home-manager.
  # configHome points at your user's DMS settings.json so the greeter
  # picks up the same theme/accent instead of its own default.
  # Back on the flake's own module (not nixpkgs' vendored one) — see
  # flake.nix input #21 for why.
  programs.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
      # Explicit cursor for the greeter's own niri instance — doesn't
      # depend on theme-sync/ACLs working, always applies.

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

  # greetd runs as a bare systemd service (user "cosmic-greeter"), not a
  # login-shell session — it never sees environment.variables in system.nix
  # (that's PAM/session-only), and greetd.toml only substitutes
  # ${XCURSOR_THEME:-Pop} explicitly, so without this it silently falls
  # back to the stock Pop cursor regardless of what's set for ayaan_mirza.
  # XCURSOR_SIZE isn't referenced in that fallback at all, but still gets
  # passed through since `env` only overrides the one var it's given and
  # inherits the rest of the service's environment as-is.
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
