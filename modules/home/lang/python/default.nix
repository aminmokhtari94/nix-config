{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.lang.python;
in
{
  options.default.lang.python = with types; {
    enable = mkEnableOption "Python language support";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ python314 ]; };
}
