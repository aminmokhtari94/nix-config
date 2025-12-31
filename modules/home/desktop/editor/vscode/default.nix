{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.desktop.editor.vscode;
in
{
  options.default.desktop.editor.vscode = with types; {
    enable = mkEnableOption "vscode";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ vscode ]; };
}
