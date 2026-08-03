{ config, lib, ... }:
with lib;
let
  cfg = config.default.netbird;
in
{
  options.default.netbird = with types; {
    enable = mkEnableOption "netbird";
    ui.enable = mkEnableOption "netbird ui";
  };

  config = mkIf cfg.enable {

    services.netbird = {
      enable = true;
      # Upstream defaults this to the presence of a graphical session; pin it
      # explicitly so headless hosts don't pull in the tray client.
      ui.enable = cfg.ui.enable;
    };
  };
}
