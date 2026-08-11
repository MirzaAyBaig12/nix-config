{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.exfatprogs ];

  fileSystems."/mnt/Shared" = {
    device = "/dev/disk/by-uuid/7AFE-F4AA";
    fsType = "exfat";
    options = [
      "nofail"                    # don't block boot if this fails to mount
      "x-systemd.device-timeout=5" # stop waiting after 5s instead of hanging
      "uid=1000"                  # mount owned by your user, not root
      "gid=100"
      "umask=0022"
    ];
  };
}
