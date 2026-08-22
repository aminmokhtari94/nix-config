{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.desktop.swaync;
  theme = config.default.theme;
  p = theme.palette;

  hex = c: "#${c}";

  # "1e1e2e" -> "30, 30, 46"  (swaync's --noti-bg wants a raw rgb triplet)
  hexDigit =
    c:
    {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    }
    .${toLower c};
  byte = s: i: (hexDigit (substring i 1 s)) * 16 + hexDigit (substring (i + 1) 1 s);
  rgb = c: concatMapStringsSep ", " (i: toString (byte c i)) [ 0 2 4 ];

  radius = theme.rounding;
  sounds = "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo";
  play = file: "${pkgs.mpv}/bin/mpv --no-terminal --no-video --really-quiet ${sounds}/${file}.oga";

  swaync = pkgs.swaynotificationcenter;
in
{
  options.default.desktop.swaync = with types; {
    enable = mkEnableOption "swaync";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inter
      mpv
      swaync
    ];

    services.swaync = {
      enable = true;
      package = swaync;

      settings = {
        positionX = "right";
        positionY = "top";
        layer = "overlay";
        layer-shell = true;
        control-center-layer = "top";
        cssPriority = "user";

        # compact panel, hugging the top-right corner
        control-center-width = 360;
        control-center-height = 560;
        control-center-margin-top = 6;
        control-center-margin-bottom = 6;
        control-center-margin-right = 6;
        control-center-margin-left = 6;
        fit-to-screen = false;

        notification-window-width = 360;
        notification-body-image-width = 180;
        notification-body-image-height = 90;

        # every urgency expires — nothing sticks around after a resume
        timeout = 8;
        timeout-low = 5;
        timeout-critical = 20;
        transition-time = 180;

        hide-on-clear = true;
        hide-on-action = true;
        notification-grouping = true;
        notification-inline-replies = true;
        relative-timestamps = true;
        keyboard-shortcuts = true;
        image-visibility = "when-available";
        ignore-gtk-theme = true;
        text-empty = "󰂛  all quiet";

        widgets = [
          "title"
          "dnd"
          "mpris"
          "notifications"
        ];

        widget-config = {
          title = {
            text = "notifications";
            clear-all-button = true;
            button-text = "󰎟 clear";
          };
          dnd.text = "do not disturb";
          mpris = {
            image-size = 72;
            image-radius = radius;
          };
          notifications.vexpand = true;
        };

        scripts = {
          "00-sound-normal" = {
            exec = play "desktop-login";
            urgency = "Normal";
          };
          "01-sound-critical" = {
            exec = play "dialog-question";
            urgency = "Critical";
          };
        };
      };

      style = ''
        @import url("file://${swaync}/etc/xdg/swaync/style.css");

        :root {
          --cc-bg: rgba(${rgb p.bgAlt}, 0.94);
          --noti-border-color: rgba(${rgb p.surfaceAlt}, 0.55);
          --noti-bg: ${rgb p.bg};
          --noti-bg-alpha: 0.94;
          --noti-bg-darker: rgb(${rgb p.bgAlt});
          --noti-bg-hover: rgb(${rgb p.surface});
          --noti-bg-focus: rgba(${rgb p.surface}, 0.75);
          --noti-close-bg: rgba(${rgb p.surfaceAlt}, 0.55);
          --noti-close-bg-hover: ${hex p.urgent};

          --text-color: ${hex p.fg};
          --text-color-disabled: ${hex p.fgMuted};
          --bg-selected: ${hex p.accent};

          --notification-icon-size: 38px;
          --notification-group-icon-size: 20px;

          --border-radius: ${toString radius}px;
          --border: 1px solid var(--noti-border-color);
          --notification-shadow:
            0 1px 2px rgba(0, 0, 0, 0.35),
            0 4px 14px rgba(0, 0, 0, 0.35);

          --font-size-summary: 12px;
          --font-size-body: 11px;
        }

        * {
          font-family: "${theme.font}", "Inter", "Noto Sans", sans-serif;
        }

        /* --- compact popups --- */
        .notification-row .notification-background {
          margin: 4px 6px;
          border: var(--border);
        }

        .notification-row .notification-background .notification .notification-content {
          padding: 6px 8px;
          min-height: 0;
        }

        .notification-content .image {
          border-radius: ${toString (radius - 3)}px;
          margin: 2px 8px 2px 2px;
        }

        .notification-content .text-box .time {
          font-size: 10px;
          font-weight: normal;
          color: ${hex p.fgMuted};
          margin-right: 26px;
        }

        .notification-content .text-box .body {
          color: ${hex p.fgMuted};
        }

        .close-button {
          min-width: 18px;
          min-height: 18px;
          margin: 4px 4px 0 0;
        }

        /* --- urgency stripe --- */
        .notification-background .notification.low {
          box-shadow: inset 3px 0 0 ${hex p.fgMuted}, var(--notification-shadow);
        }
        .notification-background .notification.normal {
          box-shadow: inset 3px 0 0 ${hex p.accent2}, var(--notification-shadow);
        }
        .notification-background .notification.critical {
          box-shadow: inset 3px 0 0 ${hex p.urgent}, var(--notification-shadow);
        }

        /* --- control center --- */
        .control-center {
          border: var(--border);
        }

        .control-center .control-center-list-placeholder {
          color: ${hex p.fgMuted};
        }

        .widget {
          margin: 6px 8px;
          padding: 6px 8px;
        }

        .widget-title > label {
          font-size: 14px;
          font-weight: bold;
          color: ${hex p.fg};
        }

        .widget-title > button {
          background: rgba(${rgb p.surface}, 0.6);
          color: ${hex p.fg};
          padding: 2px 10px;
          border: none;
          box-shadow: none;
        }

        .widget-title > button:hover {
          background: ${hex p.accent};
          color: ${hex p.bg};
        }

        .widget-dnd {
          padding: 2px 8px;
        }

        .widget-dnd > label {
          font-size: 12px;
        }

        .widget-dnd > switch:checked {
          background: ${hex p.accent};
        }

        .widget-mpris .widget-mpris-player {
          margin: 6px 8px;
        }
      '';
    };
  };
}
