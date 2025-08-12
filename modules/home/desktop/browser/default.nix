{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.desktop.browser;
in {
  options.default.desktop.browser = with types; {
    enable = mkEnableOption "Enable google-chrome browser";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ google-chrome ]; };
}
