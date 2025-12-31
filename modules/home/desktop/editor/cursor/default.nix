{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.desktop.editor.cursor;
in
{
  options.default.desktop.editor.cursor = with types; {
    enable = mkEnableOption "cursor";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ code-cursor ]; };
}
