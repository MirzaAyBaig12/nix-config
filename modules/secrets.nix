{ config, inputs, ... }:

{
  sops.defaultSopsFile = "${inputs.nix-secrets}/Axiom/keys/ssh.yaml";
  sops.age.keyFile = "/home/ayaan_mirza/nix-secrets/Axiom/age.txt";

  sops.secrets.ssh-private-key = {
    key = "id_ed25519";
    owner = config.users.users.ayaan_mirza.name;
    group = config.users.users.ayaan_mirza.group;
    mode = "0400";
  };
}
