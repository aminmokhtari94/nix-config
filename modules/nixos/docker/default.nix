{ config, lib, ... }:
with lib;
let cfg = config.default.docker;
in {
  options.default.docker = with types; { enable = mkEnableOption "docker"; };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      # storageDriver = "btrfs";
      daemon.settings = {
        registry-mirrors =
          [ "https://docker.arvancloud.ir" "https://hub.hamdocker.ir" ];
      };
      extraOptions = "--iptables"; # --insecure-registry localhost:5000
    };
  };
}
