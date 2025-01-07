{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.default.desktop;
in
{
  options.default.desktop = with types; {
    enable = mkEnableOption "desktop";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # files & multimedia
      nautilus
      mpv
      okular
      # text & font helper
      font-manager
      wofi-emoji

      gnome-calculator
      telegram-desktop

      # deveopment
      mongodb-compass
      mqtt-explorer
      redisinsight

      blender
      postman
      winbox4
    ];
  };
}
