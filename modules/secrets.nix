{ config, inputs, ... }:

{
  sops.defaultSopsFile = "${inputs.nix-secrets}/ssh.yaml";
  sops.age.keyFile = "/home/ayaan_mirza/.config/sops/age/keys.txt";

  sops.secrets.ssh-private-key = {
    key = "id_ed25519";
    owner = config.users.users.ayaan_mirza.name;
    group = config.users.users.ayaan_mirza.group;
    mode = "0400";
  };
}
