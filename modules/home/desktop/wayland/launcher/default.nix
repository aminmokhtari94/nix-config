{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.default.desktop.wayland.launcher;
  theme = config.default.theme;
  p = theme.palette;
in
{
  options.default.desktop.wayland.launcher = with types; {
    enable = mkEnableOption "wayland app launcher";

    backend = mkOption {
      type = enum [ "fuzzel" "hyprlauncher" ];
      default = "fuzzel";
      description = ''
        Launcher to install. fuzzel: tiny, fast, vim-friendly keys (Ctrl-N/P,
        Ctrl-J/K), beautiful when themed. hyprlauncher: GTK4, prettier visuals,
        lighter on vim ergonomics.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "fuzzel") {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            font = "${theme.font}:size=12";
            dpi-aware = "yes";
            prompt = ''"❯  "'';
            icon-theme = "Papirus-Dark";
            terminal = "${pkgs.kitty}/bin/kitty";
            layer = "overlay";
            width = 40;
            lines = 12;
            horizontal-pad = 20;
            vertical-pad = 16;
            inner-pad = 8;
            line-height = 22;
            tabs = 4;
            fields = "name,generic,exec";
          };
          colors = {
            background = "${p.bg}f2";
            text       = "${p.fg}ff";
            match      = "${p.accent}ff";
            selection  = "${p.surface}ff";
            selection-text = "${p.fg}ff";
            selection-match = "${p.accent}ff";
            border     = "${p.accent}ff";
          };
          border = {
            width = 2;
            radius = theme.rounding;
          };
          dmenu = {
            exit-immediately-if-empty = "yes";
          };
          # vim-style keybindings on top of fuzzel's defaults
          key-bindings = {
            cancel = "Escape Control+g Control+bracketleft";
            cursor-left = "Left Control+b";
            cursor-right = "Right Control+f";
            delete-prev = "BackSpace Control+h";
            delete-next = "Delete Control+d";
            delete-line-forward = "Control+k";
            prev = "Up Control+p Control+k";
            next = "Down Control+n Control+j";
            prev-page = "Page_Up KP_Page_Up Control+u";
            next-page = "Page_Down KP_Page_Down Control+v Control+d";
            first = "Control+Home";
            last = "Control+End";
            execute = "Return KP_Enter";
          };
        };
      };
    })

    (mkIf (cfg.backend == "hyprlauncher") {
      home.packages = [ pkgs.hyprlauncher ];
      xdg.configFile."hyprlauncher/config.json".text = builtins.toJSON {
        window = {
          width = 600;
          height = 400;
          anchor = "center";
          show_descriptions = true;
          show_actions = true;
          enable_recent_apps = true;
        };
        theming = {
          corners = theme.rounding;
          border_width = 2;
          background_opacity = 0.92;
          accent_color = "#${p.accent}";
        };
      };
    })
  ]);
}
