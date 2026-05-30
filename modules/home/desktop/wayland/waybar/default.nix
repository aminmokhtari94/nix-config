{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.default.desktop.wayland.waybar;
  theme = config.default.theme;
  p = theme.palette;

  hex = c: "#${c}";

  jalaliScript = pkgs.writeShellScript "waybar-jalali" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.jcal
        pkgs.coreutils
      ]
    }:$PATH

    jdate +"%Y/%m/%d"
  '';

  dunstScript = pkgs.writeShellScript "waybar-dunst" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.dunst
        pkgs.gnugrep
      ]
    }:$PATH

    COUNT=$(dunstctl count waiting)
    ENABLED="󰂚 "
    DISABLED="󰂛 "

    if [ "$COUNT" != 0 ]; then
      DISABLED="󱅫 "
    fi

    if dunstctl is-paused | grep -q "false"; then
      echo "$ENABLED"
    else
      echo "$DISABLED"
    fi
  '';

  baseConfig = {
    start_hidden = false;
    margin = "0";
    layer = "top";
    modules-left = [
      "hyprland/workspaces"
      "mpris"
    ];
    modules-center = ["wlr/taskbar"];
    modules-right = [
      "network#interface"
      "network#speed"
      "cpu"
      "temperature"
      "backlight"
      "battery"
      "custom/jalali"
      "clock"
      "custom/notification"
      "wireplumber"
      "tray"
    ];

    persistent_workspaces = {
      "1" = [];
      "2" = [];
      "3" = [];
      "4" = [];
    };

    "hyprland/workspaces" = {
      format = "{icon}";
      on-click = "activate";
      sort-by-number = true;
      format-icons = {
        "default" = "";
        "active" = "";
      };
    };

    mpris = {
      format = "{status_icon}<span weight='bold'>{artist}</span> | {title}";
      status-icons = {
        playing = "󰎈 ";
        paused = "󰏤 ";
        stopped = "󰓛 ";
      };
    };

    "wlr/taskbar" = {
      on-click = "activate";
    };

    "network#interface" = {
      format-ethernet = "󰣶 {ifname}";
      format-wifi = "󰖩 {ifname}";
      tooltip = true;
      tooltip-format = "{ipaddr}";
    };

    "network#speed" = {
      format = "⇡{bandwidthUpBits} ⇣{bandwidthDownBits}";
    };

    cpu = {
      format = " {usage}% 󱐌{avg_frequency}";
    };

    temperature = {
      format = "{icon} {temperatureC} °C";
      format-icons = [
        ""
        ""
        ""
        "󰈸"
      ];
    };

    backlight = {
      format = "{icon} {percent}%";
      format-icons = [
        "󰃜"
        "󰃛"
        "󰃚 "
      ];
    };

    battery = {
      format-critical = "{icon} {capacity}%";
      format = "{icon} {capacity}%";
      format-icons = [
        "󰁺"
        "󰁾"
        "󰂀"
        "󱟢"
      ];
    };

    "custom/jalali" = {
      exec = "${jalaliScript}";
      interval = 60;
      format = "󰃮 {}";
      tooltip = false;
    };

    clock = {
      interval = 60;
      format = " {:%H:%M}";
      format-alt = "󰃭 {:%Y-%m-%d}";
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      calendar = {
        mode = "month";
        weeks-pos = "right";
        on-scroll = 1;
        format = {
          months = "<span color='${hex p.accent2}'><b>{}</b></span>";
          days = "<span color='${hex p.fg}'>{}</span>";
          weeks = "<span color='${hex p.fgMuted}'>W{}</span>";
          weekdays = "<span color='${hex p.warn}'><b>{}</b></span>";
          today = "<span color='${hex p.accent}'><b><u>{}</u></b></span>";
        };
      };
      actions = {
        on-click-right = "mode";
        on-scroll-up = "shift_up";
        on-scroll-down = "shift_down";
      };
    };

    "custom/notification" = {
      exec = "${dunstScript}";
      tooltip = false;
      on-click = "dunstctl set-paused toggle";
      restart-interval = 1;
    };

    wireplumber = {
      format = "{icon} {volume}%";
      format-muted = " ";
      on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      on-click-right = "pavucontrol -t 3";
      on-scroll-up = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      format-icons = [
        ""
        ""
        "󰕾"
        ""
      ];
      max-volume = 140;
    };

    tray = {
      icon-size = 16;
      spacing = 8;
    };
  };

  style = ''
    * {
      border: none;
      min-height: 0;
    }

    window#waybar {
      background-color: ${hex p.bg};
      color: ${hex p.fg};
      font-family: "${theme.font}", "RobotoMono Nerd Font", "Noto Sans";
      font-size: 10px;
    }

    tooltip {
      background-color: ${hex p.bg};
      color: ${hex p.fg};
      border: 1px solid ${hex p.surfaceAlt};
      border-radius: ${toString theme.rounding}px;
    }

    tooltip label {
      padding: 6px 10px;
    }

    #workspaces button {
      color: ${hex p.fgMuted};
      padding: 0 4px;
      margin: 0 4px 0 0;
      border-radius: ${toString theme.rounding}px;
    }

    #workspaces button.active {
      color: ${hex p.accent};
      font-weight: bold;
    }

    #workspaces button.urgent {
      color: ${hex p.urgent};
    }

    #mpris,
    #taskbar,
    #network,
    #cpu,
    #temperature,
    #backlight,
    #battery,
    #custom-jalali,
    #clock,
    #custom-notification,
    #wireplumber {
      padding: 0 4px;
      margin: 0 0 0 4px;
    }

    #custom-jalali {
      color: ${hex p.accent};
    }

    #clock {
      color: ${hex p.accent2};
    }

    #battery {
      color: ${hex p.ok};
    }

    #battery.critical {
      color: ${hex p.urgent};
    }

    #wireplumber {
      color: ${hex p.accent2};
    }

    #tray {
      padding: 0 4px;
    }

    #tray * {
      padding: 0;
      margin: 0;
    }
  '';
in {
  options.default.desktop.wayland.waybar = with types; {
    enable = mkEnableOption "waybar";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.dunst
      pkgs.jcal
      pkgs.noto-fonts
      pkgs.pavucontrol
      pkgs.playerctl
      pkgs.wireplumber
    ];

    services.playerctld.enable = true;

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      package = pkgs.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      });
      settings = {
        mainBar = baseConfig;
      };

      inherit style;
    };

    xdg.configFile."waybar/scripts/task-context.sh" = {
      text = ''
        ICON=" "
        CONTEXT=$(task _get rc.context)

        if [ -z "$CONTEXT" ]; then
          CONTEXT="NONE"
        fi
        echo "$ICON $CONTEXT"
      '';
      executable = true;
    };
  };
}
