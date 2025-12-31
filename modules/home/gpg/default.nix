{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.default.gpg;
in
{
  options.default.gpg = with types; {
    enable = mkEnableOption "gpg";

    autostart = mkOption {
      type = bool;
      default = true;
      description = "whether to auto start agent";
    };

    enableExtraSocket = mkOption {
      type = bool;
      default = true;
      description = "Whether to enable extra socket";
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          source = ./amin-n550.asc;
          trust = 5;
        }
      ];
      settings = {
        throw-keyids = true;
        no-autostart = !cfg.autostart;
      };
      scdaemonSettings = {
        disable-ccid = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      verbose = true;
      enableSshSupport = true;
      enableExtraSocket = cfg.enableExtraSocket;
      enableZshIntegration = config.programs.zsh.enable;
      pinentryPackage = pkgs.pinentry-gnome3;
      sshKeys = [ "08F5EDD3C01108FE50CD7781EC93568F7E2AB312" ];
    };
  };
}
