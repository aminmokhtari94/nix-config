{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.lang.nodejs;
in
{
  options.default.lang.nodejs = with types; {
    enable = mkEnableOption "nodejs language support";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      pnpm
    ];
  };
}
