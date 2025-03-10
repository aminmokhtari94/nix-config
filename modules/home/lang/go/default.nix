{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.lang.go;
in {
  options.default.lang.go = with types; {
    enable = mkEnableOption "Golang Language support";
  };

  config = mkIf cfg.enable {
    programs.go = { enable = true; };
    home.packages = with pkgs; [ gopls gnumake buf ];
    home.sessionPath = [ "$HOME/go/bin" ];
  };
}
