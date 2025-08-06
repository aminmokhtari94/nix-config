{ config, lib, ... }:
with lib;
let cfg = config.default.v2ray;
in {
  options.default.v2ray = with types; { enable = mkEnableOption "v2ray"; };

  config = mkIf cfg.enable {

    programs.nekoray = {
      enable = true;
      tunMode.enable = true;
    };
  };
}
