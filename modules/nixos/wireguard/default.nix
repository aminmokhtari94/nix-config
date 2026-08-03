{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.wireguard;

  wg = "${pkgs.wireguard-tools}/bin/wg";
  wgQuick = "${pkgs.wireguard-tools}/bin/wg-quick";

  # wg/wg-quick refuse to run as a normal user, so shadow them with wrappers
  # that re-exec themselves through sudo. Combined with the NOPASSWD rules
  # below, `wg-quick up wg-rs` just works - no sudo, no password prompt.
  sudoWrapper =
    name: target:
    pkgs.writeShellScriptBin name ''
      if [ "$(id -u)" -eq 0 ]; then
        exec ${target} "$@"
      fi
      exec /run/wrappers/bin/sudo ${target} "$@"
    '';
in
{
  options.default.wireguard = with types; {
    enable = mkEnableOption "wireguard tools";

    sudoless = {
      enable = mkOption {
        type = bool;
        default = true;
        description = ''
          Let members of `sudoless.group` run wg and wg-quick without typing
          sudo and without a password prompt. Note this is root-equivalent:
          a wg-quick config can carry arbitrary PostUp commands.
        '';
      };

      group = mkOption {
        type = str;
        default = "wheel";
        description = "Group allowed to bring wireguard interfaces up and down.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Built into the kernel since 5.6; loading it eagerly keeps `wg` usable
    # before any interface exists.
    boot.kernelModules = [ "wireguard" ];

    environment.systemPackages =
      [ pkgs.wireguard-tools ]
      # hiPrio so the wrappers win the /run/current-system/sw/bin collision
      # against wireguard-tools' own binaries.
      ++ optionals cfg.sudoless.enable [
        (hiPrio (sudoWrapper "wg" wg))
        (hiPrio (sudoWrapper "wg-quick" wgQuick))
      ];

    security.sudo.extraRules = mkIf cfg.sudoless.enable [
      {
        groups = [ cfg.sudoless.group ];
        commands = map
          (command: {
            inherit command;
            options = [ "NOPASSWD" ];
          })
          [
            # What the wrappers exec.
            wg
            wgQuick
            # What a hand-typed `sudo wg-quick ...` resolves to.
            "/run/current-system/sw/bin/wg"
            "/run/current-system/sw/bin/wg-quick"
          ];
      }
    ];
  };
}
