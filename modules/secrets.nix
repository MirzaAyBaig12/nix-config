{ config, inputs, pkgs, ... }:

{
  # The `agenix` command (create/edit/rekey secrets).
  environment.systemPackages = [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Machine key agenix uses to decrypt at boot. Make it once with:
  #   sudo ssh-keygen -t ed25519 -N "" -C axiom-host -f /etc/ssh/ssh_host_ed25519_key
  # (sshd does not need to be enabled.)
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Your GitHub SSH key. Decrypted to /run/agenix/ssh-private-key at boot.
  age.secrets.github-ssh-key = {
    file = "${inputs.nix-secrets}/secrets/github-ssh-key.age";
    owner = config.users.users.ayaan_mirza.name;
    group = config.users.users.ayaan_mirza.group;
    mode = "0400";
  };
  age.secrets.wifi = {
    file = "${inputs.nix-secrets}/secrets/wifi.age";
    owner = "root";
    mode = "0400";
  };

  # Cloudflare API token (wrangler / API). Decrypted to /run/agenix/cloudflare-api-token;
  # zsh exports it as CLOUDFLARE_API_TOKEN (see home-manager/dotfiles/zsh.nix).
  age.secrets.cloudflare-api-token = {
    file = "${inputs.nix-secrets}/secrets/cloudflare-api-token.age";
    owner = config.users.users.ayaan_mirza.name;
    group = config.users.users.ayaan_mirza.group;
    mode = "0400";
  };

  # Add more secrets below. `node scripts/add-secret.mjs` in ~/nix-secrets
  # prints a ready-to-paste block for each one.
}
