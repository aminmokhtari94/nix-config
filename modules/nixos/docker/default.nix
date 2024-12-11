{ ... }:

{
  virtualisation.docker = {
    enable = true;
  # storageDriver = "btrfs";
    daemon.settings = {
      registry-mirrors = [
        "https://hub.hamdocker.ir"
      ];
    };
  };
}
