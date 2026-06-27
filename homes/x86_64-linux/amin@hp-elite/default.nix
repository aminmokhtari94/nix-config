{ pkgs, ... }:
let
  batteryAlert = pkgs.writeShellScript "battery-alert" ''
    export PATH=${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.findutils
        pkgs.libnotify
      ]
    }

    battery="$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' -print -quit)"
    [ -n "$battery" ] || exit 0

    status="$(cat "$battery/status")"
    capacity="$(cat "$battery/capacity")"
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/battery-alert"
    state_file="$state_dir/last-alert"

    mkdir -p "$state_dir"

    if [ "$status" != "Discharging" ]; then
      rm -f "$state_file"
      exit 0
    fi

    last_alert=""
    [ -f "$state_file" ] && last_alert="$(cat "$state_file")"

    if [ "$capacity" -le 10 ]; then
      if [ "$last_alert" != "critical" ]; then
        notify-send -a Power -u critical "Battery critical" "$capacity% remaining. Plug in now; the system will suspend near empty."
        echo critical > "$state_file"
      fi
    elif [ "$capacity" -le 20 ]; then
      if [ "$last_alert" != "low" ]; then
        notify-send -a Power -u normal "Battery low" "$capacity% remaining."
        echo low > "$state_file"
      fi
    else
      rm -f "$state_file"
    fi
  '';
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.11";
  };
  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  systemd.user.services.battery-alert = {
    Unit.Description = "Low battery desktop alert";
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryAlert}";
    };
  };

  systemd.user.timers.battery-alert = {
    Unit.Description = "Check battery level for desktop alerts";
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "1m";
      Unit = "battery-alert.service";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  xdg.configFile."hypr/hyprland.lua".force = true;

  default = {
    theme.name = "embarl";
    gpg.enable = false;
    # kube.enable = true;
    # vpn.enable = true;
    # lang = {
    #   go.enable = true;
    #   nodejs.enable = true;
    #   python.enable = true;
    #   cpp.enable = true;
    #   esp-idf.enable = true;
    # };
    desktop = {
      enable = true;
      apps = with pkgs; [
        # postman
      ];
      wayland = {
        hyprland = {
          enable = true;
          autostart = [ "Throne" ];
          layout = "scrolling";
        };
        niri = {
          enable = true;
          autostart = [ "Throne" ];
        };
      };
      browser.enable = true;
      kitty.enable = true;
      gtk.enable = false;
      wayland.waybar.enable = true;
      wayland.ironbar = {
        enable = false;
        desktop = true; # drop battery/network modules
      };
      wayland.launcher = {
        enable = true;
        backend = "fuzzel";
      };
      wayland.shaders = {
        enable = true;
        style = "vignette"; # try "crt" or "warm"
      };
      dunst.enable = true;
      nm-applet.enable = true;
      editor = {
        vscode.enable = false;
        cursor.enable = false;
      };
      wine.enable = false;
    };
    agent = {
      claude.enable = true;
      codex.enable = true;
    };
  };

  keyboard = {
    options = "grp:alt_shift_toggle";
  };

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      scale = "1";
      refreshRate = 60;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
      ];
      wallpaper = "~/Pictures/wallpaper.jpg";
    }
  ];
}
