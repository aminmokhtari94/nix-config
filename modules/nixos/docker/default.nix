{ ... }:
{
  virtualisation.docker = {
    enable = true;
    # storageDriver = "btrfs";
    daemon.settings = {
      registry-mirrors = [
        "https://docker.arvancloud.ir"
        "https://hub.hamdocker.ir"
      ];
    };
    extraOptions = "--iptables"; # --insecure-registry localhost:5000
  };
}
