{ pkgs, ... }:
# LibreWolf through enterprise policies: preferences and extensions are set in
# programs.firefox.policies, no Home Manager profile involved.
let
  # Force-install an extension straight from AMO.
  amo = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };

  locked = value: {
    Value = value;
    Status = "locked";
  };
in
{
  programs.firefox = {
    enable = true;
    package = pkgs.librewolf;

    policies = {
      Preferences = {
        # Websites see prefers-color-scheme: dark (0 = dark, 1 = light, 2 = system).
        "layout.css.prefers-color-scheme.content-override" = locked 0;

        # LibreWolf turns resistFingerprinting on by default, and RFP forces
        # prefers-color-scheme back to light. Use the lighter FPP instead and
        # keep it away from the color scheme.
        "privacy.resistFingerprinting" = locked false;
        "privacy.fingerprintingProtection" = locked true;
        "privacy.fingerprintingProtection.overrides" = locked "-CSSPrefersColorScheme";

        # Catppuccin theme (installed below), still switchable from about:addons.
        "extensions.activeThemeID" = {
          Value = "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}";
          Status = "default";
        };
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = amo "ublock-origin";
        "78272b6fa58f4a1abaac99321d503a20@proton.me" = amo "proton-pass";
        "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = amo "styl-us";
        "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = amo "violentmonkey";
        "sponsorBlocker@ajay.app" = amo "sponsorblock";
        "SaveImageAsType@d7om.dev" = amo "siat";

        # Catppuccin Mocha - Mauve (official theme).
        "{76aabc99-c1a8-4c1e-832b-d4f2941d5a7a}" = amo "catppuccin-mocha-mauve-git";
      };
    };
  };

  # LibreWolf reads policies from /etc/librewolf, not /etc/firefox.
  environment.etc."firefox/policies/policies.json".target = "librewolf/policies/policies.json";
}
