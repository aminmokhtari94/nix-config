{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.kube;
in {
  options.default.kube = with types; { enable = mkEnableOption "kube"; };

  config = mkIf cfg.enable {
    programs.zsh = {
      shellAliases = {
        k = "kubectl";
        t = "talosctl";
      };
    };
    home.packages = with pkgs; [
      kubectl
      k9s
      talosctl
      kustomize
      istioctl
      fluxcd
      kubernetes-helm
      kind
      kubebuilder
      kn
    ];
  };
}
