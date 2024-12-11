{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.default.vscode;
in
{
  options.default.vscode = with types; {
    enable = mkEnableOption "vscode";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        vscode
    ];
  };
}
