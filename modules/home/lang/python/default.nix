{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.default.lang.python;
in
{
  options.default.lang.python = with types; {
    enable = mkEnableOption "Python Language support";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
        python314
      gcc
      git
      gnumake
      flex
      bison
      gperf
      cmake
      ninja
      ccache
      dfu-util
      libusb1
    ];
  };
}
