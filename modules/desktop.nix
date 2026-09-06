{ config, pkgs, ... }:

{
  # Display Managers & Desktop Environments
  services.displayManager.defaultSession = pkgs.lib.mkForce "niri";
  services.displayManager.cosmic-greeter.enable = false;
  services.desktopManager.cosmic.enable = true;

  # DankGreeter — greetd login screen matching DMS's theme. Compositor
  # must be "niri" here since niri is what's actually installed via
  # NixOS config (see note above the module option), not home-manager.
  # configHome points at your user's DMS settings.json so the greeter
  # picks up the same theme/accent instead of its own default.
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
          xcursor-size 24
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
    XCURSOR_SIZE = "24";
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
}