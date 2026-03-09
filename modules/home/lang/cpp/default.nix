{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.lang.cpp;
in
{
  options.default.lang.cpp = with types; {
    enable = mkEnableOption "C/C++ language support";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gcc
      clang-tools
      cmake
      gnumake
      gdb
    ];
    programs.nixvim = {
      plugins.dap.enable = true;
    };
  };
}
