{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.agent.claude;
in
{
  options.default.agent.claude = with types; {
    enable = mkEnableOption "Enable claude code ai agent";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      claude-code-bin
    ];
  };
}
