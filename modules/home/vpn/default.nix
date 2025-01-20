{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.vpn;
in {
  options.default.vpn = with types; { enable = mkEnableOption "vpn"; };

  config = mkIf cfg.enable { home.packages = with pkgs; [ openvpn ]; };
}
