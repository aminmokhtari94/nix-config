{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.default.desktop.wayland.ironbar;
  theme = config.default.theme;
  p = theme.palette;

  hex = c: "#${c}";

  # Jalali date
  jalaliScript = pkgs.writeShellScript "ironbar-jalali" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.jcal
        pkgs.coreutils
      ]
    }:$PATH
    jdate +"%Y/%m/%d"
  '';

  # System stats (CPU / RAM / Disk)
  sysScript = pkgs.writeShellScript "ironbar-sys" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.procps
        pkgs.gnugrep
        pkgs.gawk
      ]
    }:$PATH

    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
    mem=$(free | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')
    disk=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

    echo "🖥 ''${cpu}%  🧠 ''${mem}%  💾 ''${disk}%"
  '';

  baseConfig = {
    position = "top";
    height = 24;
    anchor_to_edges = true;
    icon_theme = "Papirus";

    start = [
      {
        type = "workspaces";
        all_monitors = false;
        sort = "label";
      }
      {
        type = "music";
        player_type = "mpris";
        format = "{title}";
        truncate = {
          mode = "end";
          length = 40;
        };
      }
    ];

    center = [
      {
        type = "script";
        cmd = "${jalaliScript}";
        mode = "poll";
        interval = 60000;
      }
      {
        type = "clock";
        format = "%H:%M";
        format_popup = "%A %d %B %Y — %H:%M:%S";
      }
    ];

    end =
      (lib.optionals (!cfg.desktop) [
        {
          type = "upower";
          format = "{percentage}%";
        }
        {
          type = "network_manager";
          icon_size = 12;
        }
      ])
      ++ [
        {
          type = "script";
          cmd = "${sysScript}";
          mode = "poll";
          interval = 200;
        }
        {
          type = "volume";
          format = "{percentage}%";
          max_volume = 140;

          # scroll control (PipeWire)
          on_scroll_up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          on_scroll_down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        }
        {
          type = "tray";
          icon_size = 12;
          direction = "horizontal";
        }
      ];
  };
in
{
  options.default.desktop.wayland.ironbar = with types; {
    enable = mkEnableOption "ironbar";

    autostart = mkOption {
      type = bool;
      default = true;
    };

    desktop = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ironbar
      jcal
      playerctl
      networkmanagerapplet
      pavucontrol
      papirus-icon-theme
      procps
      gawk
      gnugrep
    ];

    services.playerctld.enable = true;

    xdg.configFile."ironbar/config.json".text = builtins.toJSON baseConfig;

    xdg.configFile."ironbar/style.css".text = ''
      * {
        font-family: "${theme.font}";
        font-size: 11px;
        border: none;
        min-height: 0;
      }

      .background {
        background-color: ${hex p.bg};
        color: ${hex p.fg};
      }

      .container {
        padding: 0 4px;
        min-height: 22px;
      }

      .item {
        padding: 0 4px;
        margin: 0 2px;
        background: transparent;
        color: ${hex p.fg};
      }

      .workspaces .item {
        color: ${hex p.fgMuted};
      }

      .workspaces .item.focused {
        color: ${hex p.accent};
        font-weight: bold;
      }

      .workspaces .item.urgent {
        color: ${hex p.urgent};
      }

      .clock .label {
        color: ${hex p.accent2};
      }

      .upower {
        color: ${hex p.ok};
      }

      .upower.critical {
        color: ${hex p.urgent};
      }

      .volume {
        color: ${hex p.accent2};
      }

      .tray .item {
        padding: 0 2px;
      }

      popup {
        background-color: ${hex p.bg};
        color: ${hex p.fg};
        border: 1px solid ${hex p.surfaceAlt};
        border-radius: ${toString theme.rounding}px;
        padding: 6px 10px;
      }
    '';

    default.desktop.wayland.hyprland.autostart = mkIf cfg.autostart [ "${pkgs.ironbar}/bin/ironbar" ];
  };
}
