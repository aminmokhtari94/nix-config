{ lib, config, ... }:

with lib;
let
  cfg = config.default.desktop.nm-applet;
in
{
  options.default.desktop.nm-applet = with types; {
    enable = mkEnableOption "nm-applet";
  };

  config = {
    services.network-manager-applet.enable = cfg.enable;
  };
}
