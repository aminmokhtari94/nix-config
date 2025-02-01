{ lib, config, pkgs, ... }:

with lib;
let cfg = config.default.theme;
in {
  options.default.theme = with types; {
    name = mkOption {
      type = str;
      default = "inspired";
      description = "Name of theme to apply to apps and tools appearance";
    };
  };
}
