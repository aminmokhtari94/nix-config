{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.cursor;
in {
  options.default.cursor = with types; { enable = mkEnableOption "cursor"; };

  config = mkIf cfg.enable { home.packages = with pkgs; [ code-cursor ]; };
}
