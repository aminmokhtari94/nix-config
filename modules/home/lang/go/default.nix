{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.lang.go;
in {
  options.default.lang.go = with types; {
    enable = mkEnableOption "Golang language support";
  };

  config = mkIf cfg.enable {
    programs.go = { enable = true; };
    home.packages = with pkgs; [ gopls gnumake protobuf buf gcc ];
    home.sessionPath = [ "$HOME/go/bin" ];
  };
}
