{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.desktop;
in {
  options.default.desktop = with types; {
    enable = mkEnableOption "desktop";

    apps = mkOption {
      type = listOf package;
      default = [ ];
      description = "List of desktop applications ";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        default.wallpaper-manager
        # files & multimedia
        nautilus
        mpv

        # text & font helper
        # font-manager
        # wofi-emoji

        gnome-calculator
        telegram-desktop

        winbox4
      ] ++ cfg.apps;
  };
}
