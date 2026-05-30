{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.agent.codex;
in
{
  options.default.agent.codex = with types; {
    enable = mkEnableOption "Enable codex ai agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      codex
      openspec
      rtk
    ];
  };
}
