{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.lang.esp-idf;
  esp-idf-shell = inputs.nixpkgs-esp-dev.devShells.${pkgs.system}.esp32-idf;
  esp-idf-env = pkgs.writeShellScriptBin "esp-idf" ''
    exec nix develop ${inputs.nixpkgs-esp-dev}#esp32-idf --command zsh "$@"
  '';
in
{
  options.default.lang.esp-idf = with types; {
    enable = mkEnableOption "ESP-IDF development environment";
  };

  config = mkIf cfg.enable {
    home.packages = [
      esp-idf-env
    ];
  };
}
