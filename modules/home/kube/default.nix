{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.default.kube;
in
{
  options.default.kube = with types; {
    enable = mkEnableOption "kube";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        kubectl
        k9s
        talosctl
        fluxcd
        kubernetes-helm
    ];
  };
}
