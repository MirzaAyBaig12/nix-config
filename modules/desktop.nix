{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

  let
    # my material design 3 fork of bibata cursors (nixpkgs' bibata-cursors doesnt have
    # material variants). packaged in nix-ext-packages
    # (packages/bibata-material-cursor.nix, bumped by its update script)
    # exposed as custom.bibataMaterialCursor so programs.nix and home-manager use the
    # same build instead of each declaring it again
    bibataMaterialCursor =
      inputs.nix-ext-packages.packages.${pkgs.stdenv.hostPlatform.system}.bibata-material-cursor;
  in
  
{
  options.custom.bibataMaterialCursor = lib.mkOption {
    type = lib.types.package;
    internal = true;
    readOnly = true;
    default = bibataMaterialCursor;
    description = "Ayaan's Material Design 3 Bibata cursor fork, packaged in nix-ext-packages.";
  };

  config = {
  # Desktop session and display manager
  services.displayManager.defaultSession = pkgs.lib.mkForce "niri";
  services.displayManager.cosmic-greeter.enable = false;
  services.desktopManager.cosmic.enable = true;

  # Shared cursor theme
  # Bibata-Material-Lilac (see greetd niri_overrides.kdl +
  # systemd.services.greetd.environment below) needs to resolve to a real cursor theme
  # in the SYSTEM profile. greetd runs as its own systemd service with XDG_DATA_DIRS
  # pointing at /run/current-system/sw/share, not my home-manager profile
  environment.systemPackages = [ bibataMaterialCursor ];

  # Greeter configuration
  # dank-greeter's module only wires its package into greetd's own ExecStart, it never
  # puts `dms-greeter` on PATH for my shell (like to run `dms-greeter --command niri`
  # manually or check --version). so adding it explicitly

  # DankGreeter, greetd login screen that matches the DMS theme. compositor has to be
  # "niri" here cuz niri is what's actually installed through the nixos config (see
  # note above the module option), not home-manager. configHome points at my DMS
  # settings.json so the greeter picks up the same theme/accent instead of its own
  # default. uses the flake's own module instead of nixpkgs' vendored one.
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

  # Greeter environment
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

  # Desktop portals and authentication
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing and audio
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Font packages
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
  };
}
