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
      gnome.nautilus
      mpv
      okular
      # text & font helper
      font-manager
      wofi-emoji
    ];
  };
}
