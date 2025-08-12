{ config, lib, pkgs, ... }:
with lib;
let cfg = config.default.lang.go;
in {
  options.default.lang.go = with types; {
    enable = mkEnableOption "Golang language support";
  };

  config = mkIf cfg.enable {
    programs.go = { enable = true; };
    home.packages = with pkgs; [ gopls gnumake protobuf buf gcc ko ];
    home.sessionPath = [ "$HOME/go/bin" ];
    programs.nixvim = {
      plugins.dap-go.enable = true;
      extraPlugins = [
        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-go";
          version = "v1.29";
          src = pkgs.fetchFromGitHub {
            owner = "fatih";
            repo = "vim-go";
            rev = "afdc93535605efaa4624b4dde296961add89750f";
            hash = "sha256-goN/0mOExk3rPm6Z5cpnCOMM47K6lK4zBqwin1lnjgk=";
          };
        })
      ];

    };
  };
}
