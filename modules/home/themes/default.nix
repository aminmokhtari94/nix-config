{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.default.theme;
in
{
  options.default.theme = with types; {
    name = mkOption {
      type = types.str;
      default = "inspired";
      description = "Name of theme to apply apps and tools appearance";
    };
  };
  
  # Dynamically import the theme configuration file
  #config = mkIf (builtins.pathExists ./${cfg.name}.theme.nix) (
  #  import ./${cfg.name}.theme.nix {
  #    inherit pkgs;
  #  }
  #);
}
