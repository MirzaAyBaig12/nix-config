{ osConfig, ... }:

{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Ayaan Mirza";
      email = "mirzaaybaig12@icloud.com";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
    settings."github.com" = {
      IdentityFile = osConfig.sops.secrets.ssh-private-key.path;
      IdentitiesOnly = true;
    };
  };
}
