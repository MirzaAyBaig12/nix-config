{ config, pkgs, ... }:

{
  # Display Managers & Desktop Environments
  services.xserver.enable = true;
  services.displayManager.defaultSession = pkgs.lib.mkForce "cosmic";
  services.displayManager.cosmic-greeter.enable = true;

  # greetd runs as a bare systemd service (user "cosmic-greeter"), not a
  # login-shell session — it never sees environment.variables in system.nix
  # (that's PAM/session-only), and greetd.toml only substitutes
  # ${XCURSOR_THEME:-Pop} explicitly, so without this it silently falls
  # back to the stock Pop cursor regardless of what's set for ayaan_mirza.
  # XCURSOR_SIZE isn't referenced in that fallback at all, but still gets
  # passed through since `env` only overrides the one var it's given and
  # inherits the rest of the service's environment as-is.
  systemd.services.greetd.environment = {
    XCURSOR_THEME = "Bibata-Material-Slate";
    XCURSOR_SIZE = "24";
  };

  services.desktopManager.cosmic.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pantheon.apps.enable = false;

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