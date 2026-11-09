{ osConfig, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
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
      IdentityFile = osConfig.age.secrets.github-ssh-key.path;
      IdentitiesOnly = true;
    };

    # More SSH identities (the helper in ~/nix-secrets prints these blocks):
    # settings."github-work" = {
    #   HostName = "github.com";
    #   User = "git";
    #   IdentityFile = osConfig.age.secrets.ssh-github-work.path;
    #   IdentitiesOnly = true;
    # };
  };
}
