{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.desktop.wine;
in
{
  options.default.desktop.wine = with types; {
    enable = mkEnableOption "wine";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wineWowPackages.staging
      winetricks
    ];
  };
}
