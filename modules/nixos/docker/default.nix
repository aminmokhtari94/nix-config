{ pkgs, ... }:
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
  environment.systemPackages = with pkgs; [
    docker-buildx
  ];
  systemd.services.docker = {
    environment = {
      HTTP_PROXY = "http://192.168.1.228:2080";
      HTTPS_PROXY = "http://192.168.1.228:2080";
      NO_PROXY = "localhost,127.0.0.1,::1";
    };
  };
}
