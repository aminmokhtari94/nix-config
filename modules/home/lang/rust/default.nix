{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.lang.rust;
in {
  options.default.lang.rust = with types; {
    enable = mkEnableOption "Rust language support";
  };

  config =
    mkIf cfg.enable { home.packages = with pkgs; [ cargo rustc rustup ]; };
}
